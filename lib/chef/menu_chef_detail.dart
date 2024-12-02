import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zzz/setting.dart';

import 'editmenuchef.dart';

class FoodMenuChefDetail extends StatefulWidget {
  final dynamic menuItem;

  const FoodMenuChefDetail({Key? key, required this.menuItem}) : super(key: key);

  @override
  _FoodMenuChefDetailState createState() => _FoodMenuChefDetailState();
}

class _FoodMenuChefDetailState extends State<FoodMenuChefDetail> {
  Future<void> popAndRefresh() async {
    // กลับไปยังหน้า FoodMenuChef และโหลดข้อมูลใหม่
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    var menuName = widget.menuItem['menu_name'] ?? '';
    var price = widget.menuItem['menu_price'] ?? '';
    var status = widget.menuItem['menu_status'] ?? '';
    var category = widget.menuItem['menu_category'] ?? '';
    var imageName = widget.menuItem['menu_pics'] ?? '';
    var imagePath = 'http://$ip/restarant_papai/upload/menu/$imageName';

    return Scaffold(
      appBar: AppBar(
        title: Text(menuName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Column(
            children: [
              Image.network(
                imagePath,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              ListTile(
                title: Text(
                  'เมนูอาหาร: $menuName',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'ราคา: $price บาท',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                title: Text(
                  'ประเภท: $category',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                title: Text(
                  'สถานะ: $status',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // เมื่อกดปุ่มแก้ไข
                      _editMenuItem(context);
                    },
                    child: Text(
                      'แก้ไข',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _deleteMenuItem();
                    },
                    child: Text(
                      'ลบ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _editMenuItem(BuildContext context) {
    // นำคุณไปยังหน้าแก้ไขข้อมูลเมนู โดยส่งข้อมูลเมนูไปด้วย
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditMenuChefPage(menuItem: widget.menuItem),
      ),
    ).then((value) {
      // เมื่อกลับจากหน้าแก้ไข เรียก popAndRefresh() เพื่อโหลดข้อมูลเมนูใหม่
      if (value == true) {
        popAndRefresh();
      }
    });
  }

  void _deleteMenuItem() async {
    // สร้าง URL สำหรับลบเมนูอาหาร
    var deleteUrl = 'http://$ip/restarant_papai/flutter1/menu_delete.php';

    // ส่งคำร้องขอลบเมนูอาหารไปยังเซิร์ฟเวอร์
    var response = await http.post(
      Uri.parse(deleteUrl),
      body: {'menu_id': widget.menuItem['menu_id'].toString()},
    );

    // ตรวจสอบคำตอบจากเซิร์ฟเวอร์
    if (response.statusCode == 200) {
      // ถ้าลบสำเร็จ
      // แสดง Alert Dialog และโหลดข้อมูลเมนูใหม่เมื่อปิด Alert Dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('ลบสำเร็จ'),
            content: Text('ลบเมนูเรียบร้อยแล้ว'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ปิด Alert Dialog
                  popAndRefresh(); // โหลดข้อมูลเมนูใหม่
                },
                child: Text('ปิด'),
              ),
            ],
          );
        },
      );
    } else {
      // ถ้าเกิดข้อผิดพลาดในการลบ
      // แสดง Alert Dialog แจ้งเตือนข้อผิดพลาด
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('เกิดข้อผิดพลาด'),
            content: Text('ไม่สามารถลบเมนูได้ในขณะนี้'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ปิด Alert Dialog
                },
                child: Text('ปิด'),
              ),
            ],
          );
        },
      );
    }
  }
}
