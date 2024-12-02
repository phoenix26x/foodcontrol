// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_const_constructors, unnecessary_brace_in_string_interps, avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../setting.dart';
import 'map.dart';

class UserAddressEdit extends StatelessWidget {
  final String username;
  final Function(Map<String, dynamic> updatedAddress) onUpdate;

  const UserAddressEdit({super.key, required this.username, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _addressController = TextEditingController();
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _phoneController = TextEditingController();
    final TextEditingController _latController = TextEditingController();
    final TextEditingController _lngController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไข Location'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10.0, top: 25),
            child: Text(
              'Username : ${username}',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'สถานที่',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(
              labelText: 'address',
              border: OutlineInputBorder(),
            ),
            controller: _addressController,
          ),
          SizedBox(height: 10),
          Text(
            'ข้อมูลติดต่อ',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(
              labelText: 'name',
              border: OutlineInputBorder(),
            ),
            controller: _nameController,
          ),
          SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(
              labelText: 'เบอร์โทรศัพท์',
              border: OutlineInputBorder(),
            ),
            controller: _phoneController,
          ),
          SizedBox(height: 10),
          Text(
            'ตำแหน่งที่อยู่',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    border: OutlineInputBorder(),
                  ),
                  controller: _latController,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    border: OutlineInputBorder(),
                  ),
                  controller: _lngController,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserMaps(
                    latController: _latController,
                    lngController: _lngController,
                    onLocationSelect: (lat, lng) {
                      _latController.text = lat.toStringAsFixed(6);
                      _lngController.text = lng.toStringAsFixed(6);
                    },
                  ),
                ),
              );
            },
            child: const Text(
              'เลือกจากแผนที่',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final lat = _latController.text;
              final lng = _lngController.text;
              final address = _addressController.text;
              final name = _nameController.text;
              final phone = _phoneController.text;

              if (lat.isNotEmpty &&
                  lng.isNotEmpty &&
                  address.isNotEmpty &&
                  name.isNotEmpty &&
                  phone.isNotEmpty) {
                final updatedAddress = {
                  'lat': lat,
                  'lng': lng,
                  'address': address,
                  'name': name,
                  'phone': phone,
                  'username': username,
                };

                final response = await http.post(
                  Uri.parse('http://$ip/restarant_papai/flutter1/location.php'),
                  body: {
                    'action': 'create',
                    ...updatedAddress,
                  },
                );

                if (response.statusCode == 200) {
                  final result = json.decode(response.body);
                  print(result['message']);
                  onUpdate(updatedAddress);
                  Navigator.pop(context);
                } else {
                  print('Failed to save data. Status code: ${response.statusCode}');
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
                  ),
                );
              }
            },
            child: const Text(
              'บันทึก',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
