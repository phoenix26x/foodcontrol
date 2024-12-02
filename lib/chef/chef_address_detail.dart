// ignore_for_file: unused_field, prefer_const_constructors, library_private_types_in_public_api, avoid_print, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressDetailsChef extends StatefulWidget {
  final Map<String, dynamic> addressData;
  final Function(Map<String, dynamic>) onUpdate;

  const AddressDetailsChef({super.key, required this.addressData, required this.onUpdate});

  @override
  _AddressDetailsChefState createState() => _AddressDetailsChefState();
}

class _AddressDetailsChefState extends State<AddressDetailsChef> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController latController;
  late TextEditingController lngController;

  GoogleMapController? _controller;
  CameraPosition? _initialPosition;

  @override
  void initState() {
    super.initState();

    addressController =
        TextEditingController(text: widget.addressData['address']);
    nameController = TextEditingController(text: widget.addressData['name']);
    phoneController = TextEditingController(text: widget.addressData['phone']);
    latController = TextEditingController(text: widget.addressData['lat']);
    lngController = TextEditingController(text: widget.addressData['lng']);

    double? lat = double.tryParse(latController.text);
    double? lng = double.tryParse(lngController.text);

    if (lat != null && lng != null) {
      LatLng location = LatLng(lat ?? 0.0, lng ?? 0.0);

      _initialPosition = CameraPosition(
        target: location,
        zoom: 17.0,
      );
    } else {
      print('Invalid latitude or longitude format');
    }
  }

  Future<void> showConfirmationDialog(
      Function action, String actionText) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันการ $actionText'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('คุณแน่ใจหรือไม่ที่ต้องการ $actionText ที่อยู่นี้?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ยืนยัน'),
              onPressed: () {
                action();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดที่อยู่'),
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
                          markerId: MarkerId('addressLocation'),
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
                SizedBox(
                  height: 20,
                ),
                Text(
                  'ที่อยู่:',
                  style: TextStyle(fontSize: 16),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: 'ระบุที่อยู่',
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'ชื่อ:',
                  style: TextStyle(fontSize: 16),
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'ระบุชื่อ',
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'เบอร์โทร:',
                  style: TextStyle(fontSize: 16),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    hintText: 'ระบุเบอร์โทร',
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'ตำแหน่ง:',
                  style: TextStyle(fontSize: 16),
                ),
                TextField(
                  controller: TextEditingController(
                      text: '${latController.text}, ${lngController.text}'),
                  decoration: InputDecoration(
                    hintText: 'เลือกพิกัดตำแหน่ง',
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
