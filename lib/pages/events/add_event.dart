import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';

import 'package:idea_docket/theme/colours.dart';

import 'package:idea_docket/data_management/firestore_events_crud.dart';
import 'package:idea_docket/google_calendar_sync/calendar_client.dart';
import 'package:idea_docket/misc/signed_in_with_google_check.dart';

import 'package:idea_docket/models/event_model.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({
    super.key,
  });

  @override
  State<AddEvent> createState() => _AddEventState();
}

extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay addHour(int hour) {
    return replacing(hour: this.hour + hour, minute: minute);
  }
}

class _AddEventState extends State<AddEvent> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now().addHour(1);
  final dateFormatter = DateFormat.yMMMMd();

  final FirestoreServiceForEvents firestoreServiceForEvents =
      FirestoreServiceForEvents();

  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController descController = TextEditingController();

  int colourBlindnessIndex = 0;

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2999),
    );

    if (picked != null) {
      setState(() {
        dateController.text = dateFormatter.format(picked);
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final localizations = MaterialLocalizations.of(context);
    TimeOfDay? pickedStartTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (pickedStartTime != null) {
      setState(() {
        startTimeController.text =
            localizations.formatTimeOfDay(pickedStartTime);
        selectedStartTime = pickedStartTime;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final localizations = MaterialLocalizations.of(context);
    TimeOfDay? pickedEndTime = await showTimePicker(
        context: context, initialTime: selectedStartTime.addHour(1));

    if (pickedEndTime != null) {
      setState(() {
        endTimeController.text = localizations.formatTimeOfDay(pickedEndTime);
        selectedEndTime = pickedEndTime;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initColourBlindnessIndex();
  }

  Future initColourBlindnessIndex() async {
    final prefs = await SharedPreferences.getInstance();

    colourBlindnessIndex = prefs.getInt('colourBlindnessChosen') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Hero(
          tag: 'add-event',
          child: Material(
            color: colorBlindness(
              greyUsed,
              returnColorBlindNessTypeFromIndex(
                colourBlindnessIndex,
              ),
            ),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Create New Event",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'GilroyBold',
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Add your form fields or other content here
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: TextStyle(
                          color: colorBlindness(
                            whiteUsed,
                            returnColorBlindNessTypeFromIndex(
                              colourBlindnessIndex,
                            ),
                          ).withOpacity(0.75),
                          fontFamily: 'GilroyBold',
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colorBlindness(
                              whiteUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colorBlindness(
                              orangeUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      style: TextStyle(
                        color: colorBlindness(
                          whiteUsed,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                        fontFamily: 'Gilroy',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dateController,
                      onTap: () {
                        _selectDate();
                      },
                      decoration: InputDecoration(
                        hintText: 'Date',
                        hintStyle: TextStyle(
                          color: colorBlindness(
                            whiteUsed,
                            returnColorBlindNessTypeFromIndex(
                              colourBlindnessIndex,
                            ),
                          ).withOpacity(0.75),
                          fontFamily: 'GilroyBold',
                        ),
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: colorBlindness(
                            whiteUsed,
                            returnColorBlindNessTypeFromIndex(
                              colourBlindnessIndex,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colorBlindness(
                              whiteUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colorBlindness(
                              orangeUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      style: TextStyle(
                        color: colorBlindness(
                          whiteUsed,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                        fontFamily: 'Gilroy',
                      ),
                      readOnly: true,
                    ),

                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: startTimeController,
                              onTap: () {
                                _selectStartTime();
                              },
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.schedule,
                                  color: colorBlindness(
                                    whiteUsed,
                                    returnColorBlindNessTypeFromIndex(
                                      colourBlindnessIndex,
                                    ),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorBlindness(
                                      whiteUsed,
                                      returnColorBlindNessTypeFromIndex(
                                        colourBlindnessIndex,
                                      ),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorBlindness(
                                      orangeUsed,
                                      returnColorBlindNessTypeFromIndex(
                                        colourBlindnessIndex,
                                      ),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                hintText: 'Start Time',
                                hintStyle: TextStyle(
                                  color: colorBlindness(
                                    whiteUsed,
                                    returnColorBlindNessTypeFromIndex(
                                      colourBlindnessIndex,
                                    ),
                                  ).withOpacity(0.75),
                                  fontFamily: 'GilroyBold',
                                ),
                              ),
                              style: TextStyle(
                                color: colorBlindness(
                                  whiteUsed,
                                  returnColorBlindNessTypeFromIndex(
                                    colourBlindnessIndex,
                                  ),
                                ),
                                fontFamily: 'Gilroy',
                              ),
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextField(
                              controller: endTimeController,
                              onTap: () {
                                _selectEndTime();
                              },
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock_clock,
                                  color: colorBlindness(
                                    whiteUsed,
                                    returnColorBlindNessTypeFromIndex(
                                      colourBlindnessIndex,
                                    ),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorBlindness(
                                      whiteUsed,
                                      returnColorBlindNessTypeFromIndex(
                                        colourBlindnessIndex,
                                      ),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorBlindness(
                                      orangeUsed,
                                      returnColorBlindNessTypeFromIndex(
                                        colourBlindnessIndex,
                                      ),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                hintText: 'End Time',
                                hintStyle: TextStyle(
                                  color: colorBlindness(
                                    whiteUsed,
                                    returnColorBlindNessTypeFromIndex(
                                      colourBlindnessIndex,
                                    ),
                                  ).withOpacity(0.75),
                                  fontFamily: 'GilroyBold',
                                ),
                              ),
                              style: TextStyle(
                                color: colorBlindness(
                                  whiteUsed,
                                  returnColorBlindNessTypeFromIndex(
                                    colourBlindnessIndex,
                                  ),
                                ),
                                fontFamily: 'Gilroy',
                              ),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        hintText: 'Description',
                        hintStyle: TextStyle(
                          color: colorBlindness(
                            whiteUsed,
                            returnColorBlindNessTypeFromIndex(
                              colourBlindnessIndex,
                            ),
                          ).withOpacity(0.75),
                          fontFamily: 'GilroyBold',
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colorBlindness(
                              whiteUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: colorBlindness(
                              orangeUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      style: TextStyle(
                        color: colorBlindness(
                          whiteUsed,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                        fontFamily: 'Gilroy',
                      ),
                      minLines: 3,
                      maxLines: null,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: GestureDetector(
                        onTap: () async {
                          addEvent();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            color: colorBlindness(
                              orangeUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Add Event",
                              style: TextStyle(
                                color: colorBlindness(
                                  whiteUsed,
                                  returnColorBlindNessTypeFromIndex(
                                    colourBlindnessIndex,
                                  ),
                                ),
                                fontFamily: "GilroyBold",
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future addEvent() async {
    DateTime dateWithStartTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedStartTime.hour,
      selectedStartTime.minute,
    );

    DateTime dateWithEndTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedEndTime.hour,
      selectedEndTime.minute,
    );

    int lastId = await firestoreServiceForEvents.getLastStoredValue();
    if (!dateWithStartTime.isBefore(DateTime.now())) {
      if (!dateWithEndTime.isBefore(DateTime.now())) {
        if (!dateWithEndTime.isBefore(dateWithStartTime)) {
          final event = Event(
            id: lastId + 1,
            title: titleController.text.trim(),
            description: descController.text.trim(),
            date: Timestamp.fromDate(DateTime(
                selectedDate.year, selectedDate.month, selectedDate.day)),
            dateWithStartTime: Timestamp.fromDate(dateWithStartTime),
            dateWithEndTime: Timestamp.fromDate(dateWithEndTime),
            color: getRandomLightColour(),
          );

          DocumentReference ref =
              await firestoreServiceForEvents.addEvent(event);

          if (await SignedInWithGoogleCheck.isSignedInWithGoogle()) {
            final eventWithDocID = Event(
              docID: ref.id,
              id: event.id,
              title: event.title,
              description: event.description,
              date: event.date,
              dateWithStartTime: event.dateWithStartTime,
              dateWithEndTime: event.dateWithEndTime,
              color: event.color,
            );

            GoogleCalendarClient calendarClient = GoogleCalendarClient();
            await calendarClient.calendarAPI();
            calendarClient.insert(eventWithDocID);
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context);
          });
        } else {
          errorBoxWhenAdding('Start time cannot be after end time.');
        }
      } else {
        errorBoxWhenAdding('End time cannot be before current time.');
      }
    } else {
      errorBoxWhenAdding('Start time cannot be before current time.');
    }
  }

  Future<dynamic> errorBoxWhenAdding(String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        icon: const Icon(
          Icons.error,
          color: redUsed,
          size: 20,
        ),
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
