// ignore_for_file: unused_field, camel_case_types, library_private_types_in_public_api, avoid_print, unused_element, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class select_detail extends StatefulWidget {
  final Map<String, dynamic> addressData;
  final Function(Map<String, dynamic>) onUpdate;

  const select_detail({super.key, required this.addressData, required this.onUpdate});

  @override
  _select_detailState createState() => _select_detailState();
}

class _select_detailState extends State<select_detail> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController latController;
  late TextEditingController lngController;

  GoogleMapController? _controller;
  CameraPosition? _initialPosition; // ประกาศ _initialPosition ในนี้

  @override
  void initState() {
    super.initState();

    addressController =TextEditingController(text: widget.addressData['address']);
    nameController = TextEditingController(text: widget.addressData['name']);
    phoneController = TextEditingController(text: widget.addressData['phone']);
    latController = TextEditingController(text: widget.addressData['lat']);
    lngController = TextEditingController(text: widget.addressData['lng']);

    double? lat = double.tryParse(latController.text);
    double? lng = double.tryParse(lngController.text);

    if (lat != null && lng != null) {
      LatLng location = LatLng(lat ?? 0.0,
          lng ?? 0.0); // แปลงเป็น double และใช้ค่าเริ่มต้นถ้าเป็น null

      _initialPosition = CameraPosition(
        target: location,
        zoom: 17.0,
      );
    } else {
      print('Invalid latitude or longitude format');
    }
  }

  void _updateTextFields() {
    setState(() {
      nameController.text = widget.addressData['name'];
      phoneController.text = widget.addressData['phone'];
      addressController.text = widget.addressData['address'];
      latController.text = widget.addressData['lat'];
      lngController.text = widget.addressData['lng'];
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดที่อยู่'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                    height: 300,
                    child: GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _controller = controller;
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          double.parse(latController.text),
                          double.parse(lngController.text),
                        ),
                        zoom: 17.0,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('addressLocation'),
                          position: LatLng(
                            double.parse(latController.text),
                            double.parse(lngController.text),
                          ),
                          infoWindow: InfoWindow(
                            title: addressController.text,
                            snippet:
                                'ชื่อ: ${nameController.text}, เบอร์โทร: ${phoneController.text}',
                          ),
                        ),
                      },
                    )),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'ที่อยู่:',
                  style: TextStyle(fontSize: 16),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    hintText: 'ระบุที่อยู่',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ชื่อ:',
                  style: TextStyle(fontSize: 16),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'ระบุชื่อ',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'เบอร์โทร:',
                  style: TextStyle(fontSize: 16),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    hintText: 'ระบุเบอร์โทร',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ตำแหน่ง:',
                  style: TextStyle(fontSize: 16),
                ),
                TextField(
                  controller: TextEditingController(
                      text: '${latController.text}, ${lngController.text}'),
                  decoration: const InputDecoration(
                    hintText: 'เลือกพิกัดตำแหน่ง',
                  ),
                ),
                const SizedBox(height: 16),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
