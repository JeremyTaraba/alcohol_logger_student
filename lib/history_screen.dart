import 'dart:collection';

import 'package:alcohol_logger/utility/bottomNav.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:alcohol_logger/utility/calendar_utils.dart';

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
                return TableCalendar(
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
                );
              }),
          bottomNavigationBar: BottomNav(
            selectedIndex: 2,
          ),
        ),
      ),
    );
  }

  getDrinks() {}
}
