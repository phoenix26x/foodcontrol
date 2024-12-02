// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:zzz/user/user_homepage.dart';

import '../setting.dart';

class QRCodeUser extends StatefulWidget {
  final String username;
  final String discountAmount;
  final String locationId;
  final double totalPrice;
  final String selecteddelivery_method;
  final String selectedpaymentmethod;
  final List<dynamic> cartItems; // รายการสินค้าในตะกร้า

  QRCodeUser({
    Key? key,
    required this.totalPrice,
    required this.username,
    required this.discountAmount,
    required this.locationId,
    required this.selecteddelivery_method,
    required this.selectedpaymentmethod,
    required this.cartItems, // รับรายการสินค้า
  }) : super(key: key);

  @override
  State<QRCodeUser> createState() => _QRCodeUserState();
}

class _QRCodeUserState extends State<QRCodeUser> {
  final ImagePicker _picker = ImagePicker();
  File? _slipImage;
  String generateUniqueFileName() {
    // สร้างชื่อไฟล์ที่ไม่ซ้ำกัน โดยใช้ timestamp
    DateTime now = DateTime.now();
    String timestamp = now.millisecondsSinceEpoch.toString();
    return 'slip_image_$timestamp.png';
  }

  String getDeliveryMethodText(String deliveryMethod) {
    switch (deliveryMethod) {
      case 'deliverymethod.inStorePickup':
        return 'มารับหน้าร้าน';
      case 'deliverymethod.dineIn':
        return 'รับประทานในร้าน';
      case 'deliverymethod.delivery':
        return 'ส่งตามที่อยู่ GPS';
      default:
        return 'ไม่ระบุ';
    }
  }

  String getPaymentMethodText(String deliveryMethod) {
    switch (deliveryMethod) {
      case 'paymentmethod.qrCode':
        return 'พร้อมเพย์ QRCode';
      default:
        return 'ไม่ระบุ';
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _slipImage = File(pickedFile.path);
      });
    }
  }

  Future<void> insertQueue(
    double totalPrice,
    double discountAmount,
    String locationId,
    String deliveryMethod,
    String paymentMethod,
    File? image,
  ) async {
    var url = 'http://$ip/restarant_papai/flutter1/insert_queue_slip.php';

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['username'] = widget.username;
    request.fields['totalPrice'] = totalPrice.toString();
    request.fields['discount'] = discountAmount.toString();
    request.fields['location_id'] = locationId;
    request.fields['delivery_method'] = deliveryMethod;
    request.fields['payment_method'] = paymentMethod;

    if (image != null) {
      var slipImageName = generateUniqueFileName(); // สร้างชื่อไฟล์ที่ไม่ซ้ำกัน
      request.files.add(await http.MultipartFile.fromPath(
          'slip_image', image.path,
          filename: slipImageName));
    }

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        print('ข้อมูลถูกแทรกลงในตาราง queue แล้ว');
      } else {
        print('ไม่สามารถแทรกข้อมูลในตาราง queue ได้: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการแทรกข้อมูลในตาราง queue: $e');
    }
  }

  Future<void> updateCartItemStatusAndMethods(
    String menu_name,
    String newStatus,
    String newDeliveryMethod,
    String newPaymentMethod,
  ) async {
    var url = 'http://$ip/restarant_papai/flutter1/update_cart_status.php';

    await http.post(Uri.parse(url), body: {
      'username': widget.username,
      'menu_name': menu_name,
      'status': newStatus,
      'delivery_method': newDeliveryMethod,
      'payment_method': newPaymentMethod,
    });
  }

  @override
  Widget build(BuildContext context) {
    double formattedTotalPrice =
        double.parse(widget.totalPrice.toStringAsFixed(2));
    double priceAmount = formattedTotalPrice;

    String storeName = 'อาหารตามสั่ง';
    String promptPayNumber = '0989604636';
    String ppname = 'นางสาว จารุวรรณ ภิรมอยู่';

    String promptPayUrl =
        "https://promptpay.io/$promptPayNumber/$priceAmount.png";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text(
          'พร้อมเพย์ QR Code',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  storeName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: Image.network(promptPayUrl),
                ),
                SizedBox(height: 10),
                Text(
                  'ราคารวม: $priceAmount บาท',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'หมายเลขพร้อมเพย์: $promptPayNumber',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'ชื่อบัญชี : $ppname',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'วิธีชำระเงิน: ${getPaymentMethodText(widget.selectedpaymentmethod)}',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'วิธีรับอาหาร: ${getDeliveryMethodText(widget.selecteddelivery_method)}',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'หมายเลขพื้นที่: ${widget.locationId}', // แสดง location_id
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'ส่วนลด: ${widget.discountAmount} บาท', // แสดงส่วนลด
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                _slipImage != null
                    ? Image.file(
                        _slipImage!,
                        height: 200,
                      )
                    : SizedBox(),
                ElevatedButton(
                  onPressed: () {
                    _pickImage(ImageSource.gallery);
                  },
                  child: Text('อัปโหลดรูปภาพสลิป'),
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    print("Start payment button pressed");
                    // Loop through cart items to update each one
                    for (var cartItem in widget.cartItems) {
                      print("Updating cart item: ${cartItem['menu_name']}");
                      await updateCartItemStatusAndMethods(
                        cartItem['menu_name'],
                        '2', // ค่า newStatus ที่ต้องการส่ง
                        widget
                            .selecteddelivery_method, // ใช้ widget เพื่อเข้าถึงค่า
                        widget
                            .selectedpaymentmethod, // ใช้ widget เพื่อเข้าถึงค่า
                      );
                      print("Updated cart item: ${cartItem['menu_name']}");
                    }

                    double totalPrice = formattedTotalPrice;
                    double discountAmount = double.parse(widget.discountAmount);
                    String locationId = widget.locationId;
                    String deliveryMethod =
                        widget.selecteddelivery_method.toString();
                    String paymentMethod =
                        widget.selectedpaymentmethod.toString();

                    await insertQueue(totalPrice, discountAmount, locationId,
                        deliveryMethod, paymentMethod, _slipImage);

                    // ย้ายไปยังหน้า HomePage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePageUser(
                                username: widget.username,
                                locationId: 0,
                              )),
                    );
                  },
                  child: Text('ตกลง'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
