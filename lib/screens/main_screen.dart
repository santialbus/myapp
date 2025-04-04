import 'package:flutter/material.dart';
import 'package:myapp/models/trip_schema.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // Dummy data for TripSchema
  List<TripSchema> get trips => [
        TripSchema(
          tripId: "1",
          serviceId: "svc1",
          firstStopName: "Station A",
          lastStopName: "Station B",
          firstDepartureTime: "08:00",
          lastArrivalTime: "09:00",
          routeShortName: "R1",
        ),
        TripSchema(
          tripId: "2",
          serviceId: "svc2",
          firstStopName: "Station C",
          lastStopName: "Station D",
          firstDepartureTime: "10:00",
          lastArrivalTime: "11:30",
          routeShortName: "R2",
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Main Screen")),
      body: trips.isEmpty
          ? const Center(child: Text("No trips found."))
          : ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return TripCard(trip: trip);
              },
            ),
    );
  }
}

class TripCard extends StatelessWidget {
  final TripSchema trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Route: ${trip.routeShortName}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text("First Stop: ${trip.firstStopName ?? "N/A"}"),
            Text("Last Stop: ${trip.lastStopName ?? "N/A"}"),
            Text("Departure: ${trip.firstDepartureTime ?? "N/A"}"),
            Text("Arrival: ${trip.lastArrivalTime ?? "N/A"}"),
          ],
        ),
      ),
    );
  }
}
