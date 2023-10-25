import 'package:alcohol_logger/utility/bottomNav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

final _firestore = FirebaseFirestore.instance; //for the database
final auth = FirebaseAuth.instance;
late User loggedInUser;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String todaysDate = "";
  String firstDayOfWeek = "";
  List<int> weeklyLog = [];

  @override
  void initState() {
    super.initState();
    todaysDate = DateTime.now().toString().split(" ")[0];
    firstDayOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday)).toString().split(" ")[0];

    getWeeklyLog(firstDayOfWeek);
  }

  getWeeklyLog(String day) async {
    try {
      final user = await auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
      var docRef = _firestore.collection('drinks').doc(loggedInUser.email);
      DocumentSnapshot doc = await docRef.get();
      final data = await doc.data() as Map<String, dynamic>;
      for (int i = 0; i < 7; i++) {
        if (data.keys.contains(day)) {
          int sum = 0;
          data[day].forEach((innerKey, innerValue) {
            // goes through each drink at date
            sum += innerValue as int;
          });
          weeklyLog.add(sum);
        } else {
          weeklyLog.add(0);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
    int currentHour = int.parse(formattedDate.split(':')[0]);

    String welcomeMessage() {
      if (currentHour <= 12) {
        return "Good morning";
      } else if (currentHour > 12 && currentHour <= 18) {
        return "Good afternoon";
      } else {
        return "Good evening";
      }
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Text(
                welcomeMessage(),
                style: TextStyle(fontSize: 24),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  left: 15,
                  right: 15,
                ),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "$todaysDate",
                        style: TextStyle(fontSize: 28),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.lightBlueAccent, width: 3)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 30.0,
                  left: 15,
                  right: 15,
                ),
                child: Container(
                  height: 300,
                  width: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.lightBlueAccent, width: 3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Ounces:",
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, left: 5, right: 5),
                          child: SfSparkBarChart(
                            labelDisplayMode: SparkChartLabelDisplayMode.all,
                            axisLineColor: Colors.transparent,
                            data: <double>[
                              10,
                              6,
                              8,
                              5,
                              11,
                              5,
                              2,
                            ],
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("Sun"),
                              Text("Mon"),
                              Text("Tue"),
                              Text("Wed"),
                              Text("Thur"),
                              Text("Fri"),
                              Text("Sat"),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  height: 200,
                  width: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.lightBlueAccent, width: 3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Beer: 40oz",
                          style: TextStyle(fontSize: 24),
                        ),
                        Text(
                          "Red Wine: 10oz",
                          style: TextStyle(fontSize: 24),
                        ),
                        Text(
                          "White Wine: 8oz",
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNav(
            selectedIndex: 1,
          ),
        ),
      ),
    );
  }

  Container datePicker() {
    return Container(
      height: 300,
      width: 300,
      child: SfDateRangePicker(
        initialSelectedDate: DateTime.now(),
        onSubmit: (value) {
          Navigator.pop(context);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
