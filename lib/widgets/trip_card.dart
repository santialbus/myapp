import 'package:flutter/material.dart';
import 'package:myapp/models/trip_schema.dart';

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
