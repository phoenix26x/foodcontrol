import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zzz/screen/fooddetailspage.dart';

import '../setting.dart';

class UpdateQueuePageAdmin extends StatefulWidget {
  const UpdateQueuePageAdmin({super.key});

  @override
  _UpdateQueuePageAdminState createState() => _UpdateQueuePageAdminState();
}

class _UpdateQueuePageAdminState extends State<UpdateQueuePageAdmin> {
  List<Map<String, dynamic>> queueData = [];
  String currentStatus = 'รอคิว';

  @override
  void initState() {
    super.initState();
    fetchDataFromAPI();
  }

  void showFoodDetails(Map<String, dynamic> entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailsPage(
          entry: entry,
          username: entry['username'],
          datetime: entry['datetime'],
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'อัพเดทสถานะ คิว',
          style: TextStyle(
            color: Colors.white, // สีตัวหนังสือ AppBar
          ),
        ),
        backgroundColor: Color.fromARGB(255, 104, 0, 130), // สีพื้นหลัง AppBar
      ),
      backgroundColor: Color.fromARGB(255, 209, 134, 255), // สีพื้นหลังของหน้าจอ
      body: Center(
        child: _buildPage(currentStatus),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentStatus == 'รอคิว' ? 0 : 1,
        onTap: (index) {
          setState(() {
            currentStatus = index == 0 ? 'รอคิว' : 'กำลังปรุงอาหาร';
          });
        },
        selectedItemColor: Color.fromARGB(255, 137, 48, 151), // สีไอเท็มที่เลือก
        unselectedItemColor: Color.fromARGB(255, 243, 37, 174), // สีไอเท็มที่ไม่ได้เลือก
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
            headingRowColor: MaterialStateProperty.all(
                Color.fromARGB(255, 216, 23, 194)), // สีพื้นหลังของหัวข้อ
            dataRowColor:
                MaterialStateProperty.all(Colors.white), // สีพื้นหลังของข้อมูล
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  'คิว',
                  style: TextStyle(
                    color: Colors.white, // สีตัวหนังสือหัวข้อ
                    fontSize: 18,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'ชื่อผู้ใช้',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'สถานะ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'อัปเดตสถานะ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'เวลา',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'รายละเอียด',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
            rows: queueData
                .where((entry) =>
                    status == 'รอคิว' ? entry['status'] == 'รอคิว' : entry['status'] == 'กำลังปรุงอาหาร')
                .map(
                  (entry) => DataRow(
                    cells: <DataCell>[
                      DataCell(Text(
                        (queueData.indexOf(entry) + 1).toString(),
                        style: const TextStyle(color: Colors.black), // สีตัวหนังสือข้อมูล
                      )),
                      DataCell(Text(
                        entry['username'],
                        style: const TextStyle(color: Colors.black),
                      )),
                      DataCell(Text(
                        entry['status'],
                        style: const TextStyle(color: Colors.black),
                      )),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            final newStatus = entry['status'] == 'กำลังปรุงอาหาร'
                                ? 'ปรุงเสร็จแล้ว'
                                : 'กำลังปรุงอาหาร';
                            updateQueueStatus(entry['id'], newStatus);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 70, 130, 180), // สีปุ่ม
                          ),
                          child: Text(
                            entry['status'] == 'กำลังปรุงอาหาร'
                                ? 'อัปเดตเสร็จแล้ว'
                                : 'อัปเดต',
                            style: const TextStyle(color: Colors.white), // สีตัวหนังสือในปุ่ม
                          ),
                        ),
                      ),
                      DataCell(Text(
                        entry['datetime'],
                        style: const TextStyle(color: Colors.black),
                      )),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            showFoodDetails(entry);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800], // สีปุ่ม "รายละเอียดเพิ่มเติม"
                          ),
                          child: const Text(
                            'รายละเอียดเพิ่มเติม',
                            style: TextStyle(color: Colors.white), // สีตัวหนังสือในปุ่ม
                          ),
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
