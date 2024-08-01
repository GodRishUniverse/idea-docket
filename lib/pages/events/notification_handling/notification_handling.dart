import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:idea_docket/models/event_model.dart';
import 'package:timezone/timezone.dart' as tz;

void scheduleNotification(Event event) {
  DateTime eventStartTime = event.dateWithStartTime.toDate();
  DateTime now = DateTime.now();

  // Debug log to check the date and time
  log("Scheduling notification for: $eventStartTime");

  if (eventStartTime.isAfter(now)) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: event.id,
        channelKey: 'basic_channel',
        title: event.title,
        body: event.description,
        notificationLayout: NotificationLayout.Default,
        autoDismissible: false,
      ),
      schedule: NotificationCalendar.fromDate(
        date: tz.TZDateTime.from(eventStartTime, tz.local),
        preciseAlarm: true,
      ),
    );
  } else {
    log("Notification time is in the past: $eventStartTime");
  }
}

void cancelNotification(int notificationId) async {
  await AwesomeNotifications().cancel(notificationId);
}
