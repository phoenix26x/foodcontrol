// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:zzz/user/user_homepage.dart';

import '../setting.dart';

class OrderSuccessPageUser extends StatelessWidget {
  final double totalPrice;
  final String username;
  final String deliveryMethod;
  final String paymentMethod;
  final List<dynamic> cartItems;
  final int locationId;

  OrderSuccessPageUser({
    required this.totalPrice,
    required this.username,
    required this.deliveryMethod,
    required this.paymentMethod,
    required this.cartItems,
    required this.locationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('สำเร็จแล้ว'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              'การสั่งอาหารสำเร็จ!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'ราคารวมทั้งหมด: ${totalPrice.toStringAsFixed(2)} บาท',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'วิธีการชำระเงิน: $paymentMethod',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'วิธีการจัดส่ง: $deliveryMethod',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'รายการที่สั่ง:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0), // ปรับตามที่คุณต้องการ
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var cartItem = cartItems[index];
                    var menuName = cartItem['menu_name'];
                    var menuPrice = double.parse(cartItem['menu_price']);
                    var quantity = int.parse(cartItem['quantity']);
                    var imageName = cartItem['menu_pics'];
                    var imagePath =
                        'http://$ip/restarant_papai/upload/menu/$imageName';
                    return Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: ListTile(
                        title: Row(
                          children: [
                            Image.network(
                              imagePath,
                              width: 100,
                              height: 100,
                            ),
                            SizedBox(width: 16,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(menuName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                Text('ราคา: $menuPrice บาท  จำนวน: $quantity', style: TextStyle(fontSize: 14,color: Colors.black54),),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePageUser(username: username, locationId: locationId),
                  ),
                );
              },
              child: Text('กลับสู่หน้าหลัก'),
            ),
          ],
        ),
      ),
    );
  }
}
