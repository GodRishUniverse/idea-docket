import 'package:flutter/material.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:lottie/lottie.dart';

class LoginConfettiSplash extends StatefulWidget {
  const LoginConfettiSplash({
    super.key,
  });

  @override
  State<LoginConfettiSplash> createState() => _LoginConfettiSplashState();
}

class _LoginConfettiSplashState extends State<LoginConfettiSplash> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        color: greyUsed.withOpacity(0.85),
      ),
      child: Center(
        child: SizedBox(
          width: 350,
          height: 400,
          child: Column(
            children: [
              Lottie.asset(
                "assets/confetti.json",
              ),
              const Text(
                "Tap to dismiss",
                style: TextStyle(
                    fontSize: 22,
                    color: whiteUsed,
                    decoration: TextDecoration.none),
              )
            ],
          ),
        ),
      ),
    );
  }
}
