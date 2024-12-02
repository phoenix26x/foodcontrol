import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../setting.dart';
import 'admin_insert_promotion.dart';

class PromotionAdmin extends StatefulWidget {
  const PromotionAdmin({Key? key}) : super(key: key);

  @override
  State<PromotionAdmin> createState() => _PromotionAdminState();
}

class _PromotionAdminState extends State<PromotionAdmin> {
  Future<List<dynamic>> getPromotionData() async {
    var url = 'http://$ip/restarant_papai/flutter1/view_promotion.php';
    var response = await http.get(Uri.parse(url));
    return json.decode(response.body);
  }

  Future<void> _refreshPromotions() async {
    setState(() {}); // อัพเดทข้อมูลโปรโมชั่นใหม่
  }

  Future<void> _deletePromotion(String promotionId) async {
    final intId = int.tryParse(promotionId);
    if (intId != null) {
      final url = 'http://$ip/restarant_papai/flutter1/delete_promotion.php';
      final response = await http.post(Uri.parse(url), body: {
        'promotion_id': intId.toString(),
      });

      if (response.statusCode == 200) {
        print('ลบโปรโมชั่นสำเร็จ');
        _refreshPromotions(); // อัพเดทข้อมูลหลังจากลบโปรโมชั่น
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบโปรโมชั่นสำเร็จ'),
          ),
        );
      } else {
        print('ลบโปรโมชั่นไม่สำเร็จ: ${response.reasonPhrase}');
      }
    } else {
      print('promotionId ไม่ใช่ตัวเลขที่ถูกต้อง');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('โปรโมชั่น', textAlign: TextAlign.center),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back,
                size: 35,
              ),
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InsertPromotionPage(),
                ),
              );
              _refreshPromotions(); // เมื่อกลับมาจากหน้า InsertPromotionPage ให้อัพเดทข้อมูล
            },
            icon: Icon(
              Icons.add,
              size: 35,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: getPromotionData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return RefreshIndicator(
            onRefresh: _refreshPromotions, // อัพเดทข้อมูลเมื่อ pull-to-refresh
            child: snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      List<dynamic> promotionList = snapshot.data!;
                      var imageName = promotionList[index]['promotion_picture'];
                      var imagePath =
                          'http://$ip/restarant_papai/upload/promotion/$imageName';

                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.network(
                                    imagePath,
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${promotionList[index]['promotion_name']}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'ส่วนลด: ${promotionList[index]['discount_amount']}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'โค้ดส่วนลด: ${promotionList[index]['code']}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await _deletePromotion(
                                          promotionList[index]['promotion_id']);
                                      Navigator.of(context)
                                          .pop(); // ปิด AlertDialog
                                    },
                                    child: Text('ลบ'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0)),
                            child: Image.network(
                              imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          );
        },
      ),
    );
  }
}
