import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zzz/admin/Income_Viewpage.dart';
import 'package:zzz/admin/admin_about.dart';
import 'package:zzz/admin/admin_avg_rating.dart';
import 'package:zzz/admin/admin_profile.dart';
import 'package:zzz/admin/admin_queue.dart';
import 'package:zzz/admin/check_slip.dart';
import 'package:zzz/admin/food_menu_chef.dart';
import 'package:zzz/login.dart';
import 'package:zzz/admin/resetpassword.dart';

import '../screen/manage_user.dart';
import '../setting.dart';
import 'admin_address.dart';
import 'admin_promotion.dart';
import 'admin_update_queue.dart';

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

class HomePageAdmin extends StatefulWidget {
  final String username;
  final int locationId;

  HomePageAdmin({required this.username, required this.locationId});

  @override
  _HomePageAdminState createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  late final PageController pageController;
  dynamic userData;
  late Future<List<PromotionPage>> futurePromotions;
  late Future<List<FoodMenuItem>> futureFoodMenu;

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage(
                locationId: widget.locationId,
              )),
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
          userData = userData;
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
        title: Image.asset(
          'assets/6.png',
          width: 70,
          height: 70,
        ),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
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
        child: Container(
          color: const Color.fromARGB(
              255, 0, 0, 0), // Set your desired background color here
          child: ListView(
            padding: EdgeInsets.only(),
            children: <Widget>[
              Container(
                height: 130,
                child: UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.purple,
                  ),
                  accountName: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome : ${widget.username}',
                        style: TextStyle(color: Colors.white, fontSize: 27),
                      ),
                    ],
                  ),
                  accountEmail: Text(''),
                ),
              ),
              ListTile(
                leading:
                    Icon(Icons.home, color: Color.fromARGB(255, 217, 93, 255)),
                title: Text(
                  'หน้าหลัก',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255)),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.people,
                    color: Color.fromARGB(255, 217, 93, 255)),
                title: Text(
                  'โปรไฟล์',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255)),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ProfilePageAdmin(username: widget.username);
                  }));
                },
              ),
              ListTile(
                leading: Icon(Icons.discount_outlined,
                    color: Color.fromARGB(255, 217, 93, 255)),
                title: Text(
                  'จัดการโปรโมชั่น',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255)),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PromotionAdmin();
                  }));
                },
              ),
              ListTile(
                leading: Icon(Icons.food_bank_rounded,
                    color: Color.fromARGB(255, 217, 93, 255)),
                title: Text(
                  'จัดการเมนูอาหาร',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255)),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return FoodMenuAdmin(
                      username: widget.username,
                    );
                  }));
                },
              ),
              ListTile(
                leading: Icon(Icons.people_alt_outlined,
                    color: Color.fromARGB(255, 217, 93, 255)),
                title: Text(
                  'จัดการผู้ใช้',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255)),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return UserListPage();
                  }));
                },
              ),
              ListTile(
                leading: Icon(Icons.attach_money,
                    color: Color.fromARGB(255, 217, 93, 255)),
                title: Text(
                  'ยอดรวมรายได้',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255)),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return IncomeViewPage();
                  }));
                },
              ),
              ListTile(
                leading: Icon(Icons.star_border,
                    color: Color.fromARGB(255, 217, 93, 255)),
                title: Text(
                  'คะแนนร้าน',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255)),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return avgRatingAdmin(
                      username: widget.username,
                    );
                  }));
                },
              ),
              ListTile(
                leading: Icon(Icons.assignment_late_outlined,
                    color: Color.fromARGB(255, 217, 93, 255)),
                title: Text(
                  'เกี่ยวกับร้าน',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255)),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AboutAdmin();
                  }));
                },
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ResetPasswordPage(
                      username: widget.username,
                    );
                  }));
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Color.fromARGB(255, 123, 0, 168), // สีตัวหนังสือ
                ),
                child: Text('แก้ไขรหัสผ่าน'),
              ),
              ElevatedButton(
                onPressed: () {
                  _logout(); // เรียกฟังก์ชัน _logout() เมื่อผู้ใช้กดปุ่มออกจากระบบ
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Color.fromARGB(255, 123, 0, 168), // สีตัวหนังสือ
                ),
                child: Text('ออกจากระบบ'),
              ),
            ],
          ),
        ),
      ),

      // ข่าวประชาสัมพันธ์ -----------------------------------------------------------------------------------------------
      body: Container(
          color: Color.fromARGB(
              255, 0, 0, 0), // Change this to your desired background color
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshPromotions,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      child: FutureBuilder<List<PromotionPage>>(
                        future: futurePromotions,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                                color: Color.fromARGB(255, 105, 0, 167),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      'http://$ip/restarant_papai/image/logopage.png'), // Path to gg.jpg
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ); //Text('Error: ${snapshot.error}');
                          } else {
                            final promotions = snapshot.data;

                            // Check if promotions are empty
                            if (promotions == null || promotions.isEmpty) {
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
                                  color: Color.fromARGB(255, 131, 0, 167),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                        'assets/images/gg.jpg'), // Path to gg.jpg
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }

                            return PageView.builder(
                              controller: pageController,
                              itemBuilder: (_, index) {
                                final promotion = promotions[index];
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
                                    color: Color.fromARGB(255, 131, 0, 167),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        'http://$ip/restarant_papai/upload/promotion/${promotion.imageUrl}',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                              itemCount: promotions.length,
                            );
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                        children: [
                          // ตัวเลือก
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 70,
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 177, 0,
                                            241), // สีพื้นหลังของ Container
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: EdgeInsets.all(0),
                                      child: Center(
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return QueuePageAdmin();
                                            }));
                                          },
                                          icon: Icon(
                                            Icons.people_alt,
                                            size: 35,
                                            color: Color.fromARGB(
                                                255, 0, 0, 0), // สีของไอคอน
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'คิว',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 250, 91,
                                            255), // สีของตัวหนังสือ
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 70,
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 177, 0,
                                            241), // สีพื้นหลังของ Container
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: EdgeInsets.all(0),
                                      child: Center(
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return UpdateQueuePageAdmin();
                                            }));
                                          },
                                          icon: Icon(
                                            Icons.show_chart,
                                            size: 35,
                                            color: Color.fromARGB(
                                                255, 0, 0, 0), // สีของไอคอน
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'อัปเดทคิว',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 250, 91,
                                            255), // สีของตัวหนังสือ
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 70,
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 177, 0,
                                            241), // สีพื้นหลังของ Container
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: EdgeInsets.all(0),
                                      child: Center(
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return CheckSlibPage();
                                            }));
                                          },
                                          icon: Icon(
                                            Icons.money_outlined,
                                            size: 35,
                                            color: Color.fromARGB(
                                                255, 0, 0, 0), // สีของไอคอน
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'ตรวจสอบการชำระ',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 250, 91,
                                            255), // สีของตัวหนังสือ
                                      ),
                                    ),
                                  ],
                                ),
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
                              final foodMenuItems = snapshot.data;
                              return Container(
                                height: 600,
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
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
                                              backgroundColor: const Color.fromARGB(255, 0, 0, 0), // เปลี่ยนสีพื้นหลังที่นี่
                                              title: Text(
                                                '', // แสดงชื่ออาหาร
                                                style: TextStyle(
                                                    color: Color.fromARGB(255, 250, 91,
                                            255)), // เปลี่ยนสีตัวหนังสือที่นี่
                                              ),
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
                                                  Text(
                                                    foodMenuItem.name,
                                                    style: TextStyle(
                                                        color: Color.fromARGB(255, 250, 91,
                                            255)), // เปลี่ยนสีตัวหนังสือที่นี่
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'ราคา: ${foodMenuItem.price} บาท',
                                                    style: TextStyle(
                                                        color:Color.fromARGB(255, 250, 91,
                                            255)), // เปลี่ยนสีตัวหนังสือที่นี่
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    'ปิด',
                                                    style: TextStyle(
                                                        color: Color.fromARGB(255, 250, 91,
                                            255)), // เปลี่ยนสีตัวหนังสือที่นี่
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Card(
                                        margin: const EdgeInsets.all(8.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        elevation: 5,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            height: 125,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: foodMenuItems!.length,
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
          )),
    );
  }
}
