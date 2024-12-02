// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, avoid_print, prefer_const_constructors_in_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../setting.dart';

class QRCode extends StatefulWidget {
  final String username;
  final String discountAmount;
  final String locationId;
  final double totalPrice;
  final String selecteddelivery_method;
  final String selectedpaymentmethod;
  final List<dynamic> cartItems; // รายการสินค้าในตะกร้า

  QRCode({
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
  State<QRCode> createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCode> {
  late double discountAmount;
  final ImagePicker _picker = ImagePicker();
  File? _slipImage;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _slipImage = File(pickedFile.path);
      });
    }
  }

  Future<void> insertQueueWithSlip(
    String username,
    String locationId,
    double totalPrice,
    double discountAmount,
    String newDeliveryMethod,
    String newPaymentMethod,
  ) async {
    var url =
        'http://$ip/restarant_papai/flutter1/add_to_queue_with_slip.php'; // เปลี่ยน URL เป็นที่อยู่ของไฟล์ PHP ของคุณ
    var response = await http.post(
      Uri.parse(url),
      body: {
        'username': username,
        'locationId': locationId,
        'totalPrice': totalPrice.toString(),
        'discountAmount': discountAmount.toString(),
        'delivery_method': newDeliveryMethod,
        'payment_method': newPaymentMethod,
      },
    );

    if (response.statusCode == 200) {
      print('เพิ่มข้อมูลลงในตาราง queue สำเร็จ');
      // ทำอะไรสักอย่างหลังจากสำเร็จ (เช่น ไปหน้าอื่น)
    } else {
      print('ไม่สามารถเพิ่มข้อมูลลงในตาราง queue ได้');
      // กรณีที่เกิดข้อผิดพลาด
    }
  }

  Future<void> updateCartItemStatusAndMethods(
      String menu_name,
      String newStatus,
      String newDeliveryMethod,
      String newPaymentMethod) async {
    var url = 'http://$ip/restarant_papai/flutter1/update_cart_status.php';

    await http.post(Uri.parse(url), body: {
      'username': widget.username,
      'menu_name': menu_name,
      'status': newStatus,
      'delivery_method': newDeliveryMethod,
      'payment_method': newPaymentMethod,
    });
  }

  Future<void> updateSlipImageToDatabase(String menu_name, File image) async {
    var url = 'http://$ip/restarant_papai/flutter1/update_cart_slib.php';

    // Create a multipart request for sending the image
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['username'] = widget.username;
    request.fields['status'] = '2';
    request.fields['delivery_method'] =
        widget.selecteddelivery_method.toString();
    request.fields['payment_method'] = widget.selectedpaymentmethod.toString();
    request.fields['menu_name'] = menu_name;
    request.files
        .add(await http.MultipartFile.fromPath('slip_image', image.path));
    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        // The image and data were successfully uploaded
        print('Successfully updated slip image for $menu_name');
      } else {
        // Handle the case where the server returns an error
        print('Failed to update slip image: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      print('Error updating slip image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double formattedTotalPrice =
        double.parse(widget.totalPrice.toStringAsFixed(2));
    double priceAmount = formattedTotalPrice;

    String storeName = 'อาหารตามสั่ง';
    String promptPayNumber = '0909609814';
    String ppname = 'นาย ธนกร มินไธสง';

    String promptPayUrl =
        "https://promptpay.io/$promptPayNumber/$priceAmount.png";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text(
          'พร้อมเพย์ QR Code',
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
                  'วิธีชำระเงิน: ${widget.selectedpaymentmethod}', // ใช้ widget เพื่อเข้าถึงค่า
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'วิธีรับอาหาร: ${widget.selecteddelivery_method}', // ใช้ widget เพื่อเข้าถึงค่า
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
                    await insertQueueWithSlip(
                      widget.username,
                      widget.locationId,
                      widget.totalPrice,
                      double.parse(widget.discountAmount),
                      widget.selecteddelivery_method,
                      widget.selectedpaymentmethod,
                    );

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

                      // Update slip image if available
                      if (_slipImage != null) {
                        await updateSlipImageToDatabase(
                          cartItem['menu_name'],
                          _slipImage!,
                        );
                      }
                      print("Updated cart item: ${cartItem['menu_name']}");
                    }
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
