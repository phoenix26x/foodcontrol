import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // เพิ่มบรรทัดนี้
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../setting.dart';

class IncomeViewPage extends StatefulWidget {
  const IncomeViewPage({super.key});

  @override
  _IncomeViewPageState createState() => _IncomeViewPageState();
}

class _IncomeViewPageState extends State<IncomeViewPage> {
  String selectedPeriod = 'daily';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  late Future<List<dynamic>> incomeData;
  double totalIncome = 0.0;

  Future<List<dynamic>> fetchIncomeData(
      DateTime startDate, DateTime endDate) async {
    final response = await http.get(Uri.parse(
        'http://$ip/restarant_papai/flutter1/Income_Viewpage.php?startDate=${startDate.toLocal().toString()}&endDate=${endDate.toLocal().toString()}&status=ปรุงเสร็จแล้ว'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('การดึงข้อมูลรายได้ล้มเหลว');
    }
  }

  @override
  void initState() {
    super.initState();
    incomeData = fetchIncomeData(startDate, endDate);
    initializeDateFormatting('th', null);
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        incomeData = fetchIncomeData(startDate, endDate);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
        incomeData = fetchIncomeData(startDate, endDate);
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายได้'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("จากวันที่* :"),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("ถึงวันที่* :"),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _selectStartDate(context),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 215, 215, 215),
                          ),
                          child: Text(
                            DateFormat('dd MMM yyyy', 'th').format(startDate),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: 8), // Add spacing between the buttons
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _selectEndDate(context),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 215, 215, 215),
                          ),
                          child: Text(
                            DateFormat('dd MMM yyyy', 'th').format(endDate),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(66, 161, 161, 161),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FutureBuilder<List<dynamic>>(
                  future: incomeData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('ไม่พบข้อมูลรายได้'),
                          ],
                        ),
                      );
                    } else {
                      List? data = snapshot.data;
                      totalIncome = 0.0;
                      for (var i = 0; i < data!.length; i++) {
                        final price = double.parse(data[i]['price']);
                        totalIncome += price;
                      }
                      return Expanded(
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'รายการ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'discount',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'รายได้',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  final income = data[index];
                                  final orderId = income['id'];
                                  final discount = income['discount_price'];
                                  final price = double.parse(income['price']);

                                  return ListTile(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '$orderId',
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '$discount',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '${price.toStringAsFixed(2)} บาท',
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // You can remove the trailing property as it's already included in the title Row
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: const Text(
                                  'รวมทั้งหมด:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                trailing: Text(
                                  '${totalIncome.toStringAsFixed(2)} บาท',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.green),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
