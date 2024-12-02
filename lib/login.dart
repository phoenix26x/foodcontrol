// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zzz/ForgotPasswordPage.dart';
import 'package:zzz/register.dart';
import 'package:zzz/rider/rider_homepage.dart';
import 'package:zzz/setting.dart';
import 'package:zzz/user/user_homepage.dart';

import 'admin/admin_homepage.dart';
import 'chef/chef_homepage.dart';

class LoginPage extends StatefulWidget {
  final int locationId;

  LoginPage({required this.locationId});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<bool> checkLogin(String username, String password) async {
    var response = await http.post(
      Uri.parse('http://$ip/restarant_papai/flutter1/login/login.php'),
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      // ตรวจสอบความตรงกันของ username และ password กับฐานข้อมูล
      if (response.body == 'success') {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      // ตรวจสอบว่าช่อง username และ password ไม่ว่าง
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Failed'),
          content: Text('กรุณากรอก Usernam และ Password ให้ครบ'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    bool isLoggedIn = await checkLogin(username, password);

    if (isLoggedIn) {
      // เรียก API เพื่อรับข้อมูลผู้ใช้และ user_type จากฐานข้อมูล
      var response = await http.post(
        Uri.parse(
            'http://$ip/restarant_papai/flutter1/login/get_user_type.php'),
        body: {'username': username},
      );

      if (response.statusCode == 200) {
        String userType = response.body;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username);
        prefs.setBool('isLoggedIn', true);
        prefs.setString(
            'userType', userType); // เพิ่ม user_type ลงใน SharedPreferences

        // ดำเนินการนำทางไปยังหน้าที่เหมาะสมตาม user_type
        switch (userType) {
          case 'User':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePageUser(
                      username: username, locationId: widget.locationId)),
            );
            break;
          case 'Chef':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePageChef(
                      username: username, locationId: widget.locationId)),
            );
            break;
          case 'Admin':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePageAdmin(
                      username: username, locationId: widget.locationId)),
            );
            break;
          case 'Rider':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePageRider(
                      username: username, locationId: widget.locationId)),
            );
            break;
          default:
            // หากไม่ระบุ user_type ให้แสดงข้อความข้อผิดพลาด
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Login Failed'),
                content: Text('ข้อมูล user_type ไม่ถูกต้อง'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
        }
      } else {
        // เกิดข้อผิดพลาดในการรับข้อมูล user_type
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Login Failed'),
            content: Text('เกิดข้อผิดพลาดในการรับข้อมูล user_type'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Failed'),
          content: Text(' username หรือ password ไม่ถูกต้อง'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/3.png',
                  width: 400,
                  height: 400,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                  ),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Password'),
                  ),
                ),
                 SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 255, 255, 255), backgroundColor: Color.fromARGB(255, 113, 5, 171), // Text color
                  ),
                  child: Text('Login'),
                ),
                SizedBox(height: 10.0),
                TextButton(
                  onPressed: () {
                    // เมื่อปุ่ม "สมัครสมาชิก" ถูกคลิก
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => register(
                                locationId: widget.locationId,
                              )),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.black, // Button color
                  ),
                  child: Text('สมัครสมาชิก'),
                ),
                SizedBox(height: 10.0),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ForgotPasswordPage(locationId: widget.locationId),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.black, // Button color
                  ),
                  child: Text('ลืมรหัสผ่าน'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
