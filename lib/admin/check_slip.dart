import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zzz/setting.dart';

class CheckSlibPage extends StatefulWidget {
  @override
  _CheckSlibPageState createState() => _CheckSlibPageState();
}

class _CheckSlibPageState extends State<CheckSlibPage> {
  List<Map<String, dynamic>> queueData = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromAPI();
  }

  Future<void> fetchDataFromAPI() async {
    final response = await http
        .get(Uri.parse('http://$ip/restarant_papai/flutter1/queue/queue.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final filteredData = data.where((entry) =>
          entry['status'] == 'รออนุมัติ' ||
          entry['status'] == 'ส่งอาหารแล้ว');

      setState(() {
        queueData = filteredData.toList().cast<Map<String, dynamic>>();
      });
    } else {
      // Handle error fetching data
    }
  }

  Future<void> _handleRefresh() async {
    await fetchDataFromAPI();
  }

  Future<void> updateQueueStatus(String queueId, String status) async {
    final response = await http.post(
      Uri.parse('http://$ip/restarant_papai/flutter1/queue/update_queue_status.php'),
      body: {
        'id': queueId,
        'status': status,
      },
    );

    if (response.statusCode == 200) {
      await fetchDataFromAPI();
    } else {
      throw Exception('Failed to update status');
    }
  }

  void updateQueueData(List<Map<String, dynamic>> newData) {
    setState(() {
      queueData = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ตรวจสอบการชำระ',
          style: TextStyle(fontSize: 20, color: Colors.white), // เพิ่มขนาดตัวอักษรในแอปบาร์
        ),
        backgroundColor: Color.fromARGB(255, 161, 14, 197),
        centerTitle: true,
      ),
      body: Container(
        color: Color.fromARGB(255, 217, 101, 255), // เปลี่ยนพื้นหลังของหน้า
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Color.fromARGB(255, 247, 25, 229)),
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        'คิว',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18, // ขนาดตัวอักษรในหัวตาราง
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'ชื่อผู้ใช้',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'สถานะ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'เวลา',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'การชำระเงิน',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                  rows: queueData
                      .asMap()
                      .entries
                      .map(
                        (entry) => DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (entry.key % 2 == 0) {
                              return Colors.grey[100]; // สีพื้นหลังแถวคู่
                            }
                            return null; // แถวคี่ไม่มีสีพื้นหลัง
                          }),
                          cells: <DataCell>[
                            DataCell(
                              Text(
                                (entry.key + 1).toString(),
                                style: const TextStyle(color: Colors.black, fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                entry.value['username'],
                                style: const TextStyle(color: Colors.black, fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                entry.value['status'],
                                style: const TextStyle(color: Colors.black, fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                entry.value['datetime'],
                                style: const TextStyle(color: Colors.black, fontSize: 14),
                              ),
                            ),
                            DataCell(
                              ElevatedButton(
                                onPressed: () {
                                  updateQueueStatus(entry.value['id'], 'ชำระเงินแล้ว');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 186, 24, 255),
                                ),
                                child: const Text(
                                  'ยืนยันการชำระเงิน',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16, // ขนาดตัวอักษรในปุ่ม
                                  ),
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
          ),
        ),
      ),
    );
  }
}
