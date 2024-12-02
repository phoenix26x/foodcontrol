// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_final_fields, file_names, prefer_if_null_operators, unused_local_variable, unused_import, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:zzz/screen/cart.dart';
import 'package:zzz/user/user_cart.dart';
import 'package:zzz/user/user_homepage.dart';

import '../setting.dart';

class FoodMenuPageUser extends StatefulWidget {
  final String username;
  final int locationId;

  FoodMenuPageUser({required this.username, required this.locationId});

  @override
  _FoodMenuPageState createState() => _FoodMenuPageState();
}

class _FoodMenuPageState extends State<FoodMenuPageUser> {
  Future<List<dynamic>> getContactData() async {
    var url = 'http://$ip/restarant_papai/flutter1/foodmenu.php';
    var response = await http.get(Uri.parse(url));
    var data = json.decode(response.body);
    return data != null ? data : [];
  }

  List<dynamic> _allData = [];
  List<dynamic> _filteredData = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    _allData = await getContactData();
    setState(() {
      _filteredData = _allData
          .where((item) =>
              item['menu_status'] == 'มี' || item['menu_status'] == 'หมด')
          .toList();
    });
  }

  void filterData(String category) {
    setState(() {
      if (category == 'อาหารจานเดียว') {
        _filteredData = _allData
            .where((item) => item['menu_category'] == 'อาหารจานเดียว')
            .toList();
      } else if (category == 'กับข้าว') {
        _filteredData = _allData
            .where((item) => item['menu_category'] == 'กับข้าว')
            .toList();
      } else if (category == 'เครื่องดื่ม') {
        _filteredData = _allData
            .where((item) => item['menu_category'] == 'เครื่องดื่ม')
            .toList();
      } else {
        _filteredData = _allData
            .where((item) =>
                item['menu_status'] == 'มี' || item['menu_status'] == 'หมด')
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Foods and Drinks',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CartPageUser(
                          username: widget.username,
                          locationId: widget.locationId,
                        )),
              );
            },
            icon: Icon(
              Icons.shopping_cart,
              size: 35,
            ),
          ),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePageUser(
                            username: widget.username,
                            locationId: widget.locationId,
                          )),
                );
              },
              icon: Icon(
                Icons.arrow_back,
                size: 35,
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (keyword) {
                setState(() {
                  if (keyword.isEmpty) {
                    _filteredData = _allData;
                  } else {
                    _filteredData = _allData
                        .where((item) => item['menu_name']
                            .toLowerCase()
                            .contains(keyword.toLowerCase()))
                        .toList();
                  }
                });
              },
              decoration: InputDecoration(
                hintText: '',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  filterData('อาหารจานเดียว');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  textStyle: TextStyle(fontSize: 12, color: Colors.black),
                ),
                child: Text('อาหารจานเดียว',
                    style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                onPressed: () {
                  filterData('กับข้าว');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  textStyle: TextStyle(fontSize: 12, color: Colors.black),
                ),
                child: Text('กับข้าว', style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                onPressed: () {
                  filterData('เครื่องดื่ม');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  textStyle: TextStyle(fontSize: 12, color: Colors.black),
                ),
                child:
                    Text('เครื่องดื่ม', style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                onPressed: () {
                  filterData('ทั้งหมด');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  textStyle: TextStyle(fontSize: 12, color: Colors.black),
                ),
                child: Text('ทั้งหมด', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: _filteredData.length,
                itemBuilder: (context, index) {
                  var menuName = _filteredData[index]['menu_name'] ?? '';
                  var price = _filteredData[index]['menu_price'] ?? '';
                  var imageName = _filteredData[index]['menu_pics'] ?? '';
                  var imagePath =
                      'http://$ip/restarant_papai/upload/menu/$imageName';
                  var status = _filteredData[index]['menu_status'] ?? '';

                  return GestureDetector(
                    onTap: () {
                      if (status != 'หมด') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return QuantityDialog(
                              menu: _filteredData[
                                  index], // ส่งเมนูไปใน QuantityDialog
                              username: widget
                                  .username, // ส่ง username ไปใน QuantityDialog
                              imagePath: imagePath,
                            );
                          },
                        );
                      }
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            color: Colors.white70,
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15.0),
                                      topRight: Radius.circular(15.0),
                                    ),
                                    child: Image.network(
                                      imagePath,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    menuName,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    '$price',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        status == 'หมด'
                            ? Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(50.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'หมด',
                                      style: TextStyle(
                                        fontFamily: 'K2D',
                                        fontSize: 55,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuantityDialog extends StatefulWidget {
  final dynamic menu;
  final String username;
  final String imagePath;

  QuantityDialog(
      {required this.menu, required this.username, required this.imagePath});

  @override
  _QuantityDialogState createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<QuantityDialog> {
  int quantity = 1;
  TextEditingController detailController = TextEditingController();

  void increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decreaseQuantity() {
    if (quantity > 0) {
      setState(() {
        quantity--;
      });
    }
  }

  Future<void> addToCart(String txt) async {
    var url =
        'http://$ip/restarant_papai/flutter1/addtocart.php'; // เปลี่ยนเป็น URL ของฐานข้อมูล
    var data = {
      'username': widget.username,
      'menu_name': widget.menu['menu_name'],
      'menu_price': widget.menu['menu_price'],
      'menu_pics': widget.menu['menu_pics'],
      'detail': txt,
      'quantity': quantity.toString(),
    };
    var response = await http.post(Uri.parse(url), body: data);

    if (response.statusCode == 200) {
      Navigator.pop(context); // ปิดกล่องโต้ตอบ
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.imagePath,
              fit: BoxFit.cover,
            ),
            Text(
              'ชื่อเมนู: ${widget.menu['menu_name']}',
              style: TextStyle(color: Colors.black),
            ),
            Text(
              'ราคา: ${widget.menu['menu_price']}',
              style: TextStyle(color: Colors.black),
            ),
            Text(
              'สถานะ: ${widget.menu['menu_status']}',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 10),
            TextField(
              controller: detailController,
              decoration: InputDecoration(
                hintText: 'รายละเอียด:',
                border: OutlineInputBorder(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: decreaseQuantity,
                ),
                Text(
                  '$quantity',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: increaseQuantity,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            addToCart(detailController.text);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, // สีพื้นหลังของปุ่ม
            textStyle: TextStyle(color: Colors.black), // สีของตัวหนังสือ
          ),
          child: Text('เพิ่มลงรถเข็น', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
