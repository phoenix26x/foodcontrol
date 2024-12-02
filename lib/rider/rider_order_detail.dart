// ignore_for_file: unused_local_variable, library_private_types_in_public_api, unnecessary_string_interpolations, avoid_unnecessary_containers

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zzz/setting.dart';

class OrderDetailsPageRider extends StatefulWidget {
  final String username;
  final String datetime;

  const OrderDetailsPageRider({
    Key? key,
    required this.username,
    required this.datetime,
  }) : super(key: key);

  @override
  _OrderDetailsPageRiderState createState() => _OrderDetailsPageRiderState();
}

class _OrderDetailsPageRiderState extends State<OrderDetailsPageRider> {
  List<Map<String, dynamic>> queueData = [];
  List<dynamic> data = [];
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    fetchDataFromAPI();
    fetchQueueData(widget.username, widget.datetime);
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

  Future<void> fetchQueueData(String username, String datetime) async {
    final apiUrl =
        'http://$ip/restarant_papai/flutter1/test.php?username=$username&datetime=$datetime';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        queueData = jsonData.cast<Map<String, dynamic>>();
      });
    } else {
      throw Exception('Failed to load queue data');
    }
  }

  Future<void> fetchDataFromAPI() async {
    final response = await http.get(
      Uri.parse(
        'http://$ip/restarant_papai/flutter1/order_datail.php?username=${widget.username}&datetime=${widget.datetime}',
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);

        totalAmount = data.fold(0.0, (sum, food) {
          final menuPrice = double.tryParse(food['menu_price']) ?? 0.0;
          final quantity = int.tryParse(food['quantity']) ?? 0;
          return sum + (menuPrice * quantity);
        });
      });
    } else {
      // จัดการข้อผิดพลาดในการดึงข้อมูล
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดอาหาร',textAlign: TextAlign.center),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Column(
              children: [
                for (var food in data)
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
                        Text(
                          '${getDeliveryMethodText(food['delivery_method'])}',
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${food['menu_price']} บาท',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'รวมค่าอาหาร:',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5,),
                      for (var item in queueData)
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ส่วนลด:',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 5,),
                            Text(
                              'รวมทั้งหมด:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$totalAmount บาท',style: const TextStyle(fontSize: 16),),
                      const SizedBox(height: 5,),
                      for (var item in queueData)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${item['discount_price']} บาท',style: const TextStyle(fontSize: 16),),
                            const SizedBox(height: 5,),
                            Text(
                              '${item['price']} บาท',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
