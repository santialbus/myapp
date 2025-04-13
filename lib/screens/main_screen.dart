// main_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:myapp/models/trip_schema.dart';
import 'package:myapp/api/api_client.dart';
import 'package:myapp/widgets/custom_app_bar.dart';
import 'package:myapp/widgets/trip_card.dart';
import '../widgets/custom_bottom_app_bar.dart';
import '../helpers/location_helper.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiClient apiClient = ApiClient();
  List<TripSchema> trips = [];
  List<TripSchema> filteredTrips = [];
  bool isLoading = true;
  String? error;
  bool showFilters = false;
  final ScrollController _scrollController = ScrollController();
  final double searchBarBottom = kToolbarHeight + 60 + 12;
  String? selectedDestination;
  String? selectedTrain;
  List<String> selectedPeriods = [];
  String? currentCity;

  @override
  void initState() {
    super.initState();
    fetchTrips();
    fetchLocation();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (showFilters) {
          setState(() {
            showFilters = false;
          });
        }
      }
    });
  }

  Future<void> fetchLocation() async {
    final city = await LocationHelper.getCurrentCity();
    setState(() {
      currentCity = city;
    });
  }

  Future<void> fetchTrips() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await apiClient.get(
        '/trips/getLocalTrips',
        queryParameters: {'date': '20250401'},
      );

      if (response != null) {
        final List<dynamic> data = response;
        setState(() {
          trips = data.map((json) => TripSchema.fromJson(json)).toList();
          filteredTrips = trips;
        });
      } else {
        setState(() {
          error = "Failed to fetch trips: Response is null";
        });
      }
    } catch (e) {
      setState(() {
        trips = [];
        filteredTrips = [];
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final destination = selectedDestination?.trim();
    final train = selectedTrain?.trim();

    setState(() {
      filteredTrips = trips.where((trip) {
        final matchDestination = destination == null || destination.isEmpty
            ? true
            : destination.split(',').map((e) => e.trim()).contains(trip.lastStopName);

        final matchTrain = train == null || train.isEmpty
            ? true
            : train.split(',').map((e) => e.trim()).contains(trip.routeShortName);

        final matchPeriod = selectedPeriods.isEmpty
            ? true
            : _matchesPeriod(trip.firstArrivalTime ?? '', selectedPeriods);

        return matchDestination && matchTrain && matchPeriod;
      }).toList();

      showFilters = false;
    });
  }

  bool _matchesPeriod(String time, List<String> periods) {
    final hour = int.tryParse(time.split(':')[0]) ?? 0;

    for (var period in periods) {
      switch (period) {
        case 'Mañana':
          if (hour >= 0 && hour <= 12) return true;
          break;
        case 'Tarde':
          if (hour >= 13 && hour <= 20) return true;
          break;
        case 'Noche':
          if (hour >= 21 && hour <= 23) return true;
          break;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                CustomAppBar(
                  onExpandFilters: () {
                    setState(() {
                      showFilters = !showFilters;
                    });
                  },
                  originCity: currentCity,
                ),
              ];
            },
            body: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                  ? Center(child: Text("Error: $error"))
                  : filteredTrips.isEmpty
                  ? const Center(child: Text("No trips found."))
                  : ListView.builder(
                padding: const EdgeInsets.only(top: 16),
                itemCount: filteredTrips.length,
                itemBuilder: (context, index) {
                  final trip = filteredTrips[index];
                  return TripCard(trip: trip);
                },
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: showFilters ? searchBarBottom : -300,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: showFilters ? 1.0 : 0.0,
              child: Transform.scale(
                scale: showFilters ? 1.0 : 0.95,
                alignment: Alignment.topCenter,
                child: Material(
                  elevation: 12,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: SearchFiltersPanel(
                    trips: trips,
                    onSearchPressed: _applyFilters,
                    onDestinationChanged: (value) => setState(() => selectedDestination = value),
                    onTrainChanged: (value) => setState(() => selectedTrain = value),
                    onPeriodChanged: (value) => setState(() => selectedPeriods = value),
                    selectedDestination: selectedDestination,
                    selectedTrain: selectedTrain,
                    selectedPeriods: selectedPeriods,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomAppBar(),
    );
  }
}

class SearchFiltersPanel extends StatelessWidget {
  final VoidCallback onSearchPressed;
  final List<TripSchema> trips;
  final ValueChanged<String?> onDestinationChanged;
  final ValueChanged<String?> onTrainChanged;
  final ValueChanged<List<String>> onPeriodChanged;
  final String? selectedDestination;
  final String? selectedTrain;
  final List<String> selectedPeriods;

  const SearchFiltersPanel({
    super.key,
    required this.onSearchPressed,
    required this.trips,
    required this.onDestinationChanged,
    required this.onTrainChanged,
    required this.onPeriodChanged,
    required this.selectedDestination,
    required this.selectedTrain,
    required this.selectedPeriods,
  });

  @override
  Widget build(BuildContext context) {
    List<String> destinations = trips.map((trip) => trip.lastStopName).whereType<String>().toSet().toList();
    List<String> trains = trips.map((trip) => trip.routeShortName).whereType<String>().toSet().toList();
    List<String> periods = ['Mañana', 'Tarde', 'Noche'];

    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("Modifica tu búsqueda", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildCheckboxSelector(context, "Selecciona uno o varios destinos", destinations, selectedDestination, onDestinationChanged),
          const SizedBox(height: 12),
          _buildCheckboxSelector(context, "Selecciona tipo de tren", trains, selectedTrain, onTrainChanged),
          const SizedBox(height: 12),
          _buildPeriodSelector(context, periods),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSearchPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Buscar", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxSelector(BuildContext context, String hint, List<String> items, String? selected, ValueChanged<String?> onChanged) {
    return GestureDetector(
      onTap: () {
        List<String> selectedItems = selected?.split(',') ?? [];
        bool selectAll = selectedItems.length == items.length;

        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          isScrollControlled: true,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.6,
                  maxChildSize: 0.95,
                  minChildSize: 0.4,
                  builder: (context, scrollController) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            CheckboxListTile(
                              title: const Text("Todos"),
                              value: selectAll,
                              onChanged: (value) {
                                setModalState(() {
                                  selectAll = value ?? false;
                                  selectedItems = selectAll ? List.from(items) : [];
                                });
                              },
                            ),
                            const Divider(),
                            ...items.map((item) => CheckboxListTile(
                              title: Text(item),
                              value: selectedItems.contains(item),
                              onChanged: (value) {
                                setModalState(() {
                                  if (value == true) {
                                    selectedItems.add(item);
                                  } else {
                                    selectedItems.remove(item);
                                    selectAll = false;
                                  }
                                });
                              },
                            )),
                            const SizedBox(height: 12),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  onChanged(selectAll ? '' : selectedItems.join(','));
                                  Navigator.pop(context);
                                },
                                child: const Text("Aplicar"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                (selected == null || selected.trim().isEmpty)
                    ? hint
                    : selected,
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, List<String> periods) {
    List<String> selectedItems = List.from(selectedPeriods);
    bool selectAll = selectedItems.length == periods.length;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          isScrollControlled: true,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.4,
                  builder: (context, scrollController) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            CheckboxListTile(
                              title: const Text("Todos"),
                              value: selectAll,
                              onChanged: (value) {
                                setModalState(() {
                                  selectAll = value ?? false;
                                  selectedItems = selectAll ? List.from(periods) : [];
                                });
                              },
                            ),
                            const Divider(),
                            ...periods.map((item) => CheckboxListTile(
                              title: Text(item),
                              value: selectedItems.contains(item),
                              onChanged: (value) {
                                setModalState(() {
                                  if (value == true) {
                                    selectedItems.add(item);
                                  } else {
                                    selectedItems.remove(item);
                                    selectAll = false;
                                  }
                                });
                              },
                            )),
                            const SizedBox(height: 12),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  onPeriodChanged(List.from(selectedItems));
                                  Navigator.pop(context);
                                },
                                child: const Text("Aplicar"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedPeriods.isEmpty
                    ? "Selecciona horario"
                    : selectedPeriods.join(', '),
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
