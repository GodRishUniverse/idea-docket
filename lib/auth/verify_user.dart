import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/misc/snack_bar.dart';
import 'package:idea_docket/pages/home.dart';
import 'package:idea_docket/scale/scale_ui.dart';

class VerifyUserScreen extends StatefulWidget {
  const VerifyUserScreen({super.key});

  @override
  State<VerifyUserScreen> createState() => _VerifyUserScreenState();
}

class _VerifyUserScreenState extends State<VerifyUserScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // user needs to be created before:
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendEmailVerification();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  Future checkEmailVerified() async {
    // cakk after email verification

    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      setState(() {
        canResendEmail = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarSuccess(context, "Verification Sent!");
      });

      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        canResendEmail = true;
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarError(context, e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScaleUi().init(context);
    return isEmailVerified
        ? const HomeScreen()
        : Scaffold(
            appBar: AppBar(
              title: const Text(
                "Verify Email",
                style: TextStyle(
                  color: whiteUsed,
                  fontFamily: "GilroyBold",
                ),
              ),
              backgroundColor: orangeUsed,
              elevation: 4,
            ),
            backgroundColor: blackUsed,
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Waiting for verification...",
                      style: TextStyle(
                        color: orangeUsed,
                        fontFamily: "Gilroy",
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(
                      height: ScaleUi.screenHeight * 0.02,
                    ),
                    const Text(
                      "To resend the email click on the below button:",
                      style: TextStyle(
                        color: whiteUsed,
                        fontFamily: "Gilroy",
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: ScaleUi.screenHeight * 0.01,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.mail_lock_sharp,
                          color: whiteUsed,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blackUsed,
                        ),
                        onPressed:
                            canResendEmail ? sendEmailVerification : null,
                        label: const Text(
                          "Resend Verification",
                          style: TextStyle(
                            color: whiteUsed,
                            fontFamily: 'GilroyBold',
                            fontSize: 26,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: RawMaterialButton(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        fillColor: redUsed,
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        textStyle: const TextStyle(
                            color: whiteUsed,
                            fontFamily: 'GilroyBold',
                            fontSize: 22),
                        child: const Text("Cancel"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
