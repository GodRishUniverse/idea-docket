import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import 'package:idea_docket/theme/colours.dart';

import 'package:idea_docket/misc/drawer.dart';
import 'package:idea_docket/misc/drawer_item.dart';
import 'package:idea_docket/pages/events/events.dart';
import 'dart:math' as math;

// import 'package:idea_docket/colors/colours.dart';

import 'package:idea_docket/pages/notes/notes_tab_view.dart';
import 'package:idea_docket/pages/settings/settings_main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser!;
  DrawerItem drawerItem = DrawerItem.notes;
  late AnimationController controllerForDrawerButton;

  late AnimationController? animationController;
  late Animation<double> animation;

  bool isDragging = false;

  bool isDrawerOpen = false;

  int colourBlindnessIndex = 0;

  final springDesc = const SpringDescription(
    mass: 0.1,
    stiffness: 40,
    damping: 5,
  );

  void openDrawer() {
    final springAnim = SpringSimulation(springDesc, 0, 1, 0);

    animationController?.animateWith(springAnim);

    setState(() {
      isDrawerOpen = true;
      controllerForDrawerButton.reverse();
    });
  }

  void closeDrawer() {
    animationController?.reverse();
    setState(() {
      isDrawerOpen = false;
      controllerForDrawerButton.forward();
    });
  }

  Future initColourBlindnessIndex() async {
    final prefs = await SharedPreferences.getInstance();

    colourBlindnessIndex = prefs.getInt('colourBlindnessChosen') ?? 0;
  }

  @override
  void initState() {
    super.initState();

    initColourBlindnessIndex();

    controllerForDrawerButton = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      upperBound: 1,
      vsync: this,
    );

    animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: animationController!,
      curve: Curves.linear,
    ));

    closeDrawer();
  }

  @override
  void dispose() {
    animationController?.dispose();
    controllerForDrawerButton.dispose();
    super.dispose();
  }

  Widget buildDrawer() {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY((1 - animation.value) * (-30) * math.pi / 180)
            ..translate((1 - animation.value) * -300),
          child: child,
        );
      },
      child: FadeTransition(
        opacity: animation,
        child: DrawerWidget(
          onSelectedItem: (item) {
            setState(() {
              drawerItem = item;
              closeDrawer();
            });
          },
          colourBlindnessIndex: colourBlindnessIndex,
        ),
      ),
    );
  }

  Widget buildPage() {
    return GestureDetector(
      onTap: closeDrawer,
      onHorizontalDragStart: (details) => isDragging = true,
      onHorizontalDragUpdate: (details) {
        if (!isDragging) return;

        const delta = 1;
        if (details.delta.dx > delta) {
          openDrawer();
        } else if (details.delta.dx < -delta) {
          closeDrawer();
        }

        isDragging = false;
      },
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 - animation.value * 0.1,
            child: Transform.translate(
              offset: Offset(
                animation.value * 230,
                0,
              ),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY((animation.value * 30) * math.pi / 180),
                child: child,
              ),
            ),
          );
        },
        child: AbsorbPointer(
          absorbing: isDrawerOpen,
          child: getDrawerPage(),
        ),
      ),
    );
  }

  Widget getDrawerPage() {
    switch (drawerItem) {
      case DrawerItem.notes:
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ));
        return NotesTabView(
          isDrawerOpen: isDrawerOpen,
        );
      case DrawerItem.events:
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
        ));
        return EventsScreen(
          isDrawerOpen: isDrawerOpen,
        );
      case DrawerItem.settings:
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ));
        return SettingsScreen(
          isDrawerOpen: isDrawerOpen,
        );
      default:
        return NotesTabView(
          isDrawerOpen: isDrawerOpen,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          buildDrawer(),
          buildPage(),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return SafeArea(
                child: Row(
                  children: [
                    SizedBox(width: animation.value * 190),
                    child!,
                  ],
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: greyUsedOpacityLowered,
                            offset: Offset(0, 5),
                            blurRadius: 5,
                          )
                        ],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: whiteUsed,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: AnimatedIcon(
                          icon: AnimatedIcons.close_menu,
                          progress: controllerForDrawerButton,
                          color: blackUsed,
                          size: 22,
                        ),
                      ),
                    ),
                    onTap: () => setState(() {
                      isDrawerOpen = !isDrawerOpen;
                      isDrawerOpen ? openDrawer() : closeDrawer();
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: blueForDrawer,
    );
  }
}
