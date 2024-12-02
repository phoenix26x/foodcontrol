import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zzz/setting.dart';

class EditDataAdmin extends StatefulWidget {
  @override
  _EditDataAdminState createState() => _EditDataAdminState();
}

class _EditDataAdminState extends State<EditDataAdmin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController igController = TextEditingController();

  List<String> openingHours = [
    'เปิด 09:00 - 20:00 น.', // วันจันทร์
    'เปิด 09:00 - 21:00 น.', // วันอังคาร
    'เปิด 09:00 - 21:00 น.', // วันพุธ
    'เปิด 09:00 - 21:00 น.', // วันพฤหัสบดี
    'เปิด 09:00 - 21:00 น.', // วันศุกร์
    'ปิด', // วันเสาร์
    'ปิด', // วันอาทิตย์
  ];

  Future<void> _getDataFromServer() async {
    var url = Uri.parse(
        'http://$ip/restarant_papai/flutter1/update_admin.php?username=admin');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        emailController.text = data['email'];
        phoneController.text = data['tel'];
        facebookController.text = data['facebook'];
        igController.text = data['ig'];
      });
    } else {
      print('ไม่สามารถโหลดข้อมูลได้');
    }
  }

  Future<void> _updateUserData() async {
    var url = Uri.parse('http://$ip/restarant_papai/flutter1/update_admin.php');
    var response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'tel': phoneController.text,
        'email': emailController.text,
        'facebook': facebookController.text,
        'ig': igController.text,
        'openingHours': jsonEncode(openingHours),
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['redirect'] != null) {
        Navigator.pop(context, {
          'tel': phoneController.text,
          'email': emailController.text,
          'facebook': facebookController.text,
          'ig': igController.text,
          'openingHours': openingHours,
        });
      } else {
        debugPrint(data['message']);
      }
    } else {
      debugPrint('ไม่สามารถอัปเดตข้อมูลผู้ใช้ได้');
    }
  }

  @override
  void initState() {
    super.initState();
    _getDataFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูล'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'อีเมล:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'อีเมล',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'เบอร์โทรศัพท์:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  hintText: 'เบอร์โทรศัพท์',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Facebook:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: facebookController,
                decoration: const InputDecoration(
                  hintText: 'Facebook',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Instagram (IG):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: igController,
                decoration: const InputDecoration(
                  hintText: 'Instagram',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _updateUserData();
                },
                child: const Text('บันทึก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
