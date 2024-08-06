import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/data_management/firestore_events_crud.dart';
import 'package:idea_docket/models/event_model.dart';
import 'package:idea_docket/pages/events/event_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PastEventsScreen extends StatefulWidget {
  const PastEventsScreen({super.key});

  @override
  State<PastEventsScreen> createState() => _PastEventsScreenState();
}

class _PastEventsScreenState extends State<PastEventsScreen> {
  final date =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  final FirestoreServiceForEvents firestoreServiceForEvents =
      FirestoreServiceForEvents();

  int colourBlindnessIndex = 0;

  @override
  void initState() {
    initColourBlindnessIndex();
    super.initState();
  }

  Future initColourBlindnessIndex() async {
    final prefs = await SharedPreferences.getInstance();

    colourBlindnessIndex = prefs.getInt('colourBlindnessChosen') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorBlindness(
          darkBackground,
          returnColorBlindNessTypeFromIndex(
            colourBlindnessIndex,
          ),
        ),
        foregroundColor: colorBlindness(
          orangeUsed,
          returnColorBlindNessTypeFromIndex(
            colourBlindnessIndex,
          ),
        ),
        title: const Text("Past Events"),
      ),
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: colorBlindness(
            whiteUsed,
            returnColorBlindNessTypeFromIndex(
              colourBlindnessIndex,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: buildEvents(date),
        ),
      ),
    );
  }

  Widget buildEvents(DateTime date) => StreamBuilder<QuerySnapshot>(
        stream:
            firestoreServiceForEvents.getEventsStreamBeforeSpecifiedDate(date),
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
                        "assets/not_found.png",
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'There are no old events present!',
                      style: TextStyle(
                        color: greyUsed,
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              );
            }

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

                  return EventCardWidget(
                    event: event,
                  );
                },
              ),
            );
          } else {
            return const Text('No events found');
          }
        },
      );
}
