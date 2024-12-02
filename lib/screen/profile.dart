// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zzz/screen/profile_edit.dart';

import '../setting.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  ProfilePage({required this.username});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  Map<String, dynamic>? userData;

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
        setState(() {
          userData = json.decode(response.body);
        });
      } else {
        // Handle API error here
      }
    } catch (e) {
      // Handle connection or other errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    _fetchUserData();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 26, // Font size of the app bar
            color: Colors.black, // Text color of the app bar
          ),
        ),
        backgroundColor: Color.fromARGB(255, 191, 0, 255), // App bar background color
      ),
      body: Container(
        color: Color.fromARGB(255, 228, 129, 255),// Background color of the page
        child: ListView(
          children: [
            Center(
              child: userData != null
                  ? Padding(
                      padding: const EdgeInsets.all(20.0), // Padding for spacing
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'สวัสดีคุณ: ${userData!['user_fname']} ${userData!['user_lname']}',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.black, // Text color
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle: TextStyle(color: Colors.black), // Label color
                              border: OutlineInputBorder(),
                            ),
                            controller: TextEditingController(
                                text: userData!['username']),
                            readOnly: true,
                          ),
                          SizedBox(height: 20),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(),
                            ),
                            controller: TextEditingController(
                                text: userData!['user_email']),
                            readOnly: true,
                          ),
                          SizedBox(height: 20),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(),
                            ),
                            controller: TextEditingController(
                                text: userData!['user_fname']),
                            readOnly: true,
                          ),
                          SizedBox(height: 20),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Lastname',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(),
                            ),
                            controller: TextEditingController(
                                text: userData!['user_lname']),
                            readOnly: true,
                          ),
                          SizedBox(height: 20),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(),
                            ),
                            controller: TextEditingController(
                                text: userData!['user_tel']),
                            readOnly: true,
                          ),
                          // Additional fields can be added here
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfilePage(username: widget.username),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 206, 29, 255), // Button color
                            ),
                            child: Text(
                              'แก้ไข',
                              style: TextStyle(
                                color: Colors.black, // Button text color
                                fontSize: 18, // Font size of the button text
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(), // Loading indicator while fetching data
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
