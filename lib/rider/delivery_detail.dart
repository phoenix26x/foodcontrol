// ignore_for_file: prefer_const_constructors, prefer_collection_literals

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../setting.dart';

class DeliveryDetailPageRider extends StatefulWidget {
  final username;
  final datetime;
  final Map<String, dynamic> entry;

  DeliveryDetailPageRider({
    required this.entry,
    required this.username,
    required this.datetime,
  });

  @override
  State<DeliveryDetailPageRider> createState() => _DeliveryDetailPageRiderState();
}

class _DeliveryDetailPageRiderState extends State<DeliveryDetailPageRider> {
  List<Map<String, dynamic>> cartData = [];
  String locationId = '';
  Map<String, dynamic> userLocation = {};

  @override
  void initState() {
    super.initState();
    locationId = widget.entry['location_id'].toString();
    fetchDataFromDatabase();
    fetchUserLocation(widget.entry['location_id'].toString()).then((data) {
      setState(() {
        userLocation = data;
      });
    });
  }

  String getDeliveryMethodText(String deliveryMethod) {
    switch (deliveryMethod) {
      case 'deliverymethod.inStorePickup':
        return 'มารับหน้าร้าน';
      case 'deliverymethod.dineIn':
        return 'รับประทานในร้าน';
      case 'deliverymethod.delivery':
        return 'ส่งตามที่อยู่ GPS';
      default:
        return 'ไม่ระบุ';
    }
  }

  Future<Map<String, dynamic>> fetchUserLocation(String locationId) async {
    final response = await http.get(
      Uri.parse(
        'http://$ip/restarant_papai/flutter1/fetch_location.php?location_id=$locationId',
      ),
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      if (decodedResponse != null &&
          decodedResponse['lat'] != null &&
          decodedResponse['lng'] != null) {
        return decodedResponse;
      } else {
        throw Exception('Invalid user location data');
      }
    } else {
      throw Exception('Failed to load user location data');
    }
  }

  Future<void> fetchDataFromDatabase() async {
    final username = widget.username;
    final datetime = widget.datetime;
    final response = await http.get(
      Uri.parse(
          'http://$ip/restarant_papai/flutter1/menu_detail.php?username=$username&datetime=$datetime'),
    );

    if (response.statusCode == 200) {
      try {
        final List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        setState(() {
          cartData = data;
        });
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดอาหาร'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: ListView(
          children: [
            ListTile(
              title: Text('Location ID: $locationId'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ชื่อลูกค้า: ${userLocation['name']}'),
                  Text('ที่อยู่: ${userLocation['address']}'),
                  Text('เบอร์โทรศัพท์: ${userLocation['phone']}'),
                  Text('พิกัดที่อยู่: ${userLocation['lat']} , ${userLocation['lng']}',
                  ),
                  SizedBox(height: 20,),
                  // แสดงแผนที่ด้วย GoogleMap
                  Container(
                    height: 300, // กำหนดความสูงของแผนที่
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          double.tryParse(userLocation['lat'] ?? '0.0') ?? 0.0,
                          double.tryParse(userLocation['lng'] ?? '0.0') ?? 0.0,
                        ),
                        zoom: 15.0, // ระดับซูมเริ่มต้น
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('user_location'),
                          position: LatLng(
                            double.tryParse(userLocation['lat'] ?? '0.0') ??
                                0.0,
                            double.tryParse(userLocation['lng'] ?? '0.0') ??
                                0.0,
                          ),
                          infoWindow: InfoWindow(
                            title:'ชื่อ :${userLocation['name']},ที่อยู่ :${userLocation['address']}, เบอร์ติดต่อ :${userLocation['phone']}',
                          ),
                        ),
                      },
                      onMapCreated: (GoogleMapController controller) {
                        // ใช้ controller.animateCamera เพื่อย้ายกล้องไปยังตำแหน่งของ Marker
                        controller.animateCamera(
                          CameraUpdate.newLatLng(
                            LatLng(
                              double.tryParse(userLocation['lat'] ?? '0.0') ??
                                  0.0,
                              double.tryParse(userLocation['lng'] ?? '0.0') ??
                                  0.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            for (var food in cartData)
              ListTile(
                leading: Image.network(
                  'http://$ip/restarant_papai/upload/menu/${food['menu_pics']}',
                  width: 100,
                  height: 100,
                ),
                title: Text('${food['menu_name']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('จำนวน: ${food['quantity']}'),
                    Text('${getDeliveryMethodText(food['delivery_method'])}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
