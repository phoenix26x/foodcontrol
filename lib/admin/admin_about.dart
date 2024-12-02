import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:zzz/setting.dart';
import 'editdataadmin.dart';

class AboutAdmin extends StatefulWidget {
  AboutAdmin({Key? key});

  @override
  _AboutAdminState createState() => _AboutAdminState();
}

class _AboutAdminState extends State<AboutAdmin> {
  Future<List<Map<String, dynamic>>> getContactData() async {
    var url = 'http://$ip/restarant_papai/flutter1/ViewAbout.php';
    var response = await http.get(Uri.parse(url));
    List<dynamic> responseData = json.decode(response.body);
    List<Map<String, dynamic>> mappedData =
        responseData.cast<Map<String, dynamic>>();
    return mappedData;
  }

  final facebookUrl = Uri.parse('https://www.facebook.com/Wongnai');
  final instagramUrl = Uri.parse('https://www.instagram.com/wongnai/?hl=en');
  String _phone = '0909609814';

  void _editData(BuildContext context) async {
    Map<String, dynamic>? updatedData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditDataAdmin()),
    );
    if (updatedData != null) {
      setState(() {
        _phone = updatedData['tel'];
      });
    } 
  }

  Widget _buildOpeningHoursForm() {
  TextEditingController _mondayController = TextEditingController();
  TextEditingController _tuesdayController = TextEditingController();
  TextEditingController _wednesdayController = TextEditingController();
  TextEditingController _thursdayController = TextEditingController();
  TextEditingController _fridayController = TextEditingController();
  TextEditingController _saturdayController = TextEditingController();
  TextEditingController _sundayController = TextEditingController();

  return ExpansionTile(
    leading: const Icon(Icons.access_time),
    title: Text('เวลาเปิดร้านอาหาร'),
    iconColor: Color.fromARGB(255, 245, 183, 0),
    children: [
      ListTile(
        title: Text('วันจันทร์'),
        subtitle: TextFormField(
          controller: _mondayController,
          decoration: InputDecoration(
            hintText: 'เช่น 09:00 - 20:00 น.',
          ),
        ),
      ),
      ListTile(
        title: Text('วันอังคาร'),
        subtitle: TextFormField(
          controller: _tuesdayController,
          decoration: InputDecoration(
            hintText: 'เช่น 09:00 - 21:00 น.',
          ),
        ),
      ),
      ListTile(
        title: Text('วันพุธ'),
        subtitle: TextFormField(
          controller: _wednesdayController,
          decoration: InputDecoration(
            hintText: 'เช่น 09:00 - 21:00 น.',
          ),
        ),
      ),
      ListTile(
        title: Text('วันพฤหัสบดี'),
        subtitle: TextFormField(
          controller: _thursdayController,
          decoration: InputDecoration(
            hintText: 'เช่น 09:00 - 21:00 น.',
          ),
        ),
      ),
      ListTile(
        title: Text('วันศุกร์'),
        subtitle: TextFormField(
          controller: _fridayController,
          decoration: InputDecoration(
            hintText: 'เช่น 09:00 - 21:00 น.',
          ),
        ),
      ),
      ListTile(
        title: Text('วันเสาร์'),
        subtitle: TextFormField(
          controller: _saturdayController,
          decoration: InputDecoration(
            hintText: 'ปิด',
            hintStyle: TextStyle(color: Colors.red),
          ),
        ),
      ),
      ListTile(
        title: Text('วันอาทิตย์'),
        subtitle: TextFormField(
          controller: _sundayController,
          decoration: InputDecoration(
            hintText: 'ปิด',
            hintStyle: TextStyle(color: Colors.red),
          ),
        ),
      ),
      ElevatedButton(
        onPressed: () {
          // นำค่าที่ผู้ใช้กรอกไปใช้งานต่อได้ตามต้องการ
          String mondayOpeningHours = _mondayController.text;
          String tuesdayOpeningHours = _tuesdayController.text;
          String wednesdayOpeningHours = _wednesdayController.text;
          String thursdayOpeningHours = _thursdayController.text;
          String fridayOpeningHours = _fridayController.text;
          String saturdayOpeningHours = _saturdayController.text;
          String sundayOpeningHours = _sundayController.text;

          // ทำการบันทึกข้อมูลลงในฐานข้อมูล
          saveOpeningHoursToDatabase(
            mondayOpeningHours,
            tuesdayOpeningHours,
            wednesdayOpeningHours,
            thursdayOpeningHours,
            fridayOpeningHours,
            saturdayOpeningHours,
            sundayOpeningHours,
          );
        },
        child: Text('บันทึก'),
      ),
    ],
  );
}

void saveOpeningHoursToDatabase(
  String monday,
  String tuesday,
  String wednesday,
  String thursday,
  String friday,
  String saturday,
  String sunday,
) async {
  // ข้อมูลเซิร์ฟเวอร์ของฐานข้อมูล
  final String apiUrl = 'http://$ip/restarant_papai/flutter1/SaveOpeningHours.php';

  // ข้อมูลที่จะส่งไปบันทึกลงในฐานข้อมูล
  final Map<String, dynamic> data = {
    'monday': monday,
    'tuesday': tuesday,
    'wednesday': wednesday,
    'thursday': thursday,
    'friday': friday,
    'saturday': saturday,
    'sunday': sunday,
  };

  // ส่งข้อมูลไปยังเซิร์ฟเวอร์เพื่อบันทึกลงในฐานข้อมูล
  final response = await http.post(Uri.parse(apiUrl), body: data);

  // ตรวจสอบว่าการส่งข้อมูลสำเร็จหรือไม่
  if (response.statusCode == 200) {
    print('บันทึกข้อมูลเวลาเปิดร้านสำเร็จ');
  } else {
    print('เกิดข้อผิดพลาดในการบันทึกข้อมูล: ${response.statusCode}');
  }
}

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
          icon: const Icon(
            Icons.arrow_back,
            size: 35,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _editData(context);
            },
            icon: const Icon(
              Icons.edit,
              size: 35,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getContactData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            var dataList = snapshot.data!;
            var data = dataList.first;
            return ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(data['email'] ?? 'No email available'),
                  onTap: () {
                    // Add code here for handling email tap
                  },
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_phone),
                      ElevatedButton(
                        onPressed: () async {
                          final url = Uri(scheme: 'tel', path: _phone);
                          if (await canLaunch(url.toString())) {
                            launch(url.toString());
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
                      TextButton(
                        onPressed: () {
                          launch(facebookUrl.toString());
                        },
                        child: Text(
                          'Facebook - ร้านอาหารตามคิว',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueAccent,
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
                      TextButton(
                        onPressed: () {
                          launch(instagramUrl.toString());
                        },
                        child: Text(
                          'Instagram - ร้านอาหารตามคิว',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildOpeningHoursForm(),
              ],
            );
          }
        },
      ),
    );
  }
}
