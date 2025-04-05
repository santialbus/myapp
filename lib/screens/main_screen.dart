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
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: 150.0,
              collapsedHeight: kToolbarHeight,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                // Changed flexibleSpace to FlexibleSpaceBar
                title:
                    innerBoxIsScrolled
                        ? Text(
                          "Tu estación mas cercana: Alicante/Alacant",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                        : null,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                      child: Image.asset(
                        'assets/images/trains2.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    LayoutBuilder(
                      builder: (
                        BuildContext context,
                        BoxConstraints constraints,
                      ) {
                        final top = constraints.biggest.height - kToolbarHeight;
                        final progress = top / (150 - kToolbarHeight);
                        final opacity = progress;

                        return Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 16),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: FadeTransition(
                              opacity: AlwaysStoppedAnimation(opacity),
                              child: DefaultTextStyle(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                                child:
                                    progress > 0.5
                                        ? const Text(
                                          "Tu estación mas cercana: Alicante/Alacant",
                                        )
                                        : const SizedBox(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: ListView(
          children: [
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? Center(child: Text("Error: $error"))
                : trips.isEmpty
                ? const Center(child: Text("No trips found."))
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return TripCard(trip: trip);
                  },
                ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        // Corrected bottomNavigationBar
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
