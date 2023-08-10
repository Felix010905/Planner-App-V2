import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateTime _firstDay = DateTime.utc(2010, 1, 1);
  final DateTime _lastDay = DateTime.utc(2050, 12, 31);
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _eventTextController = TextEditingController();
  final TextEditingController _eventTimeController = TextEditingController();
  final Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _eventTextController.dispose();
    _eventTimeController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String eventsJson = prefs.getString('events') ?? '{}';
    Map<String, dynamic> decodedEvents = json.decode(eventsJson);
    decodedEvents.forEach((date, eventsData) {
      DateTime dateKey = DateTime.parse(date);
      List<Event> events = List<Event>.from(
        eventsData.map((eventData) => Event.fromJson(eventData)),
      );
      setState(() {
        _events[dateKey] = events;
      });
    });
  }

  Future<void> _saveEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> encodedEvents = {};
    _events.forEach((date, events) {
      encodedEvents[date.toIso8601String()] =
          events.map((event) => event.toJson()).toList();
    });
    String eventsJson = json.encode(encodedEvents);
    await prefs.setString('events', eventsJson);
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _addEvent(DateTime day, String eventText, String eventTime) {
    if (day != null && eventText.isNotEmpty) {
      final event = Event(eventText, eventTime);
      setState(() {
        _events[day] ??= [];
        _events[day]!.add(event);
      });
      _saveEvents(); // Save events when added
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          calendarFormat: _calendarFormat,
          firstDay: _firstDay,
          lastDay: _lastDay,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          eventLoader: (day) {
            return _getEventsForDay(day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _showEventDialog(context, selectedDay);
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
        ),
      ],
    );
  }

  Future<void> _showEventDialog(BuildContext context, DateTime selectedDay) async {
    TimeOfDay? selectedStartTime = TimeOfDay.now();
    TimeOfDay? selectedEndTime = TimeOfDay.now();
    bool isAllDayEvent = false;
    int duplicateDays = 1;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Events for ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _eventTextController,
                    decoration: const InputDecoration(labelText: 'Event'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isAllDayEvent,
                        onChanged: (value) {
                          setState(() {
                            isAllDayEvent = value ?? false;
                          });
                        },
                      ),
                      const Text('All day event'),
                    ],
                  ),
                  if (!isAllDayEvent)
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            selectedStartTime = await showTimePicker(
                              context: context,
                              initialTime: selectedStartTime ?? TimeOfDay.now(),
                            );
                            setState(() {});
                          },
                          child: const Text('Start Time'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            selectedEndTime = await showTimePicker(
                              context: context,
                              initialTime: selectedEndTime ?? TimeOfDay.now(),
                            );
                            setState(() {});
                          },
                          child: const Text('End Time'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Duplicate for'),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: duplicateDays,
                        onChanged: (value) {
                          setState(() {
                            duplicateDays = value ?? 1;
                          });
                        },
                        items: List.generate(10, (index) {
                          return DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text('${index + 1} days'),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_eventTextController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a name for the event')),
                        );
                      } else if (!isAllDayEvent && (selectedStartTime == null || selectedEndTime == null)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select start and end times for the event')),
                        );
                      } else {
                        final eventTime = isAllDayEvent
                            ? 'All day'
                            : '${selectedStartTime!.format(context)} - ${selectedEndTime!.format(context)}';

                        _addEvent(
                          selectedDay,
                          _eventTextController.text,
                          eventTime,
                        );

                        // Duplicate event for selected number of days
                        for (int i = 1; i < duplicateDays; i++) {
                          DateTime duplicateDay = selectedDay.add(Duration(days: i));
                          _addEvent(
                            duplicateDay,
                            _eventTextController.text,
                            eventTime,
                          );
                        }

                        _eventTextController.clear();
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add Event'),
                  ),
                  ...(_events[selectedDay] ?? [])
                      .map((event) => ListTile(
                    title: Text('${event.time} - ${event.title}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _removeEvent(selectedDay, event);
                        setState(() {});
                      },
                    ),
                  ))
                      .toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _removeEvent(DateTime day, Event event) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final eventsOnDay = _events[day];
    if (eventsOnDay != null) {
      _events[day] = eventsOnDay.where((e) => e != event).toList();
      if (_events[day]!.isEmpty) {
        _events.remove(day);
      }

      // Remove duplicates of the event from all dates
      _events.forEach((date, events) {
        events.removeWhere((e) => e.title == event.title);
        _prefs.remove('events');
      });
    }
    _saveEvents();
    _selectedDay = null;
  }
}

class Event {
  final String title;
  final String time;

  Event(this.title, this.time);

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(json['title'] ?? '', json['time'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'time': time,
    };
  }
}
