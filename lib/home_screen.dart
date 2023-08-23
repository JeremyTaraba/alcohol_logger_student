import 'package:alcohol_logger/utility/bottomNav.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                        "August 20 - 27",
                        style: TextStyle(fontSize: 28),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 50,
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.lightBlueAccent, width: 3)),
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
                      border:
                          Border.all(color: Colors.lightBlueAccent, width: 3)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Overview:",
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 5, right: 5),
                          child: SfSparkBarChart(
                            axisLineColor: Colors.white,
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
                            lastPointColor: Colors.greenAccent,
                          ),
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
}
