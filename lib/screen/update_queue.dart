// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zzz/screen/fooddetailspage.dart';

import '../setting.dart';

class UpdateQueuePage extends StatefulWidget {
  const UpdateQueuePage({super.key});

  @override
  _UpdateQueuePageState createState() => _UpdateQueuePageState();
}

class _UpdateQueuePageState extends State<UpdateQueuePage> {
  List<Map<String, dynamic>> queueData = [];
  String currentStatus = 'รอคิว'; // เริ่มต้นที่ 'รอคิว'

  @override
  void initState() {
    super.initState();
    fetchDataFromAPI();
  }

  // ฟังก์ชันสำหรับแสดงรายละเอียดอาหาร
  void showFoodDetails(Map<String, dynamic> entry) {
    // ตรวจสอบว่า cart.status = 2, cart.username = queue.username, และ cart.datetime = queue.datetime
    // แล้วแสดงรายละเอียดอาหารที่ตรงกัน
    // เรียกหน้ารายละเอียดอาหารและส่งข้อมูลที่ตรงกันไป
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailsPage(
          entry: entry,
          username: entry['username'], // เพิ่ม username
          datetime: entry['datetime'], // เพิ่ม datetime
        ),
      ),
    );
  }

  Future<void> updateQueueStatus(String queueId, String status) async {
    final response = await http.post(
      Uri.parse(
          'http://$ip/restarant_papai/flutter1/queue/update_queue_status.php'),
      body: {
        'id': queueId,
        'status': status,
      },
    );

    if (response.statusCode == 200) {
      fetchDataFromAPI();
    } else {
      // Handle update error
    }
  }

  Future<void> fetchDataFromAPI() async {
    final response = await http.get(
        Uri.parse('http://$ip/restarant_papai/flutter1/queue/queue.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        queueData = data.cast<Map<String, dynamic>>();
      });
    } else {
      // Handle data fetch error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('อัพเดทสถานะ คิว'),
      ),
      body: Center(
        child: _buildPage(currentStatus), // เรียก _buildPage ด้วย currentStatus
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentStatus == 'รอคิว' ? 0 : 1, // กำหนด currentIndex จาก currentStatus
        onTap: (index) {
          setState(() {
            currentStatus = index == 0 ? 'รอคิว' : 'กำลังปรุงอาหาร'; // ปรับค่า currentStatus จาก index
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'รอคิว',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'กำลังปรุงอาหาร',
          ),
        ],
      ),
    );
  }

  Widget _buildPage(String status) {
    return ListView(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const <DataColumn>[
              DataColumn(label: Text('คิว')),
              DataColumn(label: Text('ชื่อผู้ใช้')),
              DataColumn(label: Text('สถานะ')),
              DataColumn(label: Text('อัปเดตสถานะ')),
              DataColumn(label: Text('เวลา')),
              DataColumn(label: Text('รายละเอียด')),
            ],
            rows: queueData
                .asMap()
                .entries
                .where((entry) => status == 'รอคิว'
                    ? entry.value['status'] == 'รอคิว'
                    : entry.value['status'] == 'กำลังปรุงอาหาร')
                .map(
                  (entry) => DataRow(
                    cells: <DataCell>[
                      DataCell(Text((entry.key + 1).toString())),
                      DataCell(Text(entry.value['username'])),
                      DataCell(Text(entry.value['status'])),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            if (entry.value['status'] ==
                                'กำลังปรุงอาหาร') {
                              updateQueueStatus(
                                  entry.value['id'], 'ปรุงเสร็จแล้ว');
                            } else {
                              updateQueueStatus(
                                  entry.value['id'], 'กำลังปรุงอาหาร');
                            }
                          },
                          child: Text(
                            entry.value['status'] == 'กำลังปรุงอาหาร'
                                ? 'อัปเดตเสร็จแล้ว'
                                : 'อัปเดต',
                          ),
                        ),
                      ),
                      DataCell(Text(entry.value['datetime'])),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            // เรียกฟังก์ชัน showFoodDetails เพื่อแสดงรายละเอียดอาหาร
                            showFoodDetails(entry.value);
                          },
                          child: const Text('รายละเอียดเพิ่มเติม'),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
