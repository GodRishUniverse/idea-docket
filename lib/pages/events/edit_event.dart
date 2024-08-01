import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/data_management/firestore_events_crud.dart';
import 'package:idea_docket/google_calendar_sync/calendar_client.dart';
import 'package:idea_docket/misc/signed_in_with_google_check.dart';

import 'package:idea_docket/models/event_model.dart';
import 'package:idea_docket/pages/events/notification_handling/notification_handling.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventsViewingScreen extends StatefulWidget {
  final Event event;

  const EventsViewingScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventsViewingScreen> createState() => _EventsViewingScreenState();
}

class _EventsViewingScreenState extends State<EventsViewingScreen> {
  DateTime selectedDate = DateTime.now();
  late TimeOfDay selectedStartTime;
  late TimeOfDay selectedEndTime;
  final dateFormatter = DateFormat.yMMMMd();
  final timeFormatter = DateFormat.jm();

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
      initialDate: widget.event.date.toDate(),
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
    TimeOfDay startTime =
        TimeOfDay.fromDateTime(widget.event.dateWithStartTime.toDate());
    TimeOfDay? pickedStartTime =
        await showTimePicker(context: context, initialTime: startTime);

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
    TimeOfDay endTime =
        TimeOfDay.fromDateTime(widget.event.dateWithEndTime.toDate());
    TimeOfDay? pickedEndTime =
        await showTimePicker(context: context, initialTime: endTime);

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
    titleController.text = widget.event.title;
    descController.text = widget.event.description;
    dateController.text = dateFormatter.format(widget.event.date.toDate());
    startTimeController.text =
        timeFormatter.format(widget.event.dateWithStartTime.toDate());
    endTimeController.text =
        timeFormatter.format(widget.event.dateWithEndTime.toDate());
    selectedStartTime =
        TimeOfDay.fromDateTime(widget.event.dateWithStartTime.toDate());
    selectedEndTime =
        TimeOfDay.fromDateTime(widget.event.dateWithEndTime.toDate());

    initColourBlindnessIndex();
  }

  Future initColourBlindnessIndex() async {
    final prefs = await SharedPreferences.getInstance();

    colourBlindnessIndex = prefs.getInt('colourBlindnessChosen') ?? 0;
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Hero(
          tag: widget.event.docID!,
          child: Material(
            color: colorBlindness(
              widget.event.color,
              returnColorBlindNessTypeFromIndex(
                colourBlindnessIndex,
              ),
            ),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Update Event",
                      style: TextStyle(
                        color: blackUsed,
                        fontSize: 30,
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
                          color: blackUsed.withOpacity(0.75),
                          fontFamily: 'GilroyBold',
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: blackUsed,
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
                      style: const TextStyle(
                        color: blackUsed,
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
                          color: blackUsed.withOpacity(0.75),
                          fontFamily: 'GilroyBold',
                        ),
                        prefixIcon: const Icon(
                          Icons.calendar_today,
                          color: blackUsed,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: blackUsed,
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
                      style: const TextStyle(
                        color: blackUsed,
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
                                prefixIcon: const Icon(
                                  Icons.schedule,
                                  color: blackUsed,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: blackUsed,
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
                                  color: blackUsed.withOpacity(0.75),
                                  fontFamily: 'GilroyBold',
                                ),
                              ),
                              style: const TextStyle(
                                color: blackUsed,
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
                                prefixIcon: const Icon(
                                  Icons.lock_clock,
                                  color: blackUsed,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: blackUsed,
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
                                  color: blackUsed.withOpacity(0.75),
                                  fontFamily: 'GilroyBold',
                                ),
                              ),
                              style: const TextStyle(
                                color: blackUsed,
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
                          color: blackUsed.withOpacity(0.75),
                          fontFamily: 'GilroyBold',
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: blackUsed,
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
                      style: const TextStyle(
                        color: blackUsed,
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
                          updateEvent(widget.event.docID!);
                        },
                        child: Center(
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
                            child: Row(
                              children: [
                                Icon(
                                  Icons.draw,
                                  color: colorBlindness(
                                    whiteUsed,
                                    returnColorBlindNessTypeFromIndex(
                                      colourBlindnessIndex,
                                    ),
                                  ),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Update Event",
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
                              ],
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

  Future updateEvent(String docID) async {
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

    if (!dateWithStartTime.isBefore(DateTime.now())) {
      if (!dateWithEndTime.isBefore(DateTime.now())) {
        if (!dateWithEndTime.isBefore(dateWithStartTime)) {
          final eventDate = Timestamp.fromDate(DateTime(
              selectedDate.year, selectedDate.month, selectedDate.day));
          final today = DateTime.now();
          final event = Event(
            id: widget.event.id,
            title: titleController.text.trim(),
            description: descController.text.trim(),
            date: eventDate,
            dateWithStartTime: Timestamp.fromDate(dateWithStartTime),
            dateWithEndTime: Timestamp.fromDate(dateWithEndTime),
            color: widget.event.color,
          );

          await firestoreServiceForEvents.updateEvent(docID, event);

          final isToday = eventDate.toDate().year == today.year &&
              eventDate.toDate().month == today.month &&
              eventDate.toDate().day == today.day;

          if (isToday) {
            cancelNotification(event.id);
            scheduleNotification(event);
          }

          if (await SignedInWithGoogleCheck.isSignedInWithGoogle()) {
            final eventWithDocID = Event(
              docID: docID,
              id: widget.event.id,
              title: titleController.text.trim(),
              description: descController.text.trim(),
              date: eventDate,
              dateWithStartTime: Timestamp.fromDate(dateWithStartTime),
              dateWithEndTime: Timestamp.fromDate(dateWithEndTime),
              color: widget.event.color,
            );
            GoogleCalendarClient googleCalendarClient = GoogleCalendarClient();
            await googleCalendarClient.calendarAPI();
            String eventIdFromGoogle = await googleCalendarClient.search(docID);
            googleCalendarClient.update(eventIdFromGoogle, eventWithDocID);
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
        icon: Icon(
          Icons.error,
          color: colorBlindness(
            redUsed,
            returnColorBlindNessTypeFromIndex(
              colourBlindnessIndex,
            ),
          ),
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
