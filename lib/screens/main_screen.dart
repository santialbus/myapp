import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myapp/models/trip_schema.dart';
import 'package:myapp/api/api_client.dart';

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

  @override
  void initState() {
    super.initState();
    fetchTrips();
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
        error = "Failed to fetch trips: ${e.toString()}";
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  expandedHeight: 150.0,
                  collapsedHeight: kToolbarHeight,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final isExpanded = constraints.maxHeight > kToolbarHeight;

                      return ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // 🖼 Fondo con imagen
                            Image.asset(
                              'assets/images/tren22.png',
                              fit: BoxFit.cover,
                            ),

                            if (!isExpanded)
                              BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                child: Container(
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 16.0,
                                  bottom: isExpanded ? 16.0 : 8.0,
                                  right: 16.0,
                                ),
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: isExpanded ? 1.0 : 0.0,
                                  child: const Text(
                                    "Tu estación más cercana: Alicante/Alacant",
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black45,
                                          blurRadius: 4,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
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
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final TripSchema trip;
  const TripCard({Key? key, required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Trip ID: ${trip.tripId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Service ID: ${trip.serviceId}'),
            Text('Route: ${trip.routeShortName}'),
            const Divider(),
            const Text(
              "First Stop",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Name: ${trip.firstStopName ?? "N/A"}'),
            Text('Sequence: ${trip.firstStopSequence ?? "N/A"}'),
            Text('Arrival: ${trip.firstArrivalTime ?? "N/A"}'),
            Text('Departure: ${trip.firstDepartureTime ?? "N/A"}'),
            const Divider(),
            const Text(
              "Last Stop",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Name: ${trip.lastStopName ?? "N/A"}'),
            Text('Sequence: ${trip.lastStopSequence ?? "N/A"}'),
            Text('Arrival: ${trip.lastArrivalTime ?? "N/A"}'),
            Text('Departure: ${trip.lastDepartureTime ?? "N/A"}'),
          ],
        ),
      ),
    );
  }
}
