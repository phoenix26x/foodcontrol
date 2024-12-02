import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../setting.dart';

class AboutRider1 extends StatelessWidget {
  AboutRider1({Key? key});

  Future<List<Map<String, dynamic>>> getSavedData() async {
    var url =
        'http://$ip/restarant_papai/flutter1/up_user.php'; // อับเดท URL ของฐานข้อมูลของคุณที่นี่
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            size: 35,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getSavedData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            var data = snapshot.data!;
            return ListView(
              children: [
                ExpansionTile(
                  title: Text('เวลาเปิดร้านอาหาร'),
                  leading: Icon(
                    Icons.access_time, // ไอคอนนาฬิกา
                    color: const Color.fromARGB(255, 244, 159, 49), // สีของไอคอน
                  ),
                  children: [
                    for (var item in data) // ใช้ for-loop เพื่อแสดงข้อมูลเวลาเปิดร้านอาหาร
                      ListTile(
                        title: Text(item['day']),
                        subtitle: Text(' ${item['open']} - ${item['close']}'),
                      ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
