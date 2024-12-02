// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, avoid_print, unnecessary_string_interpolations

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../setting.dart';

class FoodDetailsPageUser extends StatefulWidget {
  final Map<String, dynamic> entry;

  FoodDetailsPageUser({required this.entry, required username, required datetime});

  @override
  State<FoodDetailsPageUser> createState() => _FoodDetailsPageUserState();
}

class _FoodDetailsPageUserState extends State<FoodDetailsPageUser> {
  List<Map<String, dynamic>> cartData = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase();
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

  Future<void> fetchDataFromDatabase() async {
    final username = widget.entry['username'];
    final datetime = widget.entry['datetime'];
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
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
