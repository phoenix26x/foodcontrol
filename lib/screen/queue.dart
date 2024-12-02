import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../setting.dart';

class QueuePage extends StatefulWidget {
  @override
  _QueuePageState createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  List<Map<String, dynamic>> queueData = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromAPI();
  }

  Future<void> fetchDataFromAPI() async {
    final response = await http.get(
        Uri.parse('http://$ip/restarant_papai/flutter1/queue/queue.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // กรองข้อมูลเฉพาะที่มี status เป็น "รอคิว" หรือ "กำลังปรุงอาหาร"
      final filteredData = data.where((entry) =>
          entry['status'] == 'รอคิว' || entry['status'] == 'กำลังปรุงอาหาร');

      setState(() {
        queueData = filteredData.toList().cast<Map<String, dynamic>>();
      });
    } else {
      // จัดการข้อผิดพลาดในการดึงข้อมูล
    }
  }

  Future<void> _handleRefresh() async {
    // ทำการรีเฟรชข้อมูลที่คุณต้องการที่นี่
    await fetchDataFromAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('คิวการบริการ'),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(label: Text('คิว')),
                  DataColumn(label: Text('ชื่อผู้ใช้')),
                  DataColumn(label: Text('สถานะ')),
                  DataColumn(label: Text('เวลา')),
                ],
                rows: queueData
                    .asMap()
                    .entries
                    .map(
                      (entry) => DataRow(
                        cells: <DataCell>[
                          DataCell(Text((entry.key + 1).toString())),
                          DataCell(Text(entry.value['username'])),
                          DataCell(Text(entry.value['status'])),
                          DataCell(Text(entry.value['datetime'])),
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