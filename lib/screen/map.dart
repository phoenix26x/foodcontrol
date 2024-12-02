import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class UserMaps extends StatefulWidget {
  final TextEditingController latController; // ตรวจสอบพารามิเตอร์นี้
  final TextEditingController lngController; // และพารามิเตอร์นี้
  final void Function(double, double) onLocationSelect;

  UserMaps({
    required this.latController,
    required this.lngController,
    required this.onLocationSelect,
  });
  @override
  State<UserMaps> createState() => UserMapsState();
}

class UserMapsState extends State<UserMaps> {
  static const LatLng centerMap = const LatLng(13.907539, 100.505518);
  CameraPosition cameraPosition = CameraPosition(
    target: centerMap,
    zoom: 16.0,
  );
  late GoogleMapController _controller;
  late LocationData currentLocation;
  MapType _currentMapType = MapType.hybrid;
  Set<Marker> _markers = {};
  TextEditingController _latController = TextEditingController();
  TextEditingController _lngController = TextEditingController();
  LatLng? myLocation;
  Timer? myTimer;

  @override
  void initState() {
    super.initState();
    findLocation();

    // Create a timer that runs every 60 seconds
    myTimer = Timer.periodic(Duration(seconds: 60), (timer) {
      if (mounted) {
        _addUserLocationMarker();
      }
    });
  }

  @override
  void dispose() {
    // Cancel the timer in the dispose method
    myTimer?.cancel();
    super.dispose();
  }

  Future<void> findLocation() async {
    var location = Location();
    try {
      currentLocation = await location.getLocation();
      cameraPosition = CameraPosition(
        target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        zoom: 16.0,
      );
      _addUserLocationMarker();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission Denied');
      }
    }
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
        ),
      );
    });
  }

  void _addUserLocationMarker() {
    setState(() {
      _markers.clear();

      _markers.add(
        Marker(
          markerId: MarkerId('userLocation'),
          position:
              LatLng(currentLocation.latitude!, currentLocation.longitude!),
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text(
          'เลือกที่อยู่จากแผนที่',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 70),
        child: Column(
          children: [
            Expanded(
              child: GoogleMap(
                mapType: _currentMapType,
                initialCameraPosition: cameraPosition,
                markers: _markers,
                onTap: (latLng) => _onMapTap(latLng),
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    readOnly: true,
                    decoration: InputDecoration(labelText: 'Latitude'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _lngController,
                    readOnly: true,
                    decoration: InputDecoration(labelText: 'Longitude'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: _onMapTypeButtonPressed,
                  heroTag: 'mapType',
                  tooltip: 'Change Map Type',
                  child: Icon(Icons.map),
                ),
                FloatingActionButton(
                  onPressed: _goToTheLake,
                  heroTag: 'goToLake',
                  tooltip: 'Go to the Lake',
                  child: Icon(Icons.gps_fixed),
                ),
                FloatingActionButton(
                  onPressed: _addUserLocationMarker,
                  heroTag: 'addUserLocation',
                  tooltip: 'Add User Location',
                  child: Icon(Icons.add_location),
                ),
                FloatingActionButton(
                  onPressed: _confirmLocation,
                  heroTag: 'confirmLocation',
                  tooltip: 'Confirm Location',
                  child: Icon(Icons.check),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    if (_markers.isNotEmpty) {
      LatLng centerOfMarker = _calculateCenterOfMarkers();
      CameraPosition newCameraPosition = CameraPosition(
        target: centerOfMarker,
        zoom: 16.0,
      );

      await _controller.animateCamera(
        CameraUpdate.newCameraPosition(newCameraPosition),
      );
    }
  }

  LatLng _calculateCenterOfMarkers() {
    if (_markers.isNotEmpty) {
      double latSum = 0;
      double lngSum = 0;

      for (Marker marker in _markers) {
        latSum += marker.position.latitude;
        lngSum += marker.position.longitude;
      }

      double latCenter = latSum / _markers.length;
      double lngCenter = lngSum / _markers.length;

      return LatLng(latCenter, lngCenter);
    } else {
      return centerMap;
    }
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      _markers.clear();
      _addMarker(latLng);
      _updateTextFields(latLng);
    });
  }

  void _updateTextFields(LatLng latLng) {
    _latController.text = latLng.latitude.toStringAsFixed(6);
    _lngController.text = latLng.longitude.toStringAsFixed(6);
  }

  void _confirmLocation() {
    if (_markers.isNotEmpty) {
      myLocation = _markers.first.position;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('ตำแหน่งของฉัน'),
          content: Text(
              'Latitude: ${myLocation!.latitude}\nLongitude: ${myLocation!.longitude}'),
          actions: [
            TextButton(
              onPressed: () {
                widget.onLocationSelect(
                  myLocation!.latitude,
                  myLocation!.longitude,
                );
                Navigator.pop(context);
              },
              child: Text('ยืนยันตำแหน่ง'),
            ),
          ],
        ),
      );
    }
  }
}
