// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zzz/setting.dart';
import 'package:zzz/user/user_qrcode.dart';
import 'package:zzz/user/user_success.dart';

import 'user_location_select.dart';

class CartPageUser extends StatefulWidget {
  final String username;
  final int locationId;

  CartPageUser({required this.username, required this.locationId});

  @override
  _CartPageUserState createState() => _CartPageUserState();
}

enum paymentmethod {
  cashOnDelivery,
  cash,
  qrCode,
}

enum deliverymethod {
  inStorePickup,
  dineIn,
  delivery,
}

class _CartPageUserState extends State<CartPageUser> {
  List<dynamic> cartItems = [];
  double discountAmount = 0;
  paymentmethod selectedpaymentmethod = paymentmethod.cashOnDelivery;
  deliverymethod selecteddelivery_method = deliverymethod.inStorePickup;

  @override
  void initState() {
    super.initState();
    loadCartItems();
  }

  Future<void> loadCartItems() async {
    var url = 'http://$ip/restarant_papai/flutter1/cart.php';
    var response = await http.post(Uri.parse(url), body: {
      'username': widget.username,
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        cartItems = data;
      });
    }
  }

  Future<void> deleteCartItem(String username, int cartId) async {
    var url = 'http://$ip/restarant_papai/flutter1/delete_cart_item.php';
    var response = await http.post(Uri.parse(url), body: {
      'username': username,
      'cart_id': cartId.toString(),
    });

    if (response.statusCode == 200) {
      print('ลบรายการสินค้าออกจากฐานข้อมูลแล้ว');
    } else {
      print('ไม่สามารถลบรายการสินค้าออกจากฐานข้อมูลได้');
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

  Future<void> insertqueue(double totalPrice, String newDeliveryMethod,
      String newPaymentMethod) async {
    var url = 'http://$ip/restarant_papai/flutter1/insert_queue.php';
    var response = await http.post(Uri.parse(url), body: {
      'username': widget.username,
      'locationId': widget.locationId.toString(),
      'totalPrice': totalPrice.toString(),
      'discountAmount': discountAmount.toString(),
      'delivery_method': newDeliveryMethod,
      'payment_method': newPaymentMethod,
    });

    if (response.statusCode == 200) {
      print('เพิ่มข้อมูลลงในตาราง queue สำเร็จ');
    } else {
      print('ไม่สามารถเพิ่มข้อมูลลงในตาราง queue ได้');
    }
  }

  Future<void> updateCartItemQuantity(
      String menu_name, int cart_id, String newQuantity) async {
    var url = 'http://$ip/restarant_papai/flutter1/update_cart_quantity.php';
    var response = await http.post(Uri.parse(url), body: {
      'username': widget.username,
      'menu_name': menu_name,
      'cart_id': cart_id.toString(),
      'quantity': newQuantity,
    });

    if (response.statusCode == 200) {
      print('อัปเดตจำนวนสินค้าในฐานข้อมูลแล้ว');
    } else {
      print('ไม่สามารถอัปเดตจำนวนสินค้าในฐานข้อมูลได้');
    }
  }

  double getTotalPrice() {
    double totalPrice = 0;
    for (var cartItem in cartItems) {
      double itemPrice = double.parse(cartItem['menu_price']);
      int itemQuantity = int.parse(cartItem['quantity']);
      totalPrice += itemPrice * itemQuantity;
    }
    return totalPrice - discountAmount;
  }

  @override
  Widget build(BuildContext context) {
    final locationId = ModalRoute.of(context)?.settings.arguments as int?;
    String enteredDiscount = '';
    return Scaffold(
      appBar: AppBar(
        title: Text('ตะกร้าสินค้า'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          var cartItem = cartItems[index];
          var menu_name = cartItem['menu_name'];
          var menu_price = cartItem['menu_price'];
          var quantity = int.parse(cartItem['quantity']);
          var cart_id = int.parse(cartItem['cart_id']);
          var imageName = cartItem['menu_pics'];
          var detail = cartItem['detail'];
          var imagePath = 'http://$ip/restarant_papai/upload/menu/$imageName';

          return Dismissible(
            key: Key(cart_id.toString()),
            onDismissed: (direction) async {
              var username = widget.username;
              await deleteCartItem(username, cart_id);
              setState(() {
                cartItems.removeAt(index);
              });
            },
            background: Container(
              alignment: Alignment.centerRight,
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              leading: Container(
                width: 100,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(imagePath, fit: BoxFit.cover),
                ),
              ),
              title: Text(menu_name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ราคา: $menu_price บาท'),
                  Text('รายละเอียด: $detail '),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ปุ่มลบรายการสินค้า
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          var username = widget.username;
                          await deleteCartItem(username, cart_id);
                          setState(() {
                            cartItems.removeAt(index);
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                              cartItem['quantity'] = quantity.toString();
                              updateCartItemQuantity(
                                  menu_name, cart_id, quantity.toString());
                            });
                          }
                        },
                        child: Icon(Icons.remove),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(0),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          quantity.toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
                            cartItem['quantity'] = quantity.toString();
                            updateCartItemQuantity(
                                menu_name, cart_id, quantity.toString());
                          });
                        },
                        child: Icon(Icons.add),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color.fromARGB(255, 21, 255, 0),
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationSelectionPage(
                        username: widget.username,
                      ),
                    ),
                  );
                },
                child: Text('เลือกที่อยู่สำหรับการส่ง'),
              ),
              Text('Username: ${widget.username}'),
              Text('Location ID: ${widget.locationId}'),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'วิธีรับอาหาร',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DropdownButton<deliverymethod>(
                    value: selecteddelivery_method,
                    onChanged: (deliverymethod? newValue) {
                      setState(() {
                        selecteddelivery_method = newValue!;
                      });
                    },
                    items: deliverymethod.values.map((deliverymethod method) {
                      String methodText = '';
                      if (method == deliverymethod.inStorePickup) {
                        methodText = 'มารับหน้าร้าน';
                      } else if (method == deliverymethod.dineIn) {
                        methodText = 'รับประทานในร้าน';
                      } else if (method == deliverymethod.delivery) {
                        methodText = 'ส่งตามที่อยู่ GPS';
                      }
                      return DropdownMenuItem<deliverymethod>(
                        value: method,
                        child: Text(methodText),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'วิธีชำระเงิน',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DropdownButton<paymentmethod>(
                    value: selectedpaymentmethod,
                    onChanged: (paymentmethod? newValue) {
                      setState(() {
                        selectedpaymentmethod = newValue!;
                      });
                    },
                    items: paymentmethod.values.map((paymentmethod method) {
                      String methodText = '';
                      if (method == paymentmethod.cashOnDelivery) {
                        methodText = 'ชำระเงินปลายทาง';
                      } else if (method == paymentmethod.cash) {
                        methodText = 'ชำระเงินสด';
                      } else if (method == paymentmethod.qrCode) {
                        methodText = 'สแกน QR Code';
                      }

                      return DropdownMenuItem<paymentmethod>(
                        value: method,
                        child: Text(methodText),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'โค้ดส่วนลด',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.orangeAccent),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('ใส่โค้ดส่วนลด'),
                            content: TextField(
                              keyboardType: TextInputType.text,
                              onChanged: (value) {
                                enteredDiscount = value;
                              },
                              decoration: InputDecoration(
                                labelText: 'โค้ดส่วนลด',
                                hintText: 'โปรดป้อนโค้ดส่วนลด',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('ยกเลิก'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  var url =
                                      'http://$ip/restarant_papai/flutter1/check_discount_code.php';
                                  var response =
                                      await http.post(Uri.parse(url), body: {
                                    'discount_code': enteredDiscount,
                                  });

                                  if (response.statusCode == 200) {
                                    var data = json.decode(response.body);
                                    if (data['success']) {
                                      discountAmount = double.parse(
                                          data['discountAmount'].toString());
                                      setState(() {
                                        discountAmount = discountAmount;
                                      });
                                      Navigator.pop(context);
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                                'ไม่สามารถใช้โค้ดดังกล่าวได้'),
                                            content: Text(data['message']),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('ตกลง'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('ข้อผิดพลาด'),
                                          content: Text(
                                              'ไม่สามารถตรวจสอบโค้ดส่วนลดได้ในขณะนี้'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('ตกลง'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Text('ตกลง'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text('ใส่โค้ดส่วนลด'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ราคารวม: ${getTotalPrice().toStringAsFixed(2)} บาท',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedpaymentmethod == paymentmethod.qrCode) {
                        for (var cartItem in cartItems) {
                          print(
                              "กำลังอัปเดตรายการสินค้า: ${cartItem['menu_name']}");
                          await updateCartItemStatusAndMethods(
                            cartItem['menu_name'],
                            '1',
                            selecteddelivery_method.toString(),
                            selectedpaymentmethod.toString(),
                          );
                          print(
                              "อัปเดตรายการสินค้าแล้ว: ${cartItem['menu_name']}");
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRCodeUser(
                              totalPrice:
                                  getTotalPrice(), // ใช้ getTotalPrice() โดยตรง
                              discountAmount: discountAmount.toString(),
                              locationId: widget.locationId.toString(),
                              username: widget.username,
                              selecteddelivery_method:
                                  selecteddelivery_method.toString(),
                              selectedpaymentmethod:
                                  selectedpaymentmethod.toString(),
                              cartItems: cartItems,
                            ),
                          ),
                        );
                      } else {
                        double totalPrice = getTotalPrice();
                        await insertqueue(
                          totalPrice,
                          selecteddelivery_method.toString(),
                          selectedpaymentmethod.toString(),
                        );

                        for (var cartItem in cartItems) {
                          print(
                              "กำลังอัปเดตรายการสินค้า: ${cartItem['menu_name']}");
                          await updateCartItemStatusAndMethods(
                            cartItem['menu_name'],
                            '2',
                            selecteddelivery_method.toString(),
                            selectedpaymentmethod.toString(),
                          );
                          print(
                              "อัปเดตรายการสินค้าแล้ว: ${cartItem['menu_name']}");
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderSuccessPageUser(
                              totalPrice: totalPrice,
                              username: widget.username,
                              locationId: widget.locationId,
                              deliveryMethod:
                                  selecteddelivery_method.toString(),
                              paymentMethod: selectedpaymentmethod.toString(),
                              cartItems: cartItems,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text('ชำระเงิน'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
