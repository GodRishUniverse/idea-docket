import 'package:color_blindness/color_blindness.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:idea_docket/theme/colours.dart';

import 'package:idea_docket/misc/drawer_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerWidget extends StatelessWidget {
  final ValueChanged<DrawerItem> onSelectedItem;
  const DrawerWidget({
    super.key,
    required this.onSelectedItem,
    required this.colourBlindnessIndex,
  });

  final int colourBlindnessIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildDrawerItems(context),
          ],
        ),
      ),
      backgroundColor: colorBlindness(
        blueForDrawer,
        returnColorBlindNessTypeFromIndex(
          colourBlindnessIndex,
        ),
      ),
    );
  }

  Widget buildDrawerItems(BuildContext context) {
    String user = FirebaseAuth.instance.currentUser!.email!;

    return SafeArea(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 230),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorBlindness(
                      whiteUsed,
                      returnColorBlindNessTypeFromIndex(
                        colourBlindnessIndex,
                      ),
                    ).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: 35,
                          height: 35,
                          child: Image.asset("assets/appicon.png"),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          "Idea Docket",
                          style: TextStyle(
                            color: colorBlindness(
                              orangeUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                            fontFamily: "GilroyBold",
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        colorBlindness(
                          orangeUsed,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                        greyUsedOpacityLowered
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: Wrap(
                      children: [
                        const CircleAvatar(
                          child: Icon(
                            Icons.person_2,
                            size: 30,
                          ),
                        ),
                        Text(
                          user,
                          style: TextStyle(
                            color: colorBlindness(
                              whiteUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                            fontSize: 15,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: DrawerItem.all
                    .map((item) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            leading: item.icon,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(
                                color: colorBlindness(
                                  orangeUsed,
                                  returnColorBlindNessTypeFromIndex(
                                    colourBlindnessIndex,
                                  ),
                                ),
                                fontFamily: "GilroyBold",
                                fontSize: 20,
                              ),
                            ),
                            onTap: () => onSelectedItem(item),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(
                height: 100,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  tileColor: colorBlindness(
                    redUsedForLogOut,
                    returnColorBlindNessTypeFromIndex(
                      colourBlindnessIndex,
                    ),
                  ),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();

                    String signedInWithGoogle = prefs.getString(
                      "signedInWithGoogle",
                    )!;

                    if (signedInWithGoogle == "Yes") {
                      // This forces the user to re-choose the account before signing in
                      GoogleSignIn googleSignIn = GoogleSignIn();
                      googleSignIn.disconnect();
                    }

                    FirebaseAuth.instance.signOut();
                  },
                  title: Center(
                    child: Text(
                      "Logout",
                      style: TextStyle(
                          color: colorBlindness(
                            whiteUsed,
                            returnColorBlindNessTypeFromIndex(
                              colourBlindnessIndex,
                            ),
                          ),
                          fontFamily: 'GilroyBold',
                          fontSize: 22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
