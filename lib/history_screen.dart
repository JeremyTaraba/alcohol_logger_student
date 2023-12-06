import 'dart:collection';

import 'package:alcohol_logger/utility/bottomNav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:alcohol_logger/utility/calendar_utils.dart';

final _firestore = FirebaseFirestore.instance; //for the database
final auth = FirebaseAuth.instance;
late User loggedInUser;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  ValueNotifier<List<Event>> _selectedEvents = ValueNotifier([Event("")]);

  var events = LinkedHashMap<DateTime, List<Event>>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedDay = _focusedDay;
  }

  getDrinkHistory() async {
    events = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(await getDrinks());
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: FutureBuilder(
              future: getDrinkHistory(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                return Column(
                  children: [
                    TableCalendar(
                      firstDay: DateTime.utc(2010, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      focusedDay: _focusedDay,
                      eventLoader: (day) {
                        return _getEventsForDay(day);
                      },
                      availableCalendarFormats: const {CalendarFormat.month: "Month"},
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      pageJumpingEnabled: true,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay; // update `_focusedDay` here as well
                        });
                        _selectedEvents.value = _getEventsForDay(selectedDay);
                      },
                      calendarBuilders: CalendarBuilders(
                        dowBuilder: (context, day) {
                          final text = DateFormat.E().format(day);
                          return Center(
                            child: Text(
                              text,
                              style: TextStyle(color: Colors.lightBlue),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: ValueListenableBuilder<List<Event>>(
                        // show the events
                        valueListenable: _selectedEvents,
                        builder: (context, value, _) {
                          return ListView.builder(
                            itemCount: value.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: ListTile(
                                  onTap: () => print('${value[index]}'),
                                  title: Text('${value[index]}'),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
          bottomNavigationBar: BottomNav(
            selectedIndex: 2,
          ),
        ),
      ),
    );
  }

  getDrinks() async {
    LinkedHashMap<DateTime, List<Event>> events = LinkedHashMap();
    List<Event> listOfDrinks = [];

    try {
      final user = await auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }

      var docRef = _firestore.collection('drinks').doc(loggedInUser.email);
      DocumentSnapshot doc = await docRef.get();
      final data = await doc.data() as Map<String, dynamic>;

      data.forEach((key, value) {
        // goes through each date
        data[key].forEach((drinkType, timeAndAmount) {
          // goes through each drink type
          int sum = 0;
          timeAndAmount.forEach((time, amount) {
            //each time and amount
            sum += amount as int;
          });
          listOfDrinks.add(Event("$drinkType: ${sum.toString()} oz")); //adding each drink to the list
        });
        events[DateTime.parse("$key 00:00:00.000")] = listOfDrinks.toList(); //create the event
        listOfDrinks.clear(); //clear the drinks for the next event
      });
    } catch (e) {
      print(e);
    }
    return events;
  }
}
