// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api, use_build_context_synchronously, unused_local_variable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../setting.dart';

class User {
  final String user_id;
  final String username;
  final String user_fname;
  final String user_lname;
  final String user_tel;
  final String user_email;
  final String user_type;

  User({
    required this.user_id,
    required this.username,
    required this.user_fname,
    required this.user_lname,
    required this.user_tel,
    required this.user_email,
    required this.user_type,
  });
}

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late List<User> users = [];
  late List<User> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(
        Uri.parse('http://$ip/restarant_papai/flutter1/select_user.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<User> fetchedUsers = data.map((user) {
        return User(
          user_id: user['user_id'],
          username: user['username'],
          user_fname: user['user_fname'],
          user_lname: user['user_lname'],
          user_tel: user['user_tel'],
          user_email: user['user_email'],
          user_type: user['user_type'],
        );
      }).toList();

      setState(() {
        users = fetchedUsers;
        filteredUsers = fetchedUsers; // เริ่มต้นด้วยการแสดงทั้งหมด
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  void filterUsers(String keyword) {
    final filtered = users.where((user) {
      // ค้นหา username หรือชื่อ-นามสกุล
      return user.username.toLowerCase().contains(keyword.toLowerCase()) ||
          '${user.user_fname} ${user.user_type}'
              .toLowerCase()
              .contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      filteredUsers = filtered;
    });
  }

  void viewUserDetails(User user) {
    // สร้างหน้าแสดงรายละเอียดข้อมูลผู้ใช้
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => UserDetailsPage(user),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดผู้ใช้',
            textAlign: TextAlign.center), // ตรงกลาง
        centerTitle: true, // จัดหัวข้อตรงกลาง
        leading: IconButton(
          // ปุ่มย้อนกลับ
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // เมื่อกดปุ่มย้อนกลับ
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: filterUsers,
              decoration: InputDecoration(
                labelText: 'ค้นหาผู้ใช้',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40.0), // ปรับความโค้ง
                ),
              ),
            ),
          ),
          users.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Username')),
                          DataColumn(label: Text('ชื่อ')),
                          DataColumn(label: Text('ชนิดของผู้ใช้')),
                          DataColumn(
                              label: Text(
                                  'ดูรายละเอียด')), // เพิ่มคอลัมน์ดูรายละเอียด
                        ],
                        rows: filteredUsers
                            .map(
                              (user) => DataRow(
                                cells: [
                                  DataCell(Text(user.username)),
                                  DataCell(Text(user.user_fname)),
                                  DataCell(Text(user.user_type)),
                                  DataCell(IconButton(
                                    // ใส่ปุ่ม IconButton เพื่อดูรายละเอียด
                                    icon: const Icon(
                                      Icons.assignment,
                                      size: 40,
                                      color: Colors.amber,
                                    ),
                                    onPressed: () => viewUserDetails(
                                        user), // เมื่อคลิกปุ่มให้ดูรายละเอียด
                                  )),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class UserDetailsPage extends StatelessWidget {
  final User user;

  const UserDetailsPage(this.user, {Key? key}) : super(key: key);

  Future<void> deleteUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ip/restarant_papai/flutter1/delete_user.php'),
        body: {
          'user_id': user.user_id,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData == 'success') {
          // การลบสำเร็จ
          // คุณสามารถเพิ่มการปิดหน้าหรือรีเฟรชรายการผู้ใช้ได้ที่นี่ตามต้องการ
          // เช่น Navigator.of(context).pop();
        } else {
          // แจ้งให้รู้ว่ามีข้อผิดพลาดในการลบ
          // สามารถเพิ่มโค้ดเพื่อแสดงข้อความผิดพลาดหรือกระทำอื่น ๆ ตามต้องการ
        }
      } else {
        // แจ้งให้รู้ว่ามีข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์
        // สามารถเพิ่มโค้ดเพื่อแสดงข้อความผิดพลาดหรือกระทำอื่น ๆ ตามต้องการ
      }
    } catch (error) {
      // แจ้งให้รู้ว่ามีข้อผิดพลาดที่ไม่รู้จัก
      // สามารถเพิ่มโค้ดเพื่อแสดงข้อความผิดพลาดหรือกระทำอื่น ๆ ตามต้องการ
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดผู้ใช้',
            textAlign: TextAlign.center), // ตรงกลาง
        centerTitle: true, // จัดหัวข้อตรงกลาง
        leading: IconButton(
          // ปุ่มย้อนกลับ
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // เมื่อกดปุ่มย้อนกลับ
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'ชื่อ',
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: const OutlineInputBorder(),
                ),
                controller: TextEditingController(
                    text: '${user.user_fname} ${user.user_lname}'),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: const OutlineInputBorder(),
                ),
                controller: TextEditingController(text: user.username),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'เบอร์โทร',
                  prefixIcon: const Icon(Icons.phone),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: const OutlineInputBorder(),
                ),
                controller: TextEditingController(text: user.user_tel),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'อีเมล',
                  prefixIcon: const Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: const OutlineInputBorder(),
                ),
                controller: TextEditingController(text: user.user_email),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'ชนิดของผู้ใช้',
                  prefixIcon: const Icon(Icons.group),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: const OutlineInputBorder(),
                ),
                controller: TextEditingController(text: user.user_type),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditUserPage(
                            user: user,
                            userId: int.parse(user.user_id),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit), // เพิ่มไอคอนแก้ไข
                    label: const Text('แก้ไขข้อมูล'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('ยืนยันการลบข้อมูล'),
                            content: Text(
                                'คุณแน่ใจหรือไม่ที่จะลบข้อมูลผู้ใช้ ${user.username}'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('ยกเลิก'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // ปิด AlertDialog
                                },
                              ),
                              TextButton(
                                child: const Text('ยืนยัน'),
                                onPressed: () {
                                  // เรียกเมธอดสำหรับการลบข้อมูล
                                  deleteUser(user);
                                  Navigator.of(context)
                                      .pop(); // ปิด AlertDialog
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) {
                                    return const UserListPage();
                                  }));
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // สีพื้นหลังปุ่มลบเป็นสีแดง
                    ),
                    icon: const Icon(Icons.delete), // เพิ่มไอคอนลบ
                    label: const Text('ลบข้อมูล'),
                  ),
                ],
              )
            ],
          ),
        ]),
      ),
    );
  }
}

class EditUserPage extends StatefulWidget {
  final User user;
  final int userId;

  const EditUserPage({Key? key, required this.user, required this.userId})
      : super(key: key);

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late TextEditingController usernameController;
  late TextEditingController userFNameController;
  late TextEditingController userLNameController;
  late TextEditingController userTelController;
  late TextEditingController userEmailController;
  String selectedUserType = 'User'; // ค่าเริ่มต้น
  final List<String> userTypes = ['Admin', 'User', 'Chef', 'Rider'];

  Future<void> updateUser(User updatedUser) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ip/restarant_papai/flutter1/update_user.php'),
        body: {
          'user_id': updatedUser.user_id,
          'username': updatedUser.username,
          'user_fname': updatedUser.user_fname,
          'user_lname': updatedUser.user_lname,
          'user_tel': updatedUser.user_tel,
          'user_email': updatedUser.user_email,
          'user_type': updatedUser.user_type,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData == 'success') {
          // การอัปเดตสำเร็จ
          // คุณสามารถเพิ่มการปิดหน้าหรือรีเฟรชรายการผู้ใช้ได้ที่นี่ตามต้องการ
          // เช่น Navigator.of(context).pop();
        } else {
          // แจ้งให้รู้ว่ามีข้อผิดพลาดในการอัปเดต
          // สามารถเพิ่มโค้ดเพื่อแสดงข้อความผิดพลาดหรือกระทำอื่น ๆ ตามต้องการ
        }
      } else {
        // แจ้งให้รู้ว่ามีข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์
        // สามารถเพิ่มโค้ดเพื่อแสดงข้อความผิดพลาดหรือกระทำอื่น ๆ ตามต้องการ
      }
    } catch (error) {
      // แจ้งให้รู้ว่ามีข้อผิดพลาดที่ไม่รู้จัก
      // สามารถเพิ่มโค้ดเพื่อแสดงข้อความผิดพลาดหรือกระทำอื่น ๆ ตามต้องการ
    }
  }

  @override
  void initState() {
    super.initState();
    // กำหนดค่าเริ่มต้นให้กับ Text Editing Controllers
    usernameController = TextEditingController(text: widget.user.username);
    userFNameController = TextEditingController(text: widget.user.user_fname);
    userLNameController = TextEditingController(text: widget.user.user_lname);
    userTelController = TextEditingController(text: widget.user.user_tel);
    userEmailController = TextEditingController(text: widget.user.user_email);
  }

  @override
  void dispose() {
    // คืนทรัพยากร Text Editing Controllers เมื่อไม่ใช้งาน
    usernameController.dispose();
    userFNameController.dispose();
    userLNameController.dispose();
    userTelController.dispose();
    userEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูลผู้ใช้', textAlign: TextAlign.center),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ใส่ TextFormFields สำหรับแก้ไขข้อมูลผู้ใช้
              _buildTextFormField('Username', usernameController),
              _buildTextFormField('ชื่อ', userFNameController),
              _buildTextFormField('นามสกุล', userLNameController),
              _buildTextFormField('เบอร์โทร', userTelController),
              _buildTextFormField('อีเมล', userEmailController),
              _buildDropdownButtonFormField(),
              // เพิ่มปุ่มบันทึกข้อมูลหลังจากแก้ไข
              _buildSaveButton(),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0), // ความโค้งขอบ
          ),
          // เพิ่มเงา
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(
              color: Colors.orangeAccent,
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownButtonFormField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: selectedUserType,
        items: userTypes.map((String userType) {
          return DropdownMenuItem<String>(
            value: userType,
            child: Text(userType),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedUserType = newValue!;
          });
        },
        decoration: InputDecoration(
          labelText: 'ประเภทของผู้ใช้',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          // เพิ่มเงา
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(
              color: Colors.orangeAccent,
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        // โค้ดที่ต้องการให้ทำเมื่อกดปุ่มบันทึก
        // ตรวจสอบข้อมูลและบันทึก
        final updatedUser = User(
          user_id: widget.userId.toString(),
          username: usernameController.text,
          user_fname: userFNameController.text,
          user_lname: userLNameController.text,
          user_tel: userTelController.text,
          user_email: userEmailController.text,
          user_type: selectedUserType, // ใช้ค่าที่เลือกจาก dropdown
        );
        updateUser(updatedUser);

        // Navigator.pushReplacement ให้เปลี่ยนหน้าและลบหน้าปัจจุบันออก
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return const UserListPage();
        }));
      },
      child: const Text('บันทึกข้อมูล'),
    );
  }
}
