import 'dart:ui';
import 'package:flutter/material.dart';
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
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                CustomAppBar(),
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
      bottomNavigationBar: const CustomBottomAppBar(),
    );
  }
}
