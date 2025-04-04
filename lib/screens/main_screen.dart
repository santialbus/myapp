import 'dart:convert';
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
              // title: innerBoxIsScrolled ? const Text("Tu estación mas cercana: Alicante/Alacant", style: TextStyle(fontSize: 24.0, color: Colors.white),) : null,
              backgroundColor: Colors.lightBlue,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final opacity =
                      (constraints.maxHeight - kToolbarHeight) /
                      (150.0 - kToolbarHeight);
                  final bottomPadding =
                      16.0 *
                      ((constraints.maxHeight - kToolbarHeight) /
                          (150.0 - kToolbarHeight));
                  return FlexibleSpaceBar(
                    background: Container(
                      color: Colors.lightBlue,
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 16.0,
                          bottom: bottomPadding,
                        ),
                        child: Opacity(
                          opacity: opacity,
                          child: const Text(
                            "Tu estación mas cercana: Alicante/Alacant",
                            style: TextStyle(
                              fontSize: 24.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
