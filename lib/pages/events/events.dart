import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idea_docket/theme/colours.dart';

import 'package:idea_docket/data_management/firestore_events_crud.dart';
import 'package:idea_docket/misc/hero_dialogue_route.dart';
import 'package:idea_docket/misc/snack_bar.dart';

import 'package:idea_docket/models/event_model.dart';
import 'package:idea_docket/pages/events/add_event.dart';
import 'package:idea_docket/pages/events/calendar_widget/calendar_view.dart';
import 'package:idea_docket/pages/events/cubits/event_selected_date_cubit.dart';
import 'package:idea_docket/pages/events/edit_event.dart';
import 'package:idea_docket/pages/events/event_card.dart';
import 'package:idea_docket/pages/events/notification_handling/notification_handling.dart';
import 'package:idea_docket/pages/events/past_events.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventsScreen extends StatefulWidget {
  final bool isDrawerOpen;

  const EventsScreen({
    super.key,
    required this.isDrawerOpen,
  });

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _currentDate = DateTime.now();
  final _dayFormatter = DateFormat('d');
  final _weekdayFormatter = DateFormat('E');

  int? _selectedIndex = 0;

  final PageController _pageController = PageController();

  final _monthAndYearFormatter = DateFormat('yMMMM');
  DateTime dateInViewForMonthAndYearDisplay = DateTime.now();

  final FirestoreServiceForEvents firestoreServiceForEvents =
      FirestoreServiceForEvents();

  int colourBlindnessIndex = 0;

  @override
  void initState() {
    super.initState();
    initColourBlindnessIndex();
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  Future initColourBlindnessIndex() async {
    final prefs = await SharedPreferences.getInstance();

    colourBlindnessIndex = prefs.getInt('colourBlindnessChosen') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateCubit = BlocProvider.of<EventSelectedDateCubit>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.isDrawerOpen ? 40 : 0),
          color: colorBlindness(
            darkBackground,
            returnColorBlindNessTypeFromIndex(
              colourBlindnessIndex,
            ),
          ),
        ),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 60),
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          "Events",
                          style: TextStyle(
                            fontFamily: "GilroyBold",
                            fontSize: 30,
                            color: colorBlindness(
                              whiteUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      _monthAndYearFormatter
                          .format(dateInViewForMonthAndYearDisplay),
                      style: TextStyle(
                        fontFamily: "GilroyBold",
                        fontSize: 24,
                        color: colorBlindness(
                          whiteUsed,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: SizedBox(
                    height: 75,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (pageIndex) {
                        setState(() {
                          dateInViewForMonthAndYearDisplay = DateTime(
                              _currentDate.year,
                              _currentDate.month,
                              _currentDate.day + pageIndex * 5);
                        });
                      },
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, pageIndex) {
                        return Row(
                          children: List.generate(5, (index) {
                            int actualIndex = pageIndex * 5 + index;
                            DateTime dateForItem = DateTime(
                                _currentDate.year,
                                _currentDate.month,
                                _currentDate.day + actualIndex);

                            return GestureDetector(
                              onTap: () async {
                                setState(
                                  () {
                                    _selectedIndex = actualIndex;
                                    dateInViewForMonthAndYearDisplay =
                                        dateForItem;
                                  },
                                );
                                // Using Cubit for date state management
                                selectedDateCubit.selectDate(dateForItem);
                              },
                              child: DateDisplayWidget(
                                dayFormatter: _dayFormatter,
                                date: DateTime(
                                    _currentDate.year,
                                    _currentDate.month,
                                    _currentDate.day + actualIndex),
                                weekdayFormatter: _weekdayFormatter,
                                selected: _selectedIndex == actualIndex,
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: colorBlindness(
                            whiteUsed,
                            returnColorBlindNessTypeFromIndex(
                              colourBlindnessIndex,
                            ),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(30),
                            topRight: const Radius.circular(30),
                            bottomLeft:
                                Radius.circular(widget.isDrawerOpen ? 40 : 0),
                            bottomRight:
                                Radius.circular(widget.isDrawerOpen ? 40 : 0),
                          ),
                        ),
                        child: BlocBuilder<EventSelectedDateCubit, DateTime>(
                            builder: (context, date) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: buildEvents(date),
                          );
                        }),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          height: 75,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                colorBlindness(
                                  whiteUsed,
                                  returnColorBlindNessTypeFromIndex(
                                    colourBlindnessIndex,
                                  ),
                                ).withOpacity(0.85),
                                colorBlindness(
                                  whiteUsed,
                                  returnColorBlindNessTypeFromIndex(
                                    colourBlindnessIndex,
                                  ),
                                ).withOpacity(0.55)
                              ],
                            ),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                    widget.isDrawerOpen ? 40 : 0),
                                bottomRight: Radius.circular(
                                    widget.isDrawerOpen ? 40 : 0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10, left: 40, right: 40, bottom: 10),
                            child: GestureDetector(
                              onTap: () async {
                                Navigator.of(context)
                                    .push(HeroDialogueRoute(builder: (context) {
                                  return const AddEvent();
                                }));
                              },
                              child: Hero(
                                tag: 'add-event',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: blackUsed,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.event_seat,
                                          color: colorBlindness(
                                            whiteUsed,
                                            returnColorBlindNessTypeFromIndex(
                                              colourBlindnessIndex,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Create New Event",
                                              style: TextStyle(
                                                color: colorBlindness(
                                                  whiteUsed,
                                                  returnColorBlindNessTypeFromIndex(
                                                    colourBlindnessIndex,
                                                  ),
                                                ),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 20,
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: colorBlindness(
                      greyUsed,
                      returnColorBlindNessTypeFromIndex(
                        colourBlindnessIndex,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PastEventsScreen()));
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          width: 35,
                          height: 35,
                          child: Image.asset("assets/archive.png"),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          "Past Events",
                          style: TextStyle(
                            color: colorBlindness(
                              whiteUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 120,
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: colorBlindness(
                      greyUsed,
                      returnColorBlindNessTypeFromIndex(
                        colourBlindnessIndex,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: buildEventsForCalendar,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 35,
                          height: 35,
                          child: Image.asset("assets/calendar.png"),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          "Calendar View",
                          style: TextStyle(
                            color: colorBlindness(
                              whiteUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEvents(DateTime date) => StreamBuilder<QuerySnapshot>(
        stream: firestoreServiceForEvents.getEventsStreamAccordingToDate(date),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: colorBlindness(
                orangeUsed,
                returnColorBlindNessTypeFromIndex(
                  colourBlindnessIndex,
                ),
              ),
            ));
          } else if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showSnackBarError(context, snapshot.error.toString());
            });

            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            List eventsList = snapshot.data!.docs;

            if (eventsList.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 80,
                    ),
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: Image.asset(
                        "assets/events_not_created.png",
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'No Events created',
                      style: TextStyle(
                        color: colorBlindness(
                          greyUsed,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              );
            }

            final today = DateTime.now();

            return Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: ListView.separated(
                itemCount: eventsList.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(
                        height: 10), // Adjust the spacing between tiles
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot documentSnapshot = eventsList[index];
                  String docId = documentSnapshot.id;
                  Map<String, dynamic> data =
                      documentSnapshot.data() as Map<String, dynamic>;
                  int id = data['id'];
                  String title = data['title'];
                  String contents = data['description'];
                  Timestamp date = data['date'];
                  Timestamp startTime = data['dateWithStartTime'];
                  Timestamp endTime = data['dateWithEndTime'];
                  int color = data['color'];

                  final event = Event(
                    docID: docId,
                    id: id,
                    title: title,
                    description: contents,
                    date: date,
                    dateWithStartTime: startTime,
                    dateWithEndTime: endTime,
                    color: colorBlindness(
                      Color(color),
                      returnColorBlindNessTypeFromIndex(
                        colourBlindnessIndex,
                      ),
                    ),
                  );

                  // Check if the event is today
                  final eventDate = event.date.toDate();
                  final isToday = eventDate.year == today.year &&
                      eventDate.month == today.month &&
                      eventDate.day == today.day;

                  if (isToday) {
                    scheduleNotification(event);
                  }

                  return GestureDetector(
                    onTap: () async {
                      Navigator.of(context).push(
                        HeroDialogueRoute(builder: (context) {
                          return EventsViewingScreen(
                            event: event,
                          );
                        }),
                      );
                    },
                    child: Hero(
                      tag: event.docID!,
                      child: EventCardWidget(
                        event: event,
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Text('No events found');
          }
        },
      );

  void buildEventsForCalendar() {
    firestoreServiceForEvents.getAllEvents().listen((querySnapshot) {
      List eventsList = querySnapshot.docs;

      List<Event> accEventList = eventsList.map((documentSnapshot) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        int id = data['id'];
        String title = data['title'];
        String contents = data['description'];
        Timestamp date = data['date'];
        Timestamp startTime = data['dateWithStartTime'];
        Timestamp endTime = data['dateWithEndTime'];
        int color = data['color'];

        final event = Event(
          id: id,
          title: title,
          description: contents,
          date: date,
          dateWithStartTime: startTime,
          dateWithEndTime: endTime,
          color: colorBlindness(
            Color(color),
            returnColorBlindNessTypeFromIndex(
              colourBlindnessIndex,
            ),
          ),
        );

        return event;
      }).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CalenderWidgetForEvents(
            events: accEventList,
          ),
        ),
      );
    });
  }
}

class DateDisplayWidget extends StatefulWidget {
  const DateDisplayWidget({
    super.key,
    required DateFormat dayFormatter,
    required this.date,
    required DateFormat weekdayFormatter,
    required this.selected,
  })  : _dayFormatter = dayFormatter,
        _weekdayFormatter = weekdayFormatter;

  final DateFormat _dayFormatter;
  final DateTime date;
  final DateFormat _weekdayFormatter;
  final bool selected;
  @override
  State<DateDisplayWidget> createState() => _DateDisplayWidgetState();
}

class _DateDisplayWidgetState extends State<DateDisplayWidget> {
  int colourBlindnessIndex = 0;

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
    return Row(
      children: [
        const SizedBox(
          width: 6,
        ),
        Container(
          width: 60,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: widget.selected
                ? colorBlindness(
                    orangeUsed,
                    returnColorBlindNessTypeFromIndex(
                      colourBlindnessIndex,
                    ),
                  )
                : colorBlindness(
                    greyUsed,
                    returnColorBlindNessTypeFromIndex(
                      colourBlindnessIndex,
                    ),
                  ).withOpacity(0.85),
          ),
          child: Column(
            children: [
              Text(
                widget._dayFormatter.format(widget.date),
                style: TextStyle(
                  fontFamily: "Gilroy",
                  fontSize: 22,
                  color: colorBlindness(
                    whiteUsed,
                    returnColorBlindNessTypeFromIndex(
                      colourBlindnessIndex,
                    ),
                  ),
                ),
              ),
              Text(
                widget._weekdayFormatter.format(widget.date),
                style: TextStyle(
                  fontFamily: "Gilroy",
                  fontSize: 12,
                  color: colorBlindness(
                    whiteUsed,
                    returnColorBlindNessTypeFromIndex(
                      colourBlindnessIndex,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 6,
        ),
      ],
    );
  }
}
