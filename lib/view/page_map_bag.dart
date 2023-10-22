import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../utils/decoder.dart';
import '../utils/gps_phone.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/auth.dart';

class MapBagPage extends StatefulWidget {
  const MapBagPage({Key? key}) : super(key: key);

  @override
  State<MapBagPage> createState() => _MapBagPageState();
}

class _MapBagPageState extends State<MapBagPage> {
  UserGPS userGPS = UserGPS();
  late Color _backgroundColor;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    _backgroundColor = Colors.blue; // Assign a default background color
    _preloadUserData(); // Preload user data
    super.initState();
    getCurrentLocation();
    getRoutePeriodically();
  }

  void _preloadUserData() async {
    _userData = await Auth().getUserData();
    if (_userData != null) {
      final accountType = _userData!['accountType'];
      setState(() {
        if (accountType == 'pengguna') {
          _backgroundColor = Colors.teal;
        } else {
          _backgroundColor = Colors.blue;
        }
      });
    }
  }

  bool isBagMarkerAdded = false;
  Symbol? markerSymbolId;
  Line? routeLine;

  MapboxMapController? _controller;
  List<LegStep> steps = [];

  late Timer timer;
  static const Duration refreshInterval = Duration(seconds: 5);

  double distance = 0.0;
  double duration = 0.0;

  String errorMessage = '';

  void getCurrentLocation() async {
    try {
      Position currentPosition = await userGPS.getCurrentLocation();
      LatLng currentLatLng = LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      );
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
          .doc('gps')
          .get();

      // Retrieve the destination coordinates from the snapshot
      double destinationLatitude = destinationSnapshot['latitude'];
      double destinationLongitude = destinationSnapshot['longitude'];
      LatLng destination = LatLng(destinationLatitude, destinationLongitude);

      // Get the route using the updated origin and destination
      await getRoute(origin, destination);

      // Add the marker for the end point if it hasn't been added yet
      if (!isBagMarkerAdded) {
        // Add a marker for the end point
        _controller?.addSymbol(
          SymbolOptions(
            geometry: LatLng(
              destination.latitude,
              destination.longitude,
            ),
            iconImage: 'assets/custom_bag.png',
            iconSize: 1,
          ),
        );
        isBagMarkerAdded = true;
      }

      // Calculate the bounds of the route
      double minLat = min(origin.latitude, destination.latitude);
      double maxLat = max(origin.latitude, destination.latitude);
      double minLng = min(origin.longitude, destination.longitude);
      double maxLng = max(origin.longitude, destination.longitude);

      // Calculate the center point of the bounds
      double centerLat = (minLat + maxLat) / 2;
      double centerLng = (minLng + maxLng) / 2;

      // Calculate the distance between the bounds' corners
      double distance = calculateDistance(minLat, minLng, maxLat, maxLng);

      // Calculate the zoom level based on the distance
      double zoomLevel = calculateZoomLevel(distance);

      // Move the camera to the calculated position and zoom level
      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(centerLat, centerLng),
          zoomLevel,
        ),
      );
    } catch (e) {
      // Handle any errors that occur while fetching the destination or route
    }
  }

  // Helper method to calculate the distance between two points on the map
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6378137; // Earth's radius in meters

    double dLat = (lat2 - lat1) * pi / 180;
    double dLng = (lng2 - lng1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  // Helper method to calculate the zoom level based on the distance
  double calculateZoomLevel(double distance) {
    const double cameraZoom = 13; // Maximum zoom level

    // Adjust the zoom level based on the distance
    double zoomLevel = cameraZoom - log(distance / 500) / log(2);

    return max(0, zoomLevel); // Ensure zoom level is not negative
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

        distance = decodedResponse['routes'][0]['legs'][0]['distance'];
        duration = decodedResponse['routes'][0]['legs'][0]['duration'] / 60;

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
            iconImage: 'assets/custom_marker.png',
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
          title: const Text("Peta Tas"), backgroundColor: _backgroundColor),
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
