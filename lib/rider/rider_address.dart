// ignore_for_file: unused_local_variable, unnecessary_null_comparison, non_constant_identifier_names, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../screen/address_detail.dart';
import '../setting.dart';
import 'rider_address2.dart';
import 'rider_address_detail.dart';

class UserAddressRider extends StatefulWidget {
  final String username;

  const UserAddressRider({super.key, required this.username});

  @override
  State<UserAddressRider> createState() => UserAddressRiderState();
}

class UserAddressRiderState extends State<UserAddressRider> {
  List<Map<String, dynamic>> addressList = [];

  Future<void> deleteLocation(String username, int location_id) async {
    var url = 'http://$ip/restarant_papai/flutter1/lcoation_delete.php'; // แก้ไข URL เป็น location_delete.php
    var response = await http.post(Uri.parse(url), body: {
      'location_id': location_id.toString(), // แก้ไข location_id เป็น id
    });

    if (response.statusCode == 200) {
      print('ลบที่อยู่ออกจากฐานข้อมูลแล้ว');
    } else {
      print('ไม่สามารถลบที่อยู่ออกจากฐานข้อมูลได้');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAddressData();
  }

  Future<void> _fetchAddressData() async {
    try {
      var response = await http.get(
        Uri.parse(
          'http://$ip/restarant_papai/flutter1/location.php?username=${widget.username}',
        ),
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> addresses =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        setState(() {
          addressList = addresses;
        });
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _navigateToAddressDetails(Map<String, dynamic> addressData) async {
    final updatedAddress = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressDetailsRider(
          addressData: addressData,
          onUpdate: (updatedAddress) {
            // ตรวจสอบว่า updatedAddress ไม่เป็น null และทำการอัพเดตข้อมูลที่อยู่ในรายการ
            if (updatedAddress != null) {
              final index = addressList.indexWhere((item) =>
                  item['address'] == addressData['address'] &&
                  item['name'] == addressData['name'] &&
                  item['phone'] == addressData['phone']);
              if (index != -1) {
                setState(() {
                  addressList[index] = updatedAddress;
                });
              }
            }
          },
        ),
      ),
    );
  }

  void updateAddressList(Map<String, dynamic> newAddress) {
    setState(() {
      addressList.add(newAddress);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ที่อยู่ผู้ใช้ : ${widget.username}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: addressList != null && addressList.isNotEmpty
                ? ListView.builder(
                    itemCount: addressList.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(addressList[index]['location_id'].toString()), // ใช้ location_id เป็นคีย์
                        onDismissed: (direction) async {
                          // ทำงานเมื่อถูกลบ
                          var username = widget.username;
                          var locationId = addressList[index]['location_id'];
                          await deleteLocation(username, locationId); // เรียกฟังก์ชันลบที่อยู่
                          setState(() {
                            addressList.removeAt(index); // ลบออกจากลิสต์
                          });
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          color: Colors.red, // สีพื้นหลังเมื่อลากไปทางขวา
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          elevation: 2.0,
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(addressList[index]['address']),
                            subtitle: Text(addressList[index]['name']),
                            onTap: () {
                              _navigateToAddressDetails(addressList[index]);
                            },
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text('ไม่มีข้อมูลที่อยู่'),
                  ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserAddressEditRider(
                    username: widget.username,
                    onUpdate: (Map<String, dynamic> updatedAddress) {
                      updateAddressList(updatedAddress);
                    },
                  ),
                ),
              ); 
            },
            child: const Text('เพิ่มที่อยู่'),
          ),
        ],
      ),
    );
  }
}
