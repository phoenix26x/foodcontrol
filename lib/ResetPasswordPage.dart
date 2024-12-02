import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:zzz/setting.dart'; // Make sure you have the correct import for your settings file
import 'package:zzz/login.dart';

class ResetPasswordPage extends StatefulWidget {
  final int locationId;

  ResetPasswordPage({required this.locationId});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  Future<void> _resetPassword() async {
    final email = _emailController.text;
    final newPassword = _passwordController.text;

    if (newPassword.length < 8) {
      _setMessage('Password must be at least 8 characters');
      return;
    }

    final String url =
        'http://$ip/restarant_papai/flutter1/login/reset_password.php';
    print('URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'newPassword': newPassword,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      LoginPage(locationId: widget.locationId)),
            );
        if (responseJson.containsKey('message')) {
          _setMessage(responseJson['message']);
          if (responseJson['message'] == 'Password reset successful') {
            
          } else {
            _setMessage('Password reset failed. Please try again.');
          }
        } else if (responseJson.containsKey('error')) {
          _setMessage(responseJson['error']);
        } else {
          _setMessage('Unexpected response from the server.');
        }
      } else {
        _setMessage('Error: ${response.statusCode}');
      }
    } catch (e) {
      _setMessage('Error: $e');
    }
  }

  void _setMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildTextField(_emailController, 'Email'),
              _buildTextField(_passwordController, 'New Password',
                  obscureText: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetPassword,
                child: Text('Reset Password'),
              ),
              SizedBox(height: 20),
              Text(
                _message,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      obscureText: obscureText,
    );
  }
}
