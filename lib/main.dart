import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:idea_docket/auth/main_page.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/pages/events/cubits/event_selected_date_cubit.dart';
import 'package:idea_docket/pages/notes/cubits/attachment_urls_cubit.dart';
import 'package:idea_docket/pages/notes/cubits/deleted_file_urls_cubit.dart';
import 'package:idea_docket/pages/notes/cubits/image_permission_cubit.dart';
import 'package:idea_docket/pages/notes/cubits/notes_or_trash_cubit.dart';
import 'package:idea_docket/pages/notes/cubits/temporary_attachment_cubit.dart';
import 'package:idea_docket/pages/settings/cubits/colour_blindness_enabled_cubit.dart';
import 'package:idea_docket/pages/settings/cubits/colour_blindness_theme_manual_or_gemini_cubit.dart';
import 'package:idea_docket/pages/settings/cubits/text_to_speech_enabled_cubit.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await dotenv.load(fileName: ".env");

  tz.initializeTimeZones();

  AwesomeNotifications().initialize(
    // icon should be a drawable resource path in the Android app
    'resource://drawable/appicon',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: blackUsed,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      ),
    ],
  );

  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => EventSelectedDateCubit()),
        BlocProvider(create: (_) => MultimediaPermissionCubit()),
        BlocProvider(create: (_) => TextToSpeechEnabledCubit()),
        BlocProvider(create: (_) => NotesOrTrashCubit()),
        BlocProvider(create: (_) => TemporaryAttachmentForNotesCubit()),
        BlocProvider(create: (_) => AttachmentUrlsCubit()),
        BlocProvider(create: (_) => DeletedFileUrlsCubit()),
        BlocProvider(create: (_) => ColourBlindnessEnabledCubit()),
        BlocProvider(create: (_) => ColourBlindnessThemeManualOrGeminiCubit()),
      ],
      child: MaterialApp(
        title: "Idea-Docket",
        theme: ThemeData(
          fontFamily: 'Gilroy',
        ),
        debugShowCheckedModeBanner: false,
        home: const MainPage(),
      ),
    );
  }
}
