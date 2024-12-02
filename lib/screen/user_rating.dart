import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;

import '../setting.dart';

class RatingPage extends StatefulWidget {
  final String username;

  RatingPage({required this.username});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double restaurantRating = 0.0;
  double tasteRating = 0.0;
  double cleanlinessRating = 0.0;
  double employeeRating = 0.0;
  bool ratingsSubmitted = false;

  // เพิ่มตัวแปร totalRating
  double totalRating = 0.0;

  Future<void> submitRatings() async {
    final url = Uri.parse('http://$ip/restarant_papai/flutter1/rating.php');

    final response = await http.post(
      url,
      body: {
        'username': widget.username,
        'restaurantPoint': restaurantRating.toString(),
        'tastePoint': tasteRating.toString(),
        'cleanlinessPoint': cleanlinessRating.toString(),
        'employeePoint': employeeRating.toString(),
      },
    );

    if (response.statusCode == 200) {
      print('บันทึกคะแนนสำเร็จ');
      setState(() {
        ratingsSubmitted = true;
      });
    } else {
      print('เกิดข้อผิดพลาดในการบันทึกคะแนน: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // คำนวณค่าเฉลี่ยของคะแนนทั้งหมด
    totalRating = (restaurantRating + tasteRating + cleanlinessRating + employeeRating) ;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text("ให้คะแนนร้านอาหาร"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(25),
            child: Text(
              "ชื่อผู้ใช้ : ${widget.username}",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          buildRatingTile("คะแนนร้าน", restaurantRating, (rating) {
            setState(() {
              restaurantRating = rating;
            });
          }),
          SizedBox(
            height: 10,
          ),
          buildRatingTile("คะแนนรสชาติอาหาร", tasteRating, (rating) {
            setState(() {
              tasteRating = rating;
            });
          }),
          buildRatingTile("คะแนนความสะอาด", cleanlinessRating, (rating) {
            setState(() {
              cleanlinessRating = rating;
            });
          }),
          buildRatingTile("คะแนนพนักงาน", employeeRating, (rating) {
            setState(() {
              employeeRating = rating;
            });
          }),
          // แสดงค่าเฉลี่ยของคะแนน
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'คะแนนเฉลี่ย: ${totalRating.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (!ratingsSubmitted)
            ElevatedButton(
              onPressed: () {
                submitRatings();
              },
              child: Text("บันทึกคะแนน"),
            ),
          if (ratingsSubmitted)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'คุณได้ให้คะแนนแล้ว',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      submitRatings().then((_) {
                        Navigator.pop(context);
                      });
                    },
                    child: Text("บันทึกคะแนน"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  ListTile buildRatingTile(
    String title,
    double rating,
    Function(double) onRatingUpdate,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RatingBar.builder(
            initialRating: rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemSize: 40.0,
            unratedColor: Colors.amber.withAlpha(50),
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: onRatingUpdate,
          ),
          Text("คะแนน: $rating", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
