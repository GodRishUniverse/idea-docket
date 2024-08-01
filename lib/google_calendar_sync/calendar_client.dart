import 'dart:developer';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';

import 'package:googleapis_auth/googleapis_auth.dart';

import 'package:idea_docket/models/event_model.dart' as event_model;

class GoogleCalendarClient {
  late CalendarApi calendarApi;

  late String currentTimeZone;

  void insert(event_model.Event event) {
    Event eventToBeAdded = Event(
      description: event.description,
      summary: event.title,
      start: EventDateTime(
        dateTime: event.dateWithStartTime.toDate().toUtc(),
        timeZone: currentTimeZone,
      ),
      end: EventDateTime(
        dateTime: event.dateWithEndTime.toDate().toUtc(),
        timeZone: currentTimeZone,
      ),
      extendedProperties: EventExtendedProperties(
        private: {"docID": event.docID!},
      ),
    );

    calendarApi.events.insert(eventToBeAdded, "primary");
  }

  void delete(String eventId) {
    calendarApi.events.delete("primary", eventId);
  }

  void update(String eventId, event_model.Event event) {
    Event eventToBeAdded = Event(
      description: event.description,
      summary: event.title,
      start: EventDateTime(
        dateTime: event.dateWithStartTime.toDate().toUtc(),
        timeZone: currentTimeZone,
      ),
      end: EventDateTime(
        dateTime: event.dateWithEndTime.toDate().toUtc(),
        timeZone: currentTimeZone,
      ),
      extendedProperties: EventExtendedProperties(
        private: {"docID": event.docID!},
      ),
    );

    calendarApi.events.update(
      eventToBeAdded,
      "primary",
      eventId,
    );
  }

  Future<String> search(String docID) async {
    Events events = await calendarApi.events.list("primary");

    Event filteredEvent = events.items!.where((event) {
      return event.extendedProperties?.private?['docID'] == docID;
    }).toList()[0];

    return filteredEvent.id!;
  }

  Future<void> calendarAPI() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/calendar',
      ],
    );

    GoogleSignInAccount? user = await googleSignIn.signIn();
    if (user == null) {
      log('Sign-in failed');
      return;
    }

    AuthClient? authClient = await googleSignIn.authenticatedClient();
    if (authClient == null) {
      log('Failed to get authenticated client');
      return;
    }

    calendarApi = CalendarApi(authClient);

    currentTimeZone = await FlutterTimezone.getLocalTimezone();
  }
}
