import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../setting.dart';

class EditMenuChefPage extends StatefulWidget {
  final dynamic menuItem;

  const EditMenuChefPage({Key? key, required this.menuItem}) : super(key: key);

  @override
  _EditMenuChefPageState createState() => _EditMenuChefPageState();
}

class _EditMenuChefPageState extends State<EditMenuChefPage> {
  TextEditingController _menuNameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  String _selectedCategory = ''; // เพิ่มตัวแปรสำหรับประเภทอาหาร
  String _status = ''; // เพิ่มตัวแปรสำหรับสถานะ

  @override
  void initState() {
    super.initState();
    _menuNameController.text = widget.menuItem['menu_name'] ?? '';
    _priceController.text = widget.menuItem['menu_price']?.toString() ?? '';
    _selectedCategory = widget.menuItem['menu_category'] ?? ''; // กำหนดค่าเริ่มต้นสำหรับ _selectedCategory
    _status = widget.menuItem['menu_status'] ?? ''; // กำหนดค่าเริ่มต้นสำหรับ _status
  }

  Future<void> _updateMenuItem() async {
    final apiUrl =
        Uri.parse('http://$ip/restarant_papai/flutter1/update_menu.php');

    final formData = http.MultipartRequest('POST', apiUrl);
    
    // เช็คว่าประเภทอาหารและสถานะไม่ใช่สตริงว่าง
    if (_selectedCategory.isEmpty || _status.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกประเภทอาหารและสถานะ'),
        ),
      );
      return; // ออกจากฟังก์ชันถ้าข้อมูลไม่ถูกต้อง
    }

    formData.fields.addAll({
      'menu_id': widget.menuItem['menu_id'],
      'menu_name': _menuNameController.text,
      'menu_price': _priceController.text,
      'menu_category': _selectedCategory,
      'menu_status': _status,
    });

    try {
      final response = await formData.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        if (jsonResponse['message'] == 'อัปเดตข้อมูลเรียบร้อยแล้ว') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('อัปเดตข้อมูลสำเร็จ'),
            ),
          );
          Navigator.pop(context, true); // กลับไปยังหน้า FoodMenuChef และโหลดข้อมูลใหม่
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('อัปเดตข้อมูลล้มเหลว'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ API'),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขข้อมูลเมนูอาหาร'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // เมื่อปุ่ม "เพิ่มเมนูอาหาร" ถูกคลิก
              // ให้นำทางไปยังหน้าเพิ่มเมนูอาหาร (สร้างหน้าเพิ่มเมนูอาหารเอง)
            },
          ),
        ],
      ),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _menuNameController,
                decoration: InputDecoration(labelText: 'ชื่อเมนูอาหาร'), // อัพเดทเป็น labelText
              ),SizedBox(height: 10,),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'ราคา (บาท)'), // อัพเดทเป็น labelText
              ),SizedBox(height: 10,),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                items: <String>['อาหารจานเดียว','กับข้าว', 'เครื่องดื่ม']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'ประเภทอาหาร', // อัพเดทเป็น labelText
                  border: OutlineInputBorder(), // เพิ่ม border
                ),
              ),
              DropdownButton<String>(
                value: _status,
                onChanged: (String? newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
                items: <String>['มี', 'หมด']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _updateMenuItem();
                },
                child: const Text('บันทึกการแก้ไข'),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
