import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:zzz/setting.dart';

class InsertPromotionPage extends StatefulWidget {
  const InsertPromotionPage({Key? key}) : super(key: key);

  @override
  _InsertPromotionPageState createState() => _InsertPromotionPageState();
}

class _InsertPromotionPageState extends State<InsertPromotionPage> {
  File? _image;
  final picker = ImagePicker();
  TextEditingController promotionNameController = TextEditingController();
  TextEditingController discountAmountController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  DateTime? _selectedDate; // New variable to store selected date

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future insertPromotion() async {
    if (_image == null) {
      print('No image selected.');
      return;
    }

    if (_selectedDate == null) {
      print('No date selected.');
      return;
    }

    final uri =
        Uri.parse('http://$ip/restarant_papai/flutter1/insert_promotion.php');
    final request = http.MultipartRequest('POST', uri);

    request.fields['promotion_name'] = promotionNameController.text;
    request.fields['discount_amount'] = discountAmountController.text;
    request.fields['user_id'] = userIdController.text;
    request.fields['code'] = codeController.text;
    request.fields['date'] = _selectedDate!.toString(); // Send selected date

    request.files.add(
        await http.MultipartFile.fromPath('promotion_picture', _image!.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      print('Promotion inserted successfully.');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('เพิ่มโปรโมชั่นสำเร็จ'),
            content: Text('เพิ่มโปรโมชั่นลงในระบบเรียบร้อยแล้ว'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ปิด AlertDialog
                  Navigator.pop(context); // กลับไปหน้า PromotionAdmin
                },
                child: Text('ปิด'),
              ),
            ],
          );
        },
      );
    } else {
      print('Failed to insert promotion: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มโปรโมชัน', textAlign: TextAlign.center),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _image == null
                      ? const Text('ยังไม่ได้เลือกรูปภาพ.')
                      : Image.file(_image!),
                  ElevatedButton(
                    onPressed: getImage,
                    child: const Text('เลือกรูปภาพโปรโมชัน'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(_selectedDate == null
                      ? 'ยังไม่ได้เลือกวันที่'
                      : 'วันที่: ${_selectedDate!.toString()}'), // Display selected date
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('เลือกวันที่'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[200],
                    ),
                    child: TextField(
                      controller: promotionNameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อโปรโมชัน',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[200],
                    ),
                    child: TextField(
                      controller: discountAmountController,
                      decoration: const InputDecoration(
                        labelText: 'จำนวนส่วนลด',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[200],
                    ),
                    child: TextField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: 'โค้ด',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    onPressed: insertPromotion,
                    child: const Text('บันทึกโปรโมชัน'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
