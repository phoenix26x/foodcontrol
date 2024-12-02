import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../setting.dart';

class QueuePageAdmin extends StatefulWidget {
  @override
  _QueuePageAdminState createState() => _QueuePageAdminState();
}

class _QueuePageAdminState extends State<QueuePageAdmin> {
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
          entry['status'] == 'รอคิว' || entry['status'] == 'กำลังปรุงอาหาร');

      setState(() {
        queueData = filteredData.toList().cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _handleRefresh() async {
    await fetchDataFromAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'คิวการบริการ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22, // ขนาดตัวหนังสือของ AppBar
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 135, 0, 150),
      ),
      backgroundColor: Color.fromARGB(255, 215, 114, 255),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                    Color.fromARGB(255, 219, 25, 174)),
                dataRowColor:
                    MaterialStateProperty.all(Colors.white),
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'คิว',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18, // ขนาดตัวหนังสือของหัวข้อ
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
                      'เวลา',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      '',
                      style: TextStyle(
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
                        cells: <DataCell>[
                          DataCell(Text(
                            (entry.key + 1).toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16, // ขนาดตัวหนังสือของข้อมูล
                            ),
                          )),
                          DataCell(Text(
                            entry.value['username'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          )),
                          DataCell(Text(
                            entry.value['status'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          )),
                          DataCell(Text(
                            entry.value['datetime'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          )),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
