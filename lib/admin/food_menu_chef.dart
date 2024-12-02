import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zzz/setting.dart';

import 'insert_menu_Admin.dart';
import 'menu_Admin_detail.dart';

class FoodMenuAdmin extends StatefulWidget {
  final String username;

  const FoodMenuAdmin({Key? key, required this.username}) : super(key: key);

  @override
  _FoodMenuAdminState createState() => _FoodMenuAdminState();
}

class _FoodMenuAdminState extends State<FoodMenuAdmin> {
  List<dynamic> _menuData = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMenuData();
  }

  Future<void> _fetchMenuData() async {
    try {
      var response = await http.get(
        Uri.parse('http://$ip/restarant_papai/flutter1/foodmenu.php'),
      );

      if (response.statusCode == 200) {
        List<dynamic> menuData = json.decode(response.body);

        setState(() {
          _menuData = menuData;
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('รายการเมนูอาหาร'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'มี'),
              Tab(text: 'หมด'),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (query) {
                        // Call _filterMenuData method here
                      },
                      decoration: const InputDecoration(
                        hintText: 'ค้นหาเมนูอาหาร',
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildMenuListView(_menuData
                        .where((menu) => menu['menu_status'] == 'มี')
                        .toList()),
                    _buildMenuListView(_menuData
                        .where((menu) => menu['menu_status'] == 'หมด')
                        .toList()),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AddFoodMenuPageAdmin();
                  }));
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuListView(List<dynamic> menuData) {
    return ListView.builder(
      itemCount: menuData.length,
      itemBuilder: (context, index) {
        var menuName = menuData[index]['menu_name'] ?? '';
        var price = menuData[index]['menu_price'] ?? '';
        var imageName = menuData[index]['menu_pics'] ?? '';
        var imagePath = 'http://$ip/restarant_papai/upload/menu/$imageName';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FoodMenuAdminDetail(menuItem: menuData[index]),
              ),
            ).then((value) {
              // เมื่อกลับจากหน้า FoodMenuChefDetail
              if (value == true) {
                _fetchMenuData(); // ดึงข้อมูลเมนูใหม่
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.white,
            ),
            child: ListTile(
              leading: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(imagePath),
                  ),
                ),
              ),
              title: Text(menuName),
              subtitle: Text('Price: $price'),
            ),
          ),
        );
      },
    );
  }
}
