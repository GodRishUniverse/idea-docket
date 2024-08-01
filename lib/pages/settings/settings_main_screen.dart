import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/data_management/complete_user_data_deletion.dart';
import 'package:idea_docket/pages/settings/colour_blindness_settings.dart';
import 'package:idea_docket/pages/settings/settings_item.dart';
import 'package:idea_docket/pages/settings/text_to_speech_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDrawerOpen;
  const SettingsScreen({
    super.key,
    required this.isDrawerOpen,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int selectedIndex = -1; // fix hover

  int colourBlindnessIndex = 0;

  Future initColourBlindnessIndex() async {
    final prefs = await SharedPreferences.getInstance();

    colourBlindnessIndex = prefs.getInt('colourBlindnessChosen') ?? 0;
  }

  @override
  void initState() {
    initColourBlindnessIndex();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.isDrawerOpen ? 40 : 0),
          color: colorBlindness(
            whiteUsed,
            returnColorBlindNessTypeFromIndex(
              colourBlindnessIndex,
            ),
          ),
        ),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 60),
        child: Column(
          children: [
            const Text(
              "Settings",
              style: TextStyle(
                fontFamily: "GilroyBold",
                fontSize: 34,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              children: SettingsItem.all
                  .asMap()
                  .map((index, item) => MapEntry(
                        index,
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 5,
                            top: 5,
                          ),
                          child: GestureDetector(
                            onTapDown: (_) {
                              setState(() {
                                selectedIndex = index; // Update touched index
                              });
                            },
                            onTapCancel: () {
                              setState(() {
                                selectedIndex = -1; // Reset touched index
                              });
                            },
                            onTapUp: (_) {
                              setState(() {
                                selectedIndex = -1; // Reset touched index
                              });
                            },
                            onTap: () {
                              switch (index) {
                                case 0:
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const TextToSpeechSettings()));
                                  break;

                                case 1:
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const ColourBlindnessSettings()));
                                  break;

                                case 2:
                                  dialogForDeletionOfAccount(context);
                                  break;
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: colorBlindness(
                                    blueUsedInLinks,
                                    returnColorBlindNessTypeFromIndex(
                                      colourBlindnessIndex,
                                    ),
                                  ),
                                ),
                                color: (selectedIndex ==
                                            SettingsItem.all.length - 1 &&
                                        index == SettingsItem.all.length - 1)
                                    ? colorBlindness(
                                        redUsed,
                                        returnColorBlindNessTypeFromIndex(
                                          colourBlindnessIndex,
                                        ),
                                      )
                                    : (selectedIndex == index)
                                        ? colorBlindness(
                                            blueUsedInLinks,
                                            returnColorBlindNessTypeFromIndex(
                                              colourBlindnessIndex,
                                            ),
                                          )
                                        : null,
                              ),
                              child: ListTile(
                                leading: item.icon,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 10,
                                ),
                                title: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: (selectedIndex == index)
                                        ? colorBlindness(
                                            whiteUsed,
                                            returnColorBlindNessTypeFromIndex(
                                              colourBlindnessIndex,
                                            ),
                                          )
                                        : blackUsed,
                                    fontFamily: "GilroyBold",
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ))
                  .values
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> dialogForDeletionOfAccount(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete your Account?'),
          content: const Text(
              '''If you select Delete we will delete your account on our server.

Your app data will also be deleted and you won't be able to retrieve it.

You might be asked to login before your account can be deleted.'''),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(
                  color: colorBlindness(
                    redUsed,
                    returnColorBlindNessTypeFromIndex(
                      colourBlindnessIndex,
                    ),
                  ),
                ),
              ),
              onPressed: () async {
                CompleteUserDataDeletion completeUserDataDeletion =
                    CompleteUserDataDeletion();
                await completeUserDataDeletion.deleteUserAccount();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      },
    );
  }
}
