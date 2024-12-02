// ignore_for_file: prefer_const_constructors, avoid_print, sized_box_for_whitespace

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zzz/setting.dart';

class PromotionRider extends StatefulWidget {
  const PromotionRider({Key? key}) : super(key: key);

  @override
  State<PromotionRider> createState() => _PromotionRiderState();
}

class _PromotionRiderState extends State<PromotionRider> {
  Future<List<dynamic>> getContactData() async {
    var url =
        'http://$ip/restarant_papai/flutter1/view_promotion.php';
    var response = await http.get(Uri.parse(url));
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Promotion',textAlign: TextAlign.center),
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
      ),
      body: FutureBuilder<List<dynamic>>(
        future: getContactData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    List<dynamic> list = snapshot.data!;
                    var imageName = list[index]['promotion_picture'];
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
                                  '${list[index]['promotion_name']}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'ส่วนลด: ${list[index]['discount_amount']}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'โค้ดส่วนลด: ${list[index]['code']}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
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
                );
        },
      ),
    );
  }
}
