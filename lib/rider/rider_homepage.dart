import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zzz/login.dart';
import 'package:zzz/rider/delivery.dart';
import 'package:zzz/rider/resetpassword.dart';
import 'package:zzz/rider/rider_about.dart';
import 'package:zzz/rider/rider_profile.dart';
import 'package:zzz/rider/rider_promotion.dart';

import '../setting.dart';
import 'rider_address.dart';

class FoodMenuItem {
  final String name;
  final double price;
  final String menu_pics;

  FoodMenuItem({
    required this.name,
    required this.price,
    required this.menu_pics,
  });

  factory FoodMenuItem.fromJson(Map<String, dynamic> json) {
    return FoodMenuItem(
      name: json['menu_name'],
      price: json['menu_price'] is String
          ? double.tryParse(json['menu_price']) ?? 0.0
          : (json['menu_price'] is int
              ? (json['menu_price'] as int).toDouble()
              : (json['menu_price'] as double)),
      menu_pics: json['menu_pics'],
    );
  }
}

class PromotionPage {
  final String promotion_name;
  final String code;
  final String discount_amount;
  final String image_url;

  PromotionPage({
    required this.promotion_name,
    required this.code,
    required this.discount_amount,
    required this.image_url,
  });

  factory PromotionPage.fromJson(Map<String, dynamic> json) {
    return PromotionPage(
      promotion_name: json['promotion_name'],
      code: json['code'],
      discount_amount: json['discount_amount'],
      image_url: json['image_url'],
    );
  }

  String get imageUrl => image_url;
}

class HomePageRider extends StatefulWidget {
  final String username;
  final int locationId;

  HomePageRider({required this.username, required this.locationId});

  @override
  _HomePageRiderState createState() => _HomePageRiderState();
}

class _HomePageRiderState extends State<HomePageRider> {
  late final PageController pageController;
  dynamic userData;
  late Future<List<PromotionPage>> futurePromotions;
  late Future<List<FoodMenuItem>> futureFoodMenu;

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
    futurePromotions = fetchPromotions();
    futureFoodMenu = fetchFoodMenu();
  }

  Future<List<PromotionPage>> fetchPromotions() async {
    final response = await http.get(
        Uri.parse('http://$ip/restarant_papai/flutter1/promotion_page.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PromotionPage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load promotions');
    }
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

  Future<List<FoodMenuItem>> fetchFoodMenu() async {
    final response = await http.get(
      Uri.parse('http://$ip/restarant_papai/flutter1/foodmenu_page.php'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) {
        try {
          return FoodMenuItem.fromJson(json);
        } catch (e) {
          print('Error parsing FoodMenuItem: $e');
          // สามารถจัดการกับข้อผิดพลาดในการแปลง JSON ได้ที่นี่
          throw Exception('Error parsing FoodMenuItem: $e');
        }
      }).toList();
    } else {
      // สามารถจัดการกับข้อผิดพลาดที่เกิดขึ้นในการร้องขอ HTTP ได้ที่นี่
      throw Exception('Failed to load food menu');
    }
  }

  Future<void> _refreshPromotions() async {
    setState(() {});
    futurePromotions = fetchPromotions();
    futureFoodMenu = fetchFoodMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              width: 100,
            ),
            Container(
              child: Image.asset(
                'assets/logo.png',
                width: 70,
                height: 70,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
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
        actions: [
          Container(
            width: 70,
            child: Text(widget.username,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis),
          ),
          Padding(
            padding: EdgeInsets.only(right: 13.0),
            child: Icon(
              Icons.account_circle_sharp,
              size: 40,
              color: Colors.black,
            ),
          ),
        ],
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
                    'Welcome Rider : ${widget.username}',
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
                  return ProfilePageRider(username: widget.username);
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment_late_outlined),
              title: Text('เกี่ยวกับร้าน'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AboutRider();
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.location_pin),
              title: Text('ที่อยู่ของฉัน'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return UserAddressRider(username: widget.username);
                }));
              },
            ),
            ElevatedButton(
              onPressed: () {
                {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ResetPasswordPage(
                      username: widget.username,
                    );
                  })); // เรียกฟังก์ชัน _logout() เมื่อผู้ใช้กดปุ่มออกจากระบบ
                } // เรียกฟังก์ชัน _logout() เมื่อผู้ใช้กดปุ่มออกจากระบบ
              },
              child: Text('แก้ไขรหัสผ่าน'),
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
        child: RefreshIndicator(
          onRefresh: _refreshPromotions,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Container(
                  height: 200,
                  child: FutureBuilder<List<PromotionPage>>(
                    future: futurePromotions,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Container(
                          margin: const EdgeInsets.only(
                            left: 50,
                            right: 50,
                            top: 20,
                            bottom: 20,
                          ),
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.orangeAccent,
                            image: DecorationImage(
                              image: NetworkImage(
                                  'http://$ip/restarant_papai/image/logopage.png'), // Path to gg.jpg
                              fit: BoxFit.cover,
                            ),
                          ),
                        ); //Text('Error: ${snapshot.error}');
                      } else {
                        final promotions = snapshot.data;
                        return PageView.builder(
                          controller: pageController,
                          itemBuilder: (_, index) {
                            final promotion = promotions![index];
                            return Container(
                              margin: const EdgeInsets.only(
                                left: 50,
                                right: 50,
                                top: 20,
                                bottom: 20,
                              ),
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.orangeAccent,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    'http://$ip/restarant_papai/upload/promotion/${promotion.imageUrl}',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                          itemCount: promotions?.length ?? 0,
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
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
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return PromotionRider();
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
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return AboutRider();
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
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return DeliveryPageRider(
                                            username: widget.username,
                                            datetime: '',
                                          );
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
                              Text('Delivery'),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    FutureBuilder<List<FoodMenuItem>>(
                      future: futureFoodMenu,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('No food menu available.');
                        } else {
                          final foodMenuItems = snapshot.data!;
                          return Container(
                            height: 600,
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // 2 คอลัมน์ใน GridView
                                crossAxisSpacing:
                                    20.0, // ระยะห่างระหว่างคอลัมน์
                                mainAxisSpacing: 8.0, // ระยะห่างระหว่างแถว
                              ),
                              itemBuilder: (_, index) {
                                final foodMenuItem = foodMenuItems[index];
                                final imageUrl =
                                    'http://$ip/restarant_papai/upload/menu/${foodMenuItem.menu_pics}';
                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(''), // แสดงชื่ออาหาร
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                height: 300,
                                                width: 300,
                                              ), // แสดงรูปภาพ
                                              SizedBox(height: 8),
                                              Text(foodMenuItem.name),
                                              SizedBox(height: 8),
                                              Text(
                                                  'ราคา: ${foodMenuItem.price} บาท'), // แสดงราคา
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('ปิด'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.all(8.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    elevation: 5,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        height: 125,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              itemCount: foodMenuItems.length,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
