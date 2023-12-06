import 'package:alcohol_logger/utility/bottomNav.dart';
import 'package:alcohol_logger/utility/calculatingBAC.dart';
import 'package:alcohol_logger/utility/user_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:jiffy/jiffy.dart';

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
          //each day
          int sum = 0;
          data[day].forEach((drinkType, timeAndAmount) {
            // each drink type
            timeAndAmount.forEach((time, amount) {
              //each time and amount
              sum += amount as int;
            });
          });

          setState(() {
            weeklyLog.add(sum);
          });
        } else {
          setState(() {
            weeklyLog.add(0);
          });
        }
        // update to next day
        DateTime nextDay = DateTime.parse(day + " 10:00:00.000");
        nextDay = Jiffy.parseFromDateTime(nextDay).add(days: 1).dateTime;
        day = nextDay.toString().split(" ")[0];
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
                            data: weeklyLog.isNotEmpty ? weeklyLog : [0, 0, 0, 0, 0, 0, 0],
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
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
                        FutureBuilder<String>(
                            future: getBloodAlcoholLevel(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                  children: [
                                    Text(
                                      "Current BAC: ${snapshot.data}%",
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    Text(
                                      double.parse(snapshot.data!) > 0.08 ? "You are above legal limit" : "You are under legal limit",
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ],
                                );
                              } else {
                                return Container();
                              }
                            }),
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
