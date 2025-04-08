// main_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:myapp/models/trip_schema.dart';
import 'package:myapp/api/api_client.dart';
import 'package:myapp/widgets/custom_app_bar.dart';
import 'package:myapp/widgets/trip_card.dart';
import '../widgets/custom_bottom_app_bar.dart';

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
  String? selectedTrain; // 🔥

  @override
  void initState() {
    super.initState();
    fetchTrips();

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
        trips = [
          TripSchema(
            tripId: "mocked_trip",
            serviceId: "mocked_service",
            firstStopName: "Mocked Start",
            firstStopSequence: 1,
            firstArrivalTime: "08:00",
            firstDepartureTime: "08:05",
            lastStopName: "Mocked End",
            lastStopSequence: 5,
            lastArrivalTime: "09:00",
            lastDepartureTime: "09:05",
            routeShortName: "MOCK",
          ),
        ];
        filteredTrips = trips;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final destination = selectedDestination?.trim();
    final train = selectedTrain?.trim(); // 🔥

    setState(() {
      filteredTrips = trips.where((trip) {
        final matchDestination = destination == null || destination.isEmpty
            ? true
            : destination.split(',').map((e) => e.trim()).contains(trip.lastStopName);

        final matchTrain = train == null || train.isEmpty
            ? true
            : train.split(',').map((e) => e.trim()).contains(trip.routeShortName);

        return matchDestination && matchTrain;
      }).toList();

      showFilters = false;
    });
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
                    onDestinationChanged: (String? newDestination) {
                      setState(() {
                        selectedDestination = newDestination;
                      });
                    },
                    onTrainChanged: (String? newTrain) {
                      setState(() {
                        selectedTrain = newTrain;
                      });
                    },
                    selectedDestination: selectedDestination,
                    selectedTrain: selectedTrain, // 🔥
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

// ======================== FILTERS PANEL ========================
class SearchFiltersPanel extends StatelessWidget {
  final VoidCallback onSearchPressed;
  final List<TripSchema> trips;
  final ValueChanged<String?> onDestinationChanged;
  final ValueChanged<String?> onTrainChanged; // 🔥
  final String? selectedDestination;
  final String? selectedTrain; // 🔥

  const SearchFiltersPanel({
    super.key,
    required this.onSearchPressed,
    required this.trips,
    required this.onDestinationChanged,
    required this.onTrainChanged, // 🔥
    required this.selectedDestination,
    required this.selectedTrain, // 🔥
  });

  @override
  Widget build(BuildContext context) {
    List<String> destinations = trips
        .map((trip) => trip.lastStopName)
        .whereType<String>()
        .toSet()
        .toList();

    List<String> trains = trips
        .map((trip) => trip.routeShortName)
        .whereType<String>()
        .toSet()
        .toList();

    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Modifica tu búsqueda",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDestinationSelector(context, destinations),
          const SizedBox(height: 12),
          _buildTrainSelector(context, trains), // 🔥
          const SizedBox(height: 12),
          _buildSearchItem(Icons.access_time, "Horario", "Mañana, Tarde, Noche"),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSearchPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Buscar", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationSelector(BuildContext context, List<String> destinations) {
    return _buildMultiSelect(
      context,
      label: "Selecciona uno o varios destinos",
      values: destinations,
      selectedValue: selectedDestination,
      onChanged: onDestinationChanged,
    );
  }

  Widget _buildTrainSelector(BuildContext context, List<String> trains) {
    return _buildMultiSelect(
      context,
      label: "Selecciona uno o varios trenes",
      values: trains,
      selectedValue: selectedTrain,
      onChanged: onTrainChanged,
    );
  }

  Widget _buildMultiSelect(
      BuildContext context, {
        required String label,
        required List<String> values,
        required String? selectedValue,
        required ValueChanged<String?> onChanged,
      }) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          isScrollControlled: true,
          builder: (BuildContext context) {
            List<String> selectedItems = [];
            bool selectAll = false;

            return StatefulBuilder(
              builder: (context, setModalState) {
                return DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.7,
                  maxChildSize: 0.95,
                  minChildSize: 0.4,
                  builder: (context, scrollController) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CheckboxListTile(
                              title: const Text("Todos"),
                              value: selectAll,
                              onChanged: (bool? value) {
                                setModalState(() {
                                  selectAll = value ?? false;
                                  selectedItems = selectAll ? List.from(values) : [];
                                });
                              },
                            ),
                            const Divider(),
                            ...values.map((val) {
                              return CheckboxListTile(
                                title: Text(val),
                                value: selectedItems.contains(val),
                                onChanged: (bool? value) {
                                  setModalState(() {
                                    if (value == true) {
                                      selectedItems.add(val);
                                    } else {
                                      selectedItems.remove(val);
                                      selectAll = false;
                                    }
                                  });
                                },
                              );
                            }).toList(),
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
                (selectedValue == null || selectedValue.trim().isEmpty)
                    ? label
                    : selectedValue,
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

  Widget _buildSearchItem(IconData icon, String title, String hint) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.black45)),
              Text(hint, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
