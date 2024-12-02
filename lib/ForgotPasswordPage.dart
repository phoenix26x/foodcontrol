import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zzz/ResetPasswordPage.dart'; // Make sure the path is correct
import 'package:zzz/setting.dart'; // Make sure the path is correct

class ForgotPasswordPage extends StatefulWidget {
  final int locationId;

  ForgotPasswordPage({required this.locationId});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _resetCodeController = TextEditingController();
  String _message = '';
  String _resetCode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter your email to reset password:',
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _resetCodeController,
                decoration: InputDecoration(
                  labelText: 'Reset Code',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendResetCode,
              child: Text('Send Reset Code'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validateResetCode,
              child: Text('Confirm Reset Code'),
            ),
            SizedBox(height: 20),
            Text(_message),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _sendResetCode() async {
    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
    final service_id = "service_xoufjq8";
    final template_id = "template_0itkmjh";
    final user_id = "rVEnxgXmLw8jDHq4A";
    String to_email = _emailController.text;
    _resetCode = _generateResetCode();
    var response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost', 
        'Content-Type': 'application/json'
      },
      body: json.encode({
        "service_id": service_id,
        "template_id": template_id,
        "user_id": user_id,
        "template_params": {
          "to_email": to_email,
          "reset_code": _resetCode,
        }
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _message = 'Reset code sent to $to_email';
      });
    } else {
      setState(() {
        _message = 'Failed to send reset code';
      });
    }
  }

  String _generateResetCode() {
    String chars = '0123456789';
    String randomCode = '';
    const codeLength = 6;

    Random random = Random();

    for (int i = 0; i < codeLength; i++) {
      int randomIndex = random.nextInt(chars.length);
      randomCode += chars[randomIndex];
    }

    return randomCode;
  }

  void _validateResetCode() {
    String enteredCode = _resetCodeController.text;
    if (enteredCode == _resetCode) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(locationId: widget.locationId),
        ),
      );
    } else {
      setState(() {
        _message = 'Invalid reset code';
      });
    }
  }
}
