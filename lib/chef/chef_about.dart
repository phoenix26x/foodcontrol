import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:zzz/admin/editdataadmin.dart';
import 'package:zzz/chef/chef_about_1.dart';
import '../setting.dart';
import 'chef_about_1.dart'; // เพิ่มการนำเข้าไฟล์ uer_about_1.dart

class AboutChef extends StatelessWidget {
  final Map<String, dynamic>? updatedData;

  AboutChef({Key? key, this.updatedData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AboutChef(updatedData: updatedData);
  }
}

class _AboutChef extends StatefulWidget {
  final Map<String, dynamic>? updatedData;

  _AboutChef({Key? key, this.updatedData}) : super(key: key);

  @override
  _AboutUserState createState() => _AboutUserState();
}

class _AboutUserState extends State<_AboutChef> {
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController igController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<List<Map<String, dynamic>>> getContactData() async {
    var url = 'http://$ip/restarant_papai/flutter1/ViewAbout.php';
    var response = await http.get(Uri.parse(url));
    List<dynamic> responseData = json.decode(response.body);
    List<Map<String, dynamic>> mappedData =
        responseData.cast<Map<String, dynamic>>();
    return mappedData;
  }

  final facebookUrl = Uri.parse('https://www.facebook.com/Wongnai');
  final instagramUrl = Uri.parse('https://www.instagram.com/wongnai/?hl=en');

  void _editData(BuildContext context) async {
    Map<String, dynamic>? updatedData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditDataAdmin()),
    );
    if (updatedData != null) {
      setState(() {
        phoneController.text = updatedData['tel'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            size: 35,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getContactData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            var dataList = snapshot.data!;
            var data = dataList.first;
            return ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(data['email'] ?? 'No email available'),
                  onTap: () {
                    // Add code here for handling email tap
                  },
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(data['tel']),
                      ElevatedButton(
                        onPressed: () async {
                          final url = Uri(scheme: 'tel', path: data['tel']);
                          if (await canLaunch(url.toString())) {
                            launch(url.toString());
                          }
                        },
                        child: const Text('โทรหาร้าน'),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.facebook),
                  title: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          if (facebookUrl != null) {
                            launch(facebookUrl.toString());
                          }
                        },
                        child: Text(
                          'Facebook - ร้านอาหารตามคิว',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt_outlined),
                  title: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          if (instagramUrl != null) {
                            launch(instagramUrl.toString());
                          }
                        },
                        child: Text(
                          'Instagram - ร้านอาหารตามคิว',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // เพิ่มปุ่ม "เวลาเปิดร้านอาหาร"
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutChef1()),
                    );
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(
                          vertical: 10), // ปรับขนาดตำแหน่งของปุ่ม
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 243, 159, 50), // ปรับสีพื้นหลังของปุ่ม
                    ),
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(120, 50), // ปรับความกว้างและความยาวของปุ่ม
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(50), // ปรับขอบของปุ่ม
                      ),
                    ),
                  ),
                  child: Text(
                    'เวลาเปิดร้านอาหาร',
                    style: TextStyle(
                      fontSize: 18, // ปรับขนาดตัวหนังสือ
                      color: Colors.white, // ปรับสีตัวหนังสือ
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
