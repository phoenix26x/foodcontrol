// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, prefer_final_fields, avoid_print, unnecessary_string_interpolations

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

import '../setting.dart';

class About extends StatelessWidget {
  About({super.key});

  Future<List<dynamic>> getContactData() async {
    var url = 'http://$ip/restarant_papai/flutter1/ViewAbout.php';
    var response = await http.get(Uri.parse(url));
    return json.decode(response.body);
  }

  final facebookUrl = Uri.parse('https://www.facebook.com/Wongnai');
  final instagarmUrl = Uri.parse('https://www.instagram.com/wongnai/?hl=en');
  String _phone = '0909609814';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            size: 35,
          ),
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
                      return Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.email),
                            title: Text(
                                list[index]['email'] ?? 'No email available'),
                            onTap: () {
                              // Add code here for handling email tap
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.phone),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('$_phone'),
                                ElevatedButton(
                                  onPressed: () async {
                                    final url =
                                        Uri(scheme: 'tel', path: _phone);
                                    if (await canLaunchUrl(url)) {
                                      launchUrl(url);
                                    }
                                  },
                                  child: const Text('โทรหาร้าน'),
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.facebook),
                            title: Row(
                              children: [
                                Link(
                                  uri: facebookUrl,
                                  target: LinkTarget.defaultTarget,
                                  builder: (context, openLink) => TextButton(
                                    onPressed: openLink,
                                    child: Text(
                                      'Facebook - ร้านอาหารตามคิว',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.camera_alt_outlined),
                            title: Row(
                              children: [
                                Link(
                                  uri: instagarmUrl,
                                  target: LinkTarget.defaultTarget,
                                  builder: (context, openLink) => TextButton(
                                    onPressed: openLink,
                                    child: Text(
                                      'Instagram - ร้านอาหารตามคิว',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ExpansionTile(
                            leading: Icon(Icons.access_time),
                            title: Text('เวลาเปิดร้านอาหาร'),
                            children: [
                              ListTile(
                                title: Text('วันจันทร์'),
                                subtitle: Text('เปิด 09:00 - 20:00 น.'),
                              ),
                              ListTile(
                                title: Text('วันอังคาร'),
                                subtitle: Text('เปิด 09:00 - 21:00 น.'),
                              ),
                              ListTile(
                                title: Text('วันพุธ'),
                                subtitle: Text('เปิด 09:00 - 21:00 น.'),
                              ),
                              ListTile(
                                title: Text('วันพฤหัสบดี'),
                                subtitle: Text('เปิด 09:00 - 21:00 น.'),
                              ),
                              ListTile(
                                title: Text('วันศุกร์'),
                                subtitle: Text('เปิด 09:00 - 21:00 น.'),
                              ),
                              ListTile(
                                title: Text('วันเสาร์'),
                                subtitle: Text(
                                  'ปิด',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text('วันอาทิตย์'),
                                subtitle: Text(
                                  'ปิด',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              // ทำซ้ำตามวันในสัปดาห์ที่คุณต้องการแสดง
                            ],
                          ),
                        ],
                      );
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          }),
    );
  }
}
