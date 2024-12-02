import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../setting.dart';

void main() => runApp(const MaterialApp(home: AddFoodMenuPage()));

class AddFoodMenuPage extends StatefulWidget {
  const AddFoodMenuPage({super.key});

  @override
  _AddFoodMenuPageState createState() => _AddFoodMenuPageState();
}

class _AddFoodMenuPageState extends State<AddFoodMenuPage> {
  File? _image;
  final picker = ImagePicker();
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String? selectedCategory;
  final List<String> categories = ['อาหาร', 'เครื่องดื่ม'];

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
        'http://$ip/restarant_papai/flutter1/insert_menu.php'); // เปลี่ยน YOUR_SERVER_URL เป็น URL ของเซิร์ฟเวอร์ PHP ของคุณ
    final request = http.MultipartRequest('POST', uri);

    request.fields['name'] = nameController.text;
    request.fields['price'] = priceController.text;
    request.fields['category'] = selectedCategory!;

    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      print('Image uploaded successfully.');
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
                    child: const Text('อัปโหลดรูปภาพและบันทึกข้อมูล'),
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
