import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:idea_docket/models/event_model.dart';

class FirestoreServiceForEvents {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // get collection of events

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper method to get the user's events collection
  CollectionReference get events {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return _firestore.collection('users').doc(user.uid).collection('events');
  }

  // CREATE

  Future<DocumentReference> addEvent(Event event) {
    return events.add({
      'id': event.id,
      'title': event.title,
      'description': event.description,
      'date': event.date,
      'dateWithStartTime': event.dateWithStartTime,
      'dateWithEndTime': event.dateWithEndTime,
      'color': event.color.value
    });
  }

  // READ

  Stream<QuerySnapshot> getAllEvents() {
    final eventsStream = events.snapshots();
    return eventsStream;
  }

  Stream<QuerySnapshot> getEventsStreamBeforeToday() {
    final currDate = DateTime.now();
    final eventsStream = events
        .orderBy(
          'dateWithStartTime',
        )
        .where('date',
            isLessThan: Timestamp.fromDate(DateTime(
              currDate.year,
              currDate.month,
              currDate.day,
            )))
        .snapshots();
    return eventsStream;
  }

  Stream<QuerySnapshot> getEventsStreamAccordingToDate(DateTime date) {
    final searchStream = events
        .orderBy(
          'dateWithStartTime',
        )
        .where('date', isEqualTo: Timestamp.fromDate(date))
        .snapshots();
    return searchStream;
  }

  Stream<QuerySnapshot> getEventsStreamBeforeSpecifiedDate(DateTime date) {
    final searchStream = events
        .orderBy(
          'date',
        )
        .where('date', isLessThan: Timestamp.fromDate(date))
        .snapshots();
    return searchStream;
  }

  // UPDATE

  Future<void> updateEvent(String docID, Event event) async {
    return events.doc(docID).update({
      'id': event.id,
      'title': event.title,
      'description': event.description,
      'date': event.date,
      'dateWithStartTime': event.dateWithStartTime,
      'dateWithEndTime': event.dateWithEndTime,
      'color': event.color.value,
    });
  }

  // DELETE

  Future<void> deleteEvent(String docID) async {
    return events.doc(docID).delete();
  }

  Future<int> getLastStoredValue() async {
    QuerySnapshot querySnapshot =
        await events.orderBy('id', descending: true).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      var document = querySnapshot.docs.first;
      return document['id'];
    } else {
      return 0;
    }
  }
}
