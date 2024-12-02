// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors, unnecessary_string_interpolations, unused_local_variable, unnecessary_brace_in_string_interps, non_constant_identifier_names, use_build_context_synchronously, unused_import

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zzz/login.dart';
import 'package:zzz/screen/about.dart';
import 'package:zzz/screen/avg_rating.dart';
import 'package:zzz/screen/cart.dart';
import 'package:zzz/screen/foodmenu.dart';
import 'package:zzz/screen/history.dart';
import 'package:zzz/screen/profile.dart';
import 'package:zzz/screen/promotion.dart';
import 'package:zzz/screen/queue.dart';
import 'package:zzz/screen/update_queue.dart';

import '../setting.dart';
import 'address.dart';

class HomePage extends StatefulWidget {
  final String username;
  final int locationId;

  HomePage({required this.username, required this.locationId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController pageController;
  dynamic userData;

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false); // ปรับค่า isLoggedIn เป็น false
    // เพิ่มโค้ดอื่น ๆ ตามความเหมาะสม เช่น เคลียร์ข้อมูลที่เก็บไว้ในแอปพลิเคชัน

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage(
                locationId: widget.locationId,
              )), // นำผู้ใช้กลับไปหน้า Login
    );
  }

  @override
  void initState() {
    pageController = PageController();
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
        Map<String, dynamic> userData = json.decode(response.body);

        setState(() {
          userData = userData; // กำหนดค่าให้กับตัวแปร userData ใน State
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
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo.png',
          width: 70,
          height: 70,
        ),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CartPage(
                  username: widget.username,
                  locationId: widget.locationId,
                );
              }));
            },
            icon: Icon(
              Icons.shopping_cart,
              size: 35,
            ),
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: Icon(
              Icons.menu,
              size: 35,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.only(),
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
              ),
              accountName: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome ${widget.username}',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              accountEmail: Text(''),
            ),

            ListTile(
              leading: Icon(Icons.home),
              title: Text('หน้าหลัก'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('โปรไฟล์'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ProfilePage(username: widget.username);
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.star_border),
              title: Text('ให้คะแนนร้าน'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return avgRating(
                    username: widget.username,
                  );
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment_late_outlined),
              title: Text('เกี่ยวกับร้าน'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return About();
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.location_pin),
              title: Text('ที่อยู่ของฉัน'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return UserAddress(username: widget.username);
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.history_outlined),
              title: Text('ประวัติการสั่งซื้อ'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return History(
                    username: widget.username,
                  );
                }));
              },
            ),
            ElevatedButton(
              onPressed: () {
                _logout(); // เรียกฟังก์ชัน _logout() เมื่อผู้ใช้กดปุ่มออกจากระบบ
              },
              child: Text('ออกจากระบบ'),
            )

            // เพิ่มเมนูอื่นๆ ตามต้องการ
          ],
        ),
      ),
      // ข่าวประชาสัมพันธ์ -----------------------------------------------------------------------------------------------
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: pageController,
                itemBuilder: (_, index) {
                  return AnimatedBuilder(
                    animation: pageController,
                    builder: (ctx, child) {
                      return child!;
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                          left: 50, right: 50, top: 20, bottom: 20),
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.orangeAccent,
                      ),
                    ),
                  );
                },
                itemCount: 5,
              ),
            ),

            // ปิดข่าวประชาสัมพันธ์ -------------------------------------------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children: [
                  // ตัวเลือก -------------------------------------------------------------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 198, 190, 190),
                                borderRadius: BorderRadius.circular(50)),
                            padding: EdgeInsets.all(0),
                            child: Center(
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return Promotion();
                                    }));
                                  },
                                  icon: Icon(
                                    Icons.menu_open,
                                    size: 35,
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text('โปรโมชั่น'),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 198, 190, 190),
                                borderRadius: BorderRadius.circular(50)),
                            padding: EdgeInsets.all(0),
                            child: Center(
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return FoodMenuPage(
                                        username: widget.username,
                                        locationId: widget.locationId,
                                      );
                                    }));
                                  },
                                  icon: Icon(
                                    Icons.food_bank,
                                    size: 35,
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text('สั่งอาหารs'),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 198, 190, 190),
                                borderRadius: BorderRadius.circular(50)),
                            padding: EdgeInsets.all(0),
                            child: Center(
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return QueuePage();
                                    }));
                                  },
                                  icon: Icon(
                                    Icons.people_alt,
                                    size: 35,
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text('คิว'),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 198, 190, 190),
                                borderRadius: BorderRadius.circular(50)),
                            padding: EdgeInsets.all(0),
                            child: Center(
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return About();
                                    }));
                                  },
                                  icon: Icon(
                                    Icons.assignment_late_rounded,
                                    size: 35,
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text('เกี่ยวกับร้าน'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // -------------------------------------------------------------------------------------------------------------------------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 198, 190, 190),
                                borderRadius: BorderRadius.circular(50)),
                            padding: EdgeInsets.all(0),
                            child: Center(
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return UpdateQueuePage();
                                    }));
                                  },
                                  icon: Icon(
                                    Icons.show_chart,
                                    size: 35,
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text('อัปเดทคิว'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
