// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zzz/setting.dart';

class EditProfilePageChef extends StatefulWidget {
  final String username;
  const EditProfilePageChef({super.key, required this.username});

  @override
  _EditProfilePageChefState createState() => _EditProfilePageChefState();
}

class _EditProfilePageChefState extends State<EditProfilePageChef> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _telController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      var response = await http.get(
        Uri.parse(
            'http://$ip/restarant_papai/flutter1/profile.php?username=${widget.username}'),
      );

      if (response.statusCode == 200) {
        var userData = json.decode(response.body);
        setState(() {
          _emailController.text = userData['user_email'];
          _fnameController.text = userData['user_fname'];
          _lnameController.text = userData['user_lname'];
          _telController.text = userData['user_tel'];
        });
      } else {
        // Handle API error here
      }
    } catch (e) {
      // Handle connection or other errors here
    }
  }

  Future<void> _updateUserData(
    String userEmail,
    String userfname,
    String userlname,
    String usertel,
  ) async {
    try {
      var response = await http.put(
        Uri.parse(
            'http://$ip/restarant_papai/flutter1/profile.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': widget.username,
          'user_email': userEmail,
          'user_fname': userfname,
          'user_lname': userlname,
          'user_tel': usertel,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData['message']);
        // เมื่ออัปเดตข้อมูลสำเร็จ คุณสามารถทำอะไรต่อได้ตามต้องการ
      } else {
        print('Failed to update user data');
        // มีข้อผิดพลาดในการอัปเดตข้อมูล
      }
    } catch (e) {
      // Handle connection or other errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แก้ไขโปรไฟล์')
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                controller: _fnameController,
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Lastname',
                  border: OutlineInputBorder(),
                ),
                controller: _lnameController,
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                controller: _telController,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _updateUserData(
                    _emailController.text,
                    _fnameController.text,
                    _lnameController.text,
                    _telController.text,
                  ); // ดึงข้อมูลที่แก้ไขจาก TextField
                  Navigator.pop(context); // กลับไปหน้า ProfilePage
                },
                child: const Text('บันทึกการแก้ไข'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
