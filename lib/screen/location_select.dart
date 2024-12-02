// ignore_for_file: unnecessary_null_comparison, library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zzz/screen/cart.dart';
import 'package:zzz/screen/location_select_detail.dart';

import '../setting.dart';

class LocationSelectionPage extends StatefulWidget {
  final String username;

  const LocationSelectionPage({super.key, required this.username});

  @override
  _LocationSelectionPageState createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  int selectedAddressIndex = -1;
  List<Map<String, dynamic>> addressList = [];
  int selectedLocationId = -1; // เพิ่มตัวแปรนี้
  

  @override
  void initState() {
    super.initState();
    fetchAddressData();
  }

  Future<void> fetchAddressData() async {
    final response = await http.get(
      Uri.parse(
          'http://$ip/restarant_papai/flutter1/location.php?username=${widget.username}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(data);

      setState(() {
        addressList = dataList;
      });
    } else {
      // จัดการข้อผิดพลาดในการดึงข้อมูล
    }
  }

  void _addToCart() {
  if (selectedAddressIndex != -1) {
    // ส่ง username และ location_id ไปยังหน้า "CartPage"
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          username: widget.username,
          locationId: selectedLocationId, // ส่ง location_id ไปยัง CartPage
        ),
      ),
    );
  } else {
    // แสดงข้อความแจ้งเตือนถ้าไม่มีรายการที่อยู่ที่ถูกเลือก
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('คำเตือน'),
          content: const Text(
              'กรุณาเลือกที่อยู่ที่คุณต้องการรับอาหาร'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เลือกที่อยู่ผู้ใช้ : ${widget.username}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: addressList != null && addressList.isNotEmpty
                ? ListView.builder(
                    itemCount: addressList.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedAddressIndex;

                      return Card(
                        elevation: 2.0,
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(addressList[index]['address']),
                          subtitle: Text(addressList[index]['name']),
                          trailing: Radio<bool>(
                            value: isSelected,
                            groupValue: true,
                            onChanged: (_) {
                              setState(() {
                                if (isSelected) {
                                  selectedAddressIndex = -1;
                                } else {
                                  selectedAddressIndex = index;
                                  selectedLocationId = addressList[index][
                                      'location_id']; // เก็บ location_id ที่ถูกเลือก
                                }
                              });
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => select_detail(
                                  addressData: addressList[index],
                                  onUpdate: (updatedAddress) {
                                    setState(() {
                                      addressList[index] = updatedAddress;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text('ไม่มีข้อมูลที่อยู่'),
                  ),
          ),
          ElevatedButton(
            onPressed: _addToCart,
            child: const Text('เพิ่มลงในรถเข็น'),
          ),
        ],
      ),
    );
  }
}
