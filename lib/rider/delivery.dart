import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zzz/rider/delivery_detail.dart';
import '../setting.dart';

class DeliveryPageRider extends StatefulWidget {
  final String username;
  final String datetime;

  DeliveryPageRider({
    required this.username,
    required this.datetime,
  });

  @override
  _DeliveryPageRiderState createState() => _DeliveryPageRiderState();
}

class _DeliveryPageRiderState extends State<DeliveryPageRider> {
  List<dynamic> queueData = [];
  String currentStatus = 'ปรุงเสร็จแล้ว';

  @override
  void initState() {
    super.initState();
    fetchQueueData();
  }

  Future<void> fetchQueueData() async {
    final response = await http
        .get(Uri.parse('http://$ip/restarant_papai/flutter1/delivery.php'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      setState(() {
        queueData = jsonData
            .where((data) =>
                data['delivery_method'] == 'deliverymethod.delivery' &&
                data['status'] !=
                    'ชำระเงินแล้ว') // เพิ่มเงื่อนไขไม่แสดงรายการที่ชำระเงินแล้ว
            .map((data) {
          return {
            ...data,
            'datetime': data['datetime'], // เพิ่มข้อมูล datetime เข้าไปใน map
          };
        }).toList();
      });
    } else {
      throw Exception('ไม่สามารถโหลดข้อมูลจาก API ได้');
    }
  }

  Future<void> updateStatus(String queueId, String status) async {
    if (status == 'ส่งอาหารแล้ว') {
      final queueItem = queueData.firstWhere((item) => item['id'] == queueId);
      if (queueItem['status'] != 'กำลังไปส่ง') {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('ไม่สามารถส่งอาหารได้'),
              content: Text('สถานะยังไม่ใช่ "กำลังไปส่ง"'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('ตกลง'),
                ),
              ],
            );
          },
        );
        return;
      }
    }

    final response = await http.post(
      Uri.parse(
          'http://$ip/restarant_papai/flutter1/queue/update_queue_status.php'),
      body: {
        'id': queueId,
        'status': status,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        // อัปเดตสถานะใน queueData และนำรายการออกถ้าสถานะเป็น "ชำระเงินแล้ว"
        queueData = queueData
            .map((item) {
              if (item['id'] == queueId) {
                return {
                  ...item,
                  'status': status,
                };
              }
              return item;
            })
            .where((item) => item['status'] != 'ชำระเงินแล้ว')
            .toList();

        if (status == 'ชำระเงินแล้ว') {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('การชำระเงินสำเร็จ'),
                content: Text('สถานะอัปเดตเป็น "ชำระเงินแล้ว" เรียบร้อย'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('ตกลง'),
                  ),
                ],
              );
            },
          );
        }
      });
    } else {
      throw Exception('ไม่สามารถอัปเดตสถานะได้');
    }
  }

  void viewDetails(Map<dynamic, dynamic> entry) {
    Map<String, dynamic> typedEntry = Map<String, dynamic>.from(entry);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryDetailPageRider(
          entry: typedEntry,
          username: typedEntry['username'],
          datetime: typedEntry['datetime'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Page'),
      ),
      body: RefreshIndicator(
        onRefresh: fetchQueueData,
        child: ListView.builder(
          itemCount: queueData.length,
          itemBuilder: (BuildContext context, int index) {
            final queueItem = queueData[index];
            final locationId = queueItem['location_id'].toString();

            return ListTile(
              title: Text('Status: ${queueItem['status']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price: ${queueItem['price']}'),
                  Text('Location ID: $locationId'),
                  Text('วันเวลา: ${queueItem['datetime']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (queueItem['status'] == 'ปรุงเสร็จแล้ว') {
                        updateStatus(queueItem['id'], 'กำลังไปส่ง');
                      } else if (queueItem['status'] == 'กำลังไปส่ง') {
                        updateStatus(queueItem['id'], 'ส่งอาหารแล้ว');
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('ไม่สามารถส่งอาหารได้'),
                              content: Text('สถานะยังไม่ใช่ "ปรุงเสร็จแล้ว"'),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('ตกลง'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Text(queueItem['status'] == 'ปรุงเสร็จแล้ว'
                        ? 'กำลังไปส่ง'
                        : 'ส่งอาหาร'),
                  ),
                  SizedBox(width: 2), // เพิ่มระยะห่างระหว่างปุ่ม
                  if (queueItem['status'] == 'ส่งอาหารแล้ว')
                    ElevatedButton(
                      onPressed: () {
                        updateStatus(queueItem['id'], 'ชำระเงินแล้ว');
                      },
                      child: Text('ชำระเงินสด'),
                    ),
                ],
              ),
              onTap: () {
                viewDetails(queueItem);
              },
            );
          },
        ),
      ),
    );
  }
}
