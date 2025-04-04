class TripSchema {
  String tripId;
  String serviceId;
  String? firstStopName;
  int? firstStopSequence;
  String? firstArrivalTime;
  String? firstDepartureTime;
  String? lastStopName;
  int? lastStopSequence;
  String? lastArrivalTime;
  String? lastDepartureTime;
  String routeShortName;

  TripSchema({
    required this.tripId,
    required this.serviceId,
    this.firstStopName,
    this.firstStopSequence,
    this.firstArrivalTime,
    this.firstDepartureTime,
    this.lastStopName,
    this.lastStopSequence,
    this.lastArrivalTime,
    this.lastDepartureTime,
    required this.routeShortName,
  });

  factory TripSchema.fromJson(Map<String, dynamic> json) {
    return TripSchema(
      tripId: json['trip_id'],
      serviceId: json['service_id'],
      firstStopName: json['first_stop_name'],
      firstStopSequence: json['first_stop_sequence'],
      firstArrivalTime: json['first_arrival_time'],
      firstDepartureTime: json['first_departure_time'],
      lastStopName: json['last_stop_name'],
      lastStopSequence: json['last_stop_sequence'],
      lastArrivalTime: json['last_arrival_time'],
      lastDepartureTime: json['last_departure_time'],
      routeShortName: json['route_short_name'],
    );
  }
}