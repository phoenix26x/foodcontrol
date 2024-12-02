import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:zzz/screen/user_rating.dart';

import '../setting.dart';

class avgRating extends StatefulWidget {
  final String username;

  avgRating({required this.username});

  @override
  _avgRatingState createState() => _avgRatingState();
}

class _avgRatingState extends State<avgRating> {
  double restaurantAvgRating = 0.0;
  double tasteAvgRating = 0.0;
  double cleanlinessAvgRating = 0.0;
  Map<String, dynamic> userRatings = {};

  Future<void> fetchAverageRatings() async {
    final url = Uri.parse(
        'http://$ip/restarant_papai/flutter1/get_average_ratings.php');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        restaurantAvgRating = double.parse(data['restaurant_avg']);
        tasteAvgRating = double.parse(data['taste_avg']);
        cleanlinessAvgRating = double.parse(data['cleanliness_avg']);
      });
    } else {
      print('เกิดข้อผิดพลาดในการดึงข้อมูล: ${response.statusCode}');
    }

    fetchUserRatings();
  }

  Future<void> fetchUserRatings() async {
    final url =
        Uri.parse('http://$ip/restarant_papai/flutter1/get_user_ratings.php');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        userRatings = data;
      });
    } else {
      print(
          'เกิดข้อผิดพลาดในการดึงข้อมูลคะแนนของผู้ใช้: ${response.statusCode}');
    }
  }

  Future<void> _handleRefresh() async {
    await fetchAverageRatings();
  }

  @override
  void initState() {
    super.initState();
    fetchAverageRatings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("คะแนนร้านอาหารตามสั่ง"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          children: [
            Card(
              elevation: 4.0,
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "ค่าเฉลี่ยคะแนนร้าน: ${restaurantAvgRating.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 20),
                    ),
                    RatingBar.builder(
                      initialRating: restaurantAvgRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "ค่าเฉลี่ยคะแนนรสชาติอาหาร: ${tasteAvgRating.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 20),
                    ),
                    RatingBar.builder(
                      initialRating: tasteAvgRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "ค่าเฉลี่ยคะแนนความสะอาด: ${cleanlinessAvgRating.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 20),
                    ),
                    RatingBar.builder(
                      initialRating: cleanlinessAvgRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "คะแนนจากผู้ใช้:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            for (var username in userRatings.keys)
              Card(
                elevation: 4.0,
                margin: EdgeInsets.all(16.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ผู้ใช้: $username",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        "คะแนนร้าน: ${userRatings[username]['resterant_point']}",
                        style: TextStyle(fontSize: 16),
                      ),
                      RatingBar.builder(
                        initialRating: double.parse(
                            userRatings[username]['resterant_point']),
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      ),
                      Text(
                        "คะแนนรสชาติอาหาร: ${userRatings[username]['food_point']}",
                        style: TextStyle(fontSize: 16),
                      ),
                      RatingBar.builder(
                        initialRating:
                            double.parse(userRatings[username]['food_point']),
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      ),
                      Text(
                        "คะแนนความสะอาด: ${userRatings[username]['clean_point']}",
                        style: TextStyle(fontSize: 16),
                      ),
                      RatingBar.builder(
                        initialRating:
                            double.parse(userRatings[username]['clean_point']),
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RatingPage(username: widget.username),
                  ),
                );
              },
              child: Text("ไปให้คะแนน"),
            ),
          ],
        ),
      ),
    );
  }
}
