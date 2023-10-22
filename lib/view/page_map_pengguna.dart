import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../utils/decoder.dart';
import '../utils/gps_phone.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapUserPage extends StatefulWidget {
  const MapUserPage({Key? key}) : super(key: key);

  @override
  State<MapUserPage> createState() => _MapUserPageState();
}

class _MapUserPageState extends State<MapUserPage> {
  UserGPS userGPS = UserGPS();

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getRoutePeriodically();
  }

  bool ispostMarkerAdded = false;
  Symbol? markerSymbolId;
  Line? routeLine;

  MapboxMapController? _controller;
  List<LegStep> steps = [];

  late Timer timer;
  static const Duration refreshInterval = Duration(seconds: 5);

  double distance = 0.0;
  double duration = 0.0;

  String errorMessage = '';

  void updateLocation(LatLng currentLocation) async {
    try {
      // Get the current timestamp
      final Timestamp timestamp = Timestamp.now();

      // Update the pengguna location in Firestore
      await FirebaseFirestore.instance
          .collection('location')
          .doc('petugas')
          .set({
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'timestamp': timestamp, // Store the timestamp for reference
      });
    } catch (e) {
      // Handle any errors that occur while updating the location
    }
  }

  void getCurrentLocation() async {
    try {
      Position currentPosition = await userGPS.getCurrentLocation();
      LatLng currentLatLng = LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      // Call the method to update the location in Firestore
      updateLocation(currentLatLng);

      // Update the route based on the current location
      updateRoute(currentLatLng);
    } catch (e) {
      // Handle any exceptions that occur while getting the current location
    }
  }

  void getRoutePeriodically() {
    Timer.periodic(refreshInterval, (Timer timer) {
      getCurrentLocation();
    });
  }

  void updateRoute(LatLng currentLocation) async {
    LatLng origin = currentLocation;

    try {
      // Remove the previous marker
      if (markerSymbolId != null) {
        _controller?.removeSymbol(markerSymbolId!);
      }

      // Fetch the destination from Firestore
      DocumentSnapshot destinationSnapshot = await FirebaseFirestore.instance
          .collection('location')
          .doc('pengguna')
          .get();

      // Retrieve the destination coordinates from the snapshot
      double destinationLatitude = destinationSnapshot['latitude'];
      double destinationLongitude = destinationSnapshot['longitude'];
      LatLng destination = LatLng(destinationLatitude, destinationLongitude);

      // Get the route using the updated origin and destination
      await getRoute(origin, destination);

      // Add the marker for the end point if it hasn't been added yet
      if (!ispostMarkerAdded) {
        // Add a marker for the end point
        _controller?.addSymbol(
          SymbolOptions(
            geometry: LatLng(
              destination.latitude,
              destination.longitude,
            ),
            iconImage: 'assets/marker_pengguna.png',
            iconSize: 0.3,
          ),
        );
        ispostMarkerAdded = true;
      }
    } catch (e) {
      // Handle any errors that occur while fetching the destination or route
    }
  }

  Future<void> getRoute(LatLng origin, LatLng destination) async {
    // Reset the error message
    setState(() {
      errorMessage = '';
    });

    try {
      Uri routeUri = Uri.parse(
          "https://api.mapbox.com/directions/v5/mapbox/walking/"
          "${origin.longitude},${origin.latitude};"
          "${destination.longitude},${destination.latitude}?"
          "access_token=pk.eyJ1IjoiZGFmZmFtYWxpazE0MyIsImEiOiJjbGkyMTd4eTgwM2s4M3Fsc3F3N3JpYXIxIn0.YoAMqd6vEzktZcCNFhnXRg");
      http.Response routeResponse = await http.get(routeUri);

      if (routeResponse.statusCode == 200) {
        var decodedResponse = json.decode(routeResponse.body);
        List<LatLng> route =
            decodeLine(decodedResponse['routes'][0]['geometry']);

        // Remove the previous line if it exists
        if (routeLine != null) {
          _controller?.removeLine(routeLine!);
        }

        // Add the new line
        routeLine = await _controller?.addLine(
          LineOptions(
            geometry: route,
            lineColor: "#FF5800",
            lineWidth: 3.0,
          ),
        );

        distance = double.parse(
            decodedResponse['routes'][0]['legs'][0]['distance'].toString());
        duration = double.parse(decodedResponse['routes'][0]['legs'][0]
                    ['duration']
                .toString()) /
            60;

        steps = decodedResponse['routes'][0]['legs'][0]['steps']
            .map<LegStep>((step) => LegStep(
                  location: step['maneuver']['location'],
                  maneuver: step['maneuver']['instruction'],
                ))
            .toList();
        // Add a marker for the start point
        markerSymbolId = await _controller?.addSymbol(
          SymbolOptions(
            geometry: LatLng(
              origin.latitude,
              origin.longitude,
            ),
            iconImage: 'assets/marker_petugas.png',
            iconSize: 0.3,
          ),
        );
      } else {
        setState(() {
          errorMessage =
              'Failed to retrieve route. Error code: ${routeResponse.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peta pengguna"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Column(
        children: [
          if (errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.red,
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          // Add a container to display the distance and duration
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Distance: ${distance >= 1000 ? '${(distance / 1000).toStringAsFixed(2)} km' : '${distance.toStringAsFixed(2)} meters'}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  'Duration: ${duration.toInt()} minutes',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
          Expanded(
            child: MapboxMap(
              accessToken:
                  "pk.eyJ1IjoiZGFmZmFtYWxpazE0MyIsImEiOiJjbGkyMTd4eTgwM2s4M3Fsc3F3N3JpYXIxIn0.YoAMqd6vEzktZcCNFhnXRg",
              initialCameraPosition: const CameraPosition(
                target: LatLng(-6.9743585, 107.6302565),
                zoom: 12.0,
              ),
              onMapCreated: (MapboxMapController controller) {
                setState(() {
                  _controller = controller;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LegStep {
  final List<double> location;
  final String maneuver;

  LegStep({required this.location, required this.maneuver});
}
