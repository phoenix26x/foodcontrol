// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously, prefer_const_constructors

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:zzz/setting.dart';

import 'food_menu_chef.dart';

void main() => runApp(const MaterialApp(home: AddFoodMenuPageChef()));

class AddFoodMenuPageChef extends StatefulWidget {
  const AddFoodMenuPageChef({super.key});

  @override
  _AddFoodMenuPageChefState createState() => _AddFoodMenuPageChefState();
}

class _AddFoodMenuPageChefState extends State<AddFoodMenuPageChef> {
  File? _image;
  final picker = ImagePicker();
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String? selectedCategory;
  final List<String> categories = [ 'เครื่องดื่ม', 'อาหารจานเดียว','กับข้าว'];

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

  Future uploadImage() async {
  if (_image == null) {
    print('No image selected.');
    return;
  }

  final uri = Uri.parse(
      'http://$ip/restarant_papai/flutter1/insert_menu.php');
  final request = http.MultipartRequest('POST', uri);

  request.fields['name'] = nameController.text;
  request.fields['price'] = priceController.text;
  request.fields['category'] = selectedCategory!;

  request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

  final response = await request.send();
  if (response.statusCode == 200) {
    // เมื่อเพิ่มเมนูอาหารสำเร็จ
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('เพิ่มเมนูอาหารสำเร็จ'),
        content: Text('เมนูอาหารถูกเพิ่มเรียบร้อยแล้ว!'),
        actions: [
          CupertinoDialogAction(
            child: Text('ตกลง'),
            onPressed: () {
              Navigator.of(context).pop(); // ปิด alert
              Navigator.of(context).pop(); // ปิดหน้าปัจจุบัน (AddFoodMenuPageChef)
            },
          ),
        ],
      ),
    );
    
    // อัพเดทรายการเมนูอาหารในหน้า FoodMenuChef
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => FoodMenuChef(username: '',),
      ),
    );
  } else {
    print('Failed to upload image: ${response.reasonPhrase}');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มเมนูอาหาร', textAlign: TextAlign.center),
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
                    child: const Text('เลือกรูปภาพ'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[200],
                    ),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่ออาหาร',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[200],
                    ),
                    child: TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'ราคา',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[200],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'ประเภทอาหาร',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    onPressed: uploadImage,
                    child: const Text('เพิ่มเมนูอาหาร'),
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
