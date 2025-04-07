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
  bool isLoading = true;
  String? error;
  bool showFilters = false;
  final ScrollController _scrollController = ScrollController();
  final double searchBarBottom = kToolbarHeight + 60 + 12;

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
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                  : trips.isEmpty
                  ? const Center(child: Text("No trips found."))
                  : ListView.builder(
                padding: const EdgeInsets.only(top: 16),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  return TripCard(trip: trip);
                },
              ),
            ),
          ),

          /// FILTROS FIJOS SOBRE EL CONTENIDO
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
                    onSearchPressed: () {
                      setState(() {
                        showFilters = false;
                      });
                    },
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

  const SearchFiltersPanel({super.key, required this.onSearchPressed});

  @override
  Widget build(BuildContext context) {
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
          _buildSearchItem(Icons.location_on, "Destino", "Ej: Madrid"),
          const SizedBox(height: 12),
          _buildSearchItem(Icons.train, "Tipo de tren", "AVE, MD, etc."),
          const SizedBox(height: 12),
          _buildSearchItem(Icons.access_time, "Horario", "Mañana, Tarde, Noche"),
          const SizedBox(height: 16),
          // Botón de buscar con ancho expandido
          SizedBox(
            width: double.infinity,  // Esto hace que el botón ocupe todo el ancho disponible
            child: ElevatedButton(
              onPressed: onSearchPressed, // Al presionar se ocultan los filtros
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

