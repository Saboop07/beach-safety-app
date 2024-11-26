import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CoastalScreen extends StatefulWidget {
  @override
  _CoastalScreenState createState() => _CoastalScreenState();
}

class _CoastalScreenState extends State<CoastalScreen> {
  late GoogleMapController mapController;
  late Position _currentPosition;
  String _currentAddress = "Loading address...";
  LatLng _currentLatLng = LatLng(20.5937, 78.9629); // Default centered on India
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {}; // Set to hold the polyline
  final TextEditingController _controller = TextEditingController();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _controller.addListener(() {
      _onChanged();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (!serviceEnabled) {
        _showLocationError('Location services are disabled. Please enable them.');
        return;
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _showLocationError('Location permission denied. Please allow location access.');
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _currentLatLng = LatLng(_currentPosition.latitude, _currentPosition.longitude);

      setState(() {
        _markers.add(Marker(
          markerId: MarkerId('current_location'),
          position: _currentLatLng,
          infoWindow: InfoWindow(title: 'You are here', snippet: _currentAddress),
        ));
      });

      mapController.animateCamera(CameraUpdate.newLatLngZoom(_currentLatLng, 15));
    } catch (e) {
      setState(() {
        _currentAddress = 'Failed to get location';
      });
    }
  }

  _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = (Random().toString());
      });
    }
    getSuggestion(_controller.text);
  }

  void getSuggestion(String input) async {
    const String PLACES_API_KEY = "YOUR_GOOGLE_MAPS_API_KEY";

    try {
      String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request = '$baseURL?input=$input&key=$PLACES_API_KEY&sessiontoken=$_sessionToken';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      print(e);
    }
  }

  void _showPredictionModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: _placeList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                var prediction = _placeList[index];
                var placeId = prediction["place_id"];
                setState(() {
                  _currentLatLng = LatLng(10.0, 20.0); // Placeholder: Replace with real lat/lng
                  _markers.add(Marker(
                    markerId: MarkerId(placeId),
                    position: _currentLatLng,
                    infoWindow: InfoWindow(title: prediction["description"]),
                  ));
                });
                mapController.animateCamera(CameraUpdate.newLatLngZoom(_currentLatLng, 15));
                Navigator.pop(context);
              },
              child: ListTile(
                title: Text(_placeList[index]["description"]),
              ),
            );
          },
        );
      },
    );
  }

  void _showLocationError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_polylines.isEmpty) {
      _polylines.add(Polyline(
        polylineId: PolylineId('green_line_1'),
        visible: true,
        points: [
          LatLng(9.931233, 76.267303),
          LatLng(9.931233 + 0.01, 76.267303 + 0.01),
        ],
        color: Colors.green,
        width: 5,
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Coastal Map"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(20.5937, 78.9629),
              zoom: 5,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Image.asset(
              'assets/color.png', // Path to your image in the assets folder
              height: 100, // Adjust the size
              width: 100,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: Icon(Icons.location_searching),
      ),
    );
  }
}
