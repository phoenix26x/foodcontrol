import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zzz/login.dart';
import 'package:zzz/setting.dart';
import 'package:flutter/services.dart';

class register extends StatefulWidget {
  final int locationId;

  register({required this.locationId});

  @override
  _registerState createState() => _registerState();
}

class _registerState extends State<register> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController telController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("ลงทะเบียนไม่สำเร็จ"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(errorMessage),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("ตกลง"),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("ลงทะเบียนสำเร็จ"),
          content: Text("คุณได้ลงทะเบียนสำเร็จแล้ว"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // กลับไปยังหน้า Login
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LoginPage(locationId: widget.locationId),
                  ),
                );
              },
              child: Text("ตกลง"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ลงทะเบียน'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset('assets/logo.png'), // แทนที่ path ด้วยที่เหมาะสม
              SizedBox(height: 16.0),
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อ',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'นามสกุล',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: telController,
                maxLength: 10, // Limit the input to 10 characters
                keyboardType: TextInputType
                    .phone, // Set keyboard type to phone for numeric keypad
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly // Accept only digits
                ],
                decoration: InputDecoration(
                  labelText: 'หมายเลขโทรศัพท์',
                  border: OutlineInputBorder(),
                  counterText: "", // Hide the character count
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'อีเมล',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'ยืนยันรหัสผ่าน',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _registerUser();
                },
                child: Text('ลงทะเบียน'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _registerUser() async {
    String url = "http://$ip/restarant_papai/flutter1/login/register.php";

    // ตรวจสอบความตรงกันของรหัสผ่านและยืนยันรหัสผ่าน
    if (passwordController.text != confirmPasswordController.text) {
      _showErrorDialog("รหัสผ่านไม่ตรงกัน");
      return;
    }

    // เพิ่มเงื่อนไขตรวจสอบความยาวของรหัสผ่าน
    if (passwordController.text.length < 8) {
      _showErrorDialog("รหัสผ่านต้องมีความยาวอย่างน้อย 8 ตัว");
      return;
    }

    Map<String, String> data = {
      'user_fname': firstNameController.text,
      'user_lname': lastNameController.text,
      'user_tel': telController.text,
      'user_email': emailController.text,
      'user_type': 'User',
      'username': usernameController.text,
      'password': passwordController.text,
      'user_date': DateTime.now().toString(),
    };

    var response = await http.post(Uri.parse(url), body: data);
    if (response.statusCode == 200) {
      String result = response.body;
      if (result == 'Success') {
        // แสดงแจ้งเตือนว่าการลงทะเบียนสำเร็จ
        _showSuccessDialog();
      } else {
        // มีข้อผิดพลาดเกิดขึ้นในการลงทะเบียน
        _showErrorDialog(result);
      }
    } else {
      // เกิดข้อผิดพลาดในการส่งข้อมูลไปยังเซิร์ฟเวอร์
      _showErrorDialog(
          "เกิดข้อผิดพลาดขณะพยายามลงทะเบียน โปรดลองอีกครั้งในภายหลัง");
    }
  }
}
