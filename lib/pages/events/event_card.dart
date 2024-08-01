import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/data_management/firestore_events_crud.dart';
import 'package:idea_docket/google_calendar_sync/calendar_client.dart';
import 'package:idea_docket/misc/signed_in_with_google_check.dart';
import 'package:idea_docket/models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventCardWidget extends StatefulWidget {
  final Event event;
  const EventCardWidget({
    super.key,
    required this.event,
  });

  @override
  State<EventCardWidget> createState() => _EventCardWidgetState();
}

class _EventCardWidgetState extends State<EventCardWidget> {
  FlutterTts flutterTts = FlutterTts();

  bool isTTSEnabledForUser = false;

  int colourBlindnessIndex = 0;

  Future initColourBlindnessIndex() async {
    final prefs = await SharedPreferences.getInstance();

    colourBlindnessIndex = prefs.getInt('colourBlindnessChosen') ?? 0;
  }

  @override
  void initState() {
    getSettings();
    isTTSEnabled();
    initColourBlindnessIndex();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    stop();
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }

  Future getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final speechRate =
        prefs.getDouble('speechRate') ?? 0.5; // Default to 1.0 if not found
    final volume =
        prefs.getDouble('volume') ?? 1.0; // Default to 1.0 if not found
    final pitch =
        prefs.getDouble('pitch') ?? 1.0; // Default to 1.0 if not found
    final language = prefs.getString('languageUsed') ?? 'en-US';

    await flutterTts.setVolume(volume);
    await flutterTts.setPitch(pitch);
    await flutterTts.setSpeechRate(speechRate);
    await flutterTts.setLanguage(language);

    setState(() {});
  }

  void isTTSEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('textToSpeechEnabled') ?? false;
    setState(() {
      isTTSEnabledForUser = isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final time = widget.event.dateWithStartTime;

    final FirestoreServiceForEvents firestoreServiceForEvents =
        FirestoreServiceForEvents();

    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorBlindness(
          widget.event.color,
          returnColorBlindNessTypeFromIndex(
            colourBlindnessIndex,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${DateFormat.jm().format(time.toDate())} - ${DateFormat.jm().format(widget.event.dateWithEndTime.toDate())}",
                  style: TextStyle(
                    color: blackUsed.withOpacity(0.9),
                    fontSize: 17,
                  ),
                ),
                Text(
                  DateFormat.yMMMd().format(time.toDate()),
                  style: TextStyle(
                    color: blackUsed.withOpacity(0.8),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.event.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.event.description,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                  ),
                ),
                Visibility(
                  visible: isTTSEnabledForUser,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        color: colorBlindness(
                          whiteUsed,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await speak(
                              "Event: ${widget.event.title} is scheduled from ${DateFormat.jm().format(widget.event.dateWithStartTime.toDate())} to ${DateFormat.jm().format(widget.event.dateWithEndTime.toDate())} on ${DateFormat.yMMMMd().format(widget.event.date.toDate())}. The event description is ${widget.event.description} ");
                        },
                        icon: Tooltip(
                          message: "Convert the event to speech",
                          child: SizedBox(
                            height: 35,
                            child: Image.asset(
                              "assets/icons/text-to-speech-icon.png",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: colorBlindness(
                      whiteUsed,
                      returnColorBlindNessTypeFromIndex(
                        colourBlindnessIndex,
                      ),
                    ),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      firestoreServiceForEvents
                          .deleteEvent(widget.event.docID!);

                      if (await SignedInWithGoogleCheck
                          .isSignedInWithGoogle()) {
                        GoogleCalendarClient googleCalendarClient =
                            GoogleCalendarClient();

                        await googleCalendarClient.calendarAPI();

                        String eventIdFromGoogle = await googleCalendarClient
                            .search(widget.event.docID!);

                        googleCalendarClient.delete(eventIdFromGoogle);
                      }
                    },
                    icon: Icon(
                      Icons.delete,
                      color: colorBlindness(
                        blueForDrawer,
                        returnColorBlindNessTypeFromIndex(
                          colourBlindnessIndex,
                        ),
                      ),
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
