// ignore_for_file: library_private_types_in_public_api, unnecessary_string_interpolations

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:zzz/screen/order_detail.dart';

import '../setting.dart'; 

class HistoryUser extends StatefulWidget {
  final String username;

  const HistoryUser({super.key, required this.username});

  @override
  _HistoryUserState createState() => _HistoryUserState();
}

class _HistoryUserState extends State<HistoryUser> {
  List<Map<String, dynamic>> queueData = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th');
    fetchDataFromAPI();
  }

  Future<void> fetchDataFromAPI() async {
    final response = await http.get(Uri.parse(
        'http://$ip/restarant_papai/flutter1/history.php?username=${widget.username}'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // แปลง List<dynamic> เป็น List<Map<String, dynamic>>
      final List<Map<String, dynamic>> dataList =
          List<Map<String, dynamic>>.from(data);

      final filteredData =
          dataList.where((entry) => entry['status'] == 'ปรุงเสร็จแล้ว');

      setState(() {
        queueData = filteredData.toList();
      });
    } else {
      // จัดการข้อผิดพลาดในการดึงข้อมูล
    }
  }

  void navigateToOrderDetails(Map<String, dynamic> orderData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(
            username: widget.username, datetime: orderData['datetime']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการสั่งซื้อ', textAlign: TextAlign.center),
      ),
      body: ListView.builder(
        itemCount: queueData.length,
        itemBuilder: (context, index) {
          final entry = queueData[index];

          // แปลงวันที่ให้เป็นรูปแบบ 'dd MMM yyyy' (ตัวอย่าง: '10 ม.ค. 2023')
          final formattedDate = DateFormat('dd MMM yyyy', 'th')
              .format(DateTime.parse(entry['datetime']));

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 2),
            child: ListTile(
              contentPadding: const EdgeInsets.only(
                  top: 20, bottom: 20, right: 10, left: 10),
              leading: ClipOval(
                child: Image.asset(
                  'assets/logofood.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                '${entry['username']}',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$formattedDate',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'สถานะ: สำเร็จ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              trailing: Text(
                '${entry['price']}',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                navigateToOrderDetails(entry);
              },
            ),
          );
        },
      ),
    );
  }
}
