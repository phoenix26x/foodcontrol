// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_final_fields, file_names, prefer_if_null_operators, unused_local_variable, unused_import, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:zzz/rider/rider_homepage.dart';
import 'package:zzz/screen/cart.dart';
import 'package:zzz/screen/homepage.dart';

import '../setting.dart';

class FoodMenuPageRider extends StatefulWidget {
  final String username;
  final int locationId;

  FoodMenuPageRider({required this.username, required this.locationId});

  @override
  _FoodMenuPageRiderState createState() => _FoodMenuPageRiderState();
}

class _FoodMenuPageRiderState extends State<FoodMenuPageRider> {
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
      _filteredData = _allData;
    });
  }

  void filterData(String category) {
    setState(() {
      if (category == 'กับข้าว') {
        _filteredData =
            _allData.where((item) => item['menu_category'] == 'กับข้าว').toList();
      } else if (category == 'เครื่องดื่ม') {
        _filteredData = _allData
            .where((item) => item['menu_category'] == 'เครื่องดื่ม')
            .toList();
      } else {
        _filteredData = _allData;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Foods and Drinks'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CartPage(
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
                      builder: (context) => HomePageRider(
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
                hintText: 'ค้นหาสินค้า',
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
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  textStyle: TextStyle(fontSize: 12),
                ),
                child: Text('อาหารจานเดียว'),
              ),
              ElevatedButton(
                onPressed: () {
                  filterData('กับข้าว');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  textStyle: TextStyle(fontSize: 12),
                ),
                child: Text('กับข้าว'),
              ),
              ElevatedButton(
                onPressed: () {
                  filterData('เครื่องดื่ม');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  textStyle: TextStyle(fontSize: 12),
                ),
                child: Text('เครื่องดื่ม'),
              ),
              ElevatedButton(
                onPressed: () {
                  filterData('ทั้งหมด');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  textStyle: TextStyle(fontSize: 12),
                ),
                child: Text('ทั้งหมด'),
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

                  return GestureDetector(
                    onTap: () {
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
                    },
                    child: Card(
                      color: Colors.orange,
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.network(
                              imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(menuName),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text('$price'),
                          ),
                        ],
                      ),
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

  Future<void> addToCart() async {
    var url =
        'http://$ip/restarant_papai/flutter1/addtocart.php'; // เปลี่ยนเป็น URL ของฐานข้อมูล
    var data = {
      'username': widget.username,
      'menu_name': widget.menu['menu_name'],
      'menu_price': widget.menu['menu_price'],
      'menu_pics': widget.menu['menu_pics'],
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            widget.imagePath,
            fit: BoxFit.cover,
          ),
          Text(
              'ชื่อเมนู: ${widget.menu['menu_name']}'), // ใช้ getter จาก widget.menu
          Text(
              'ราคา: ${widget.menu['menu_price']}'), // ใช้ getter จาก widget.menu
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: decreaseQuantity,
            ),
            Text(
              '$quantity',
              style: TextStyle(fontSize: 18),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: increaseQuantity,
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            addToCart();
          },
          child: Text('เพิ่มลงรถเข็น'),
        ),
      ],
    );
  }
}
