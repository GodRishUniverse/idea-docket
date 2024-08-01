import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/misc/snack_bar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailAddress = TextEditingController();

  @override
  void dispose() {
    _emailAddress.dispose();
    super.dispose();
  }

  Future resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailAddress.text.trim(),
      );
      Future.delayed(
        Duration.zero,
        () {
          showSnackBarSuccess(context, "Please check your email!");
        },
      );
    } on FirebaseAuthException catch (e) {
      Future.delayed(
        Duration.zero,
        () {
          showSnackBarError(context, e.toString());
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Fogot Password",
          style: TextStyle(
            color: whiteUsed,
            fontFamily: "GilroyBold",
          ),
        ),
        backgroundColor: orangeUsed,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Forgot Your Password?",
                    style: TextStyle(
                      fontFamily: "GilroyBold",
                      fontSize: 30,
                      color: whiteUsed,
                    ),
                  ),
                  const SizedBox(
                    height: 33,
                  ),
                  TextField(
                    controller: _emailAddress,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: whiteUsed,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: orangeUsed),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintText: "Enter your Email",
                      hintStyle: const TextStyle(
                        fontFamily: "Gilroy",
                        color: greyUsed,
                        fontSize: 15,
                      ),
                      prefixIcon: const Icon(
                        Icons.email_rounded,
                        color: blackUsed,
                      ),
                      fillColor: whiteUsed,
                      filled: true,
                    ),
                    style: const TextStyle(
                      fontFamily: "Gilroy",
                      fontSize: 15,
                      color: blackUsed,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: RawMaterialButton(
                      onPressed: resetPassword,
                      fillColor: orangeUsed,
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      textStyle: const TextStyle(
                          color: whiteUsed,
                          fontFamily: 'GilroyBold',
                          fontSize: 22),
                      child: const Text("Reset Password?"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: blackUsed,
    );
  }
}
