import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:idea_docket/theme/colours.dart';

import 'package:idea_docket/data_management/firestore_events_crud.dart';
import 'package:idea_docket/misc/login_success_pop_up.dart';
import 'package:idea_docket/misc/snack_bar.dart';
import 'package:idea_docket/pages/login/forgot_password.dart';
import 'package:idea_docket/scale/scale_ui.dart';

import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginScreen({super.key, required this.showRegisterPage});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Text contollers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  FirestoreServiceForEvents firestoreServiceForEvents =
      FirestoreServiceForEvents();

  bool isPasswordVisible = false;
  bool signingIn = false;
  bool signingInWithGoogle = false;

  Future<void> showDialogOnSignInSuccessful(BuildContext context) async {
    Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const LoginConfettiSplash()),
          opaque: false,
        ));
  }

  Future<void> signIn() async {
    setState(() {
      signingIn = true;
    });

    try {
      final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());

      final user = authResult.user;

      final prefs = await SharedPreferences.getInstance();

      prefs.setString(
        "signedInWithGoogle",
        "No",
      );

      if (user != null) {
        bool isEmailVerified = user.emailVerified;

        if (!isEmailVerified) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showSnackBarError(context, "Please Verify your Email!");
          });
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSnackBarError(context, "User is null!");
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSnackBarError(context, "Invalid email or password!");
        });
      } else if (e.code == 'user-disabled') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSnackBarAccountError(context, "Account Temporarily Disabled",
              "Your account has been temporarily disabled due to unusual activity. Please reset your password or try again later.");
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSnackBarError(context, "An error occured: ${e.code}");
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarError(context, e.toString());
      });
    } finally {
      setState(() {
        signingIn = false;
      });
    }
  }

  signInWithGoogle() async {
    setState(() {
      signingInWithGoogle = true;
    });

    try {
      final GoogleSignInAccount? user = await GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/calendar',
        ],
      ).signIn();

      if (user == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSnackBarWarning(context, "Canceled");
        });
      }

      final GoogleSignInAuthentication auth = await user!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
        "signedInWithGoogle",
        "Yes",
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      setState(() {
        signingInWithGoogle = false;
      });
      if (e.code == 'account-exists-with-different-credential') {
        // Handle account conflict

        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSnackBarAccountError(context, "Account Error",
              "Account exists with different credential");
        });
      } else if (e.code == 'invalid-credential') {
        // Handle invalid credential
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSnackBarAccountError(
              context, "Credential Error", "Invalid Credentials!");
        });
      } else if (e.code == 'operation-not-allowed') {
        // Handle operation not allowed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSnackBarAccountError(
              context, "Operation Error", "Operation not Allowed!");
        });
      } else if (e.code == 'user-disabled') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSnackBarAccountError(context, "Account Temporarily Disabled",
              "Your account has been temporarily disabled due to unusual activity. Please reset your password or try again later.");
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSnackBarError(context, "An error occured: ${e.code}");
        });
      }
    } catch (e) {
      setState(() {
        signingInWithGoogle = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarError(context, e.toString());
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? validateEmail(String? formEmail) {
    if (formEmail == null || formEmail == "") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarWarning(context, 'Email Field is empty!');
      });
    }
    String pattern = r'\w+@\w.\w+';
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(formEmail!)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarError(context, 'Please enter a valid email');
      });
    }

    return null;
  }

  String? validatePassword(String? formPassword) {
    if (formPassword == null || formPassword == "") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarWarning(context, 'Password Field is empty!');
      });
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    ScaleUi().init(context);
    return Scaffold(
      backgroundColor: blackUsed,
      body: Form(
        key: _key,
        child: Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 27, sigmaY: 27),
              child: const RiveAnimation.asset("assets/shapes.riv"),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Idea Docket",
                          style: TextStyle(
                            color: orangeUsed,
                            fontFamily: "GilroyBold",
                            fontSize: 50,
                          ),
                        ),
                        const Text(
                          "Login to your account",
                          style: TextStyle(
                            color: whiteUsed,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          height: ScaleUi.screenHeight * 0.02,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0.0),
                          child: TextFormField(
                            validator: validateEmail,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
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
                              hintText: "Email",
                              hintStyle: const TextStyle(
                                color: greyUsed,
                              ),
                              prefixIcon: const Icon(
                                Icons.mail,
                                color: blackUsed,
                              ),
                              fillColor: whiteUsed,
                              filled: true,
                            ),
                            style: const TextStyle(
                              color: blackUsed,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScaleUi.screenHeight * 0.0067,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0.0),
                          child: TextFormField(
                            validator: validatePassword,
                            controller: _passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: !isPasswordVisible,
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
                              hintText: "Password",
                              hintStyle: const TextStyle(
                                color: greyUsed,
                              ),
                              prefixIcon: const Icon(
                                Icons.key,
                                color: blackUsed,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () => setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                }),
                                child: isPasswordVisible
                                    ? const Icon(Icons.visibility)
                                    : const Icon(Icons.visibility_off),
                              ),
                              fillColor: whiteUsed,
                              filled: true,
                            ),
                            style: const TextStyle(
                              color: blackUsed,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScaleUi.screenHeight * 0.002,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const ForgotPasswordScreen();
                                }));
                              },
                              child: const Text(
                                "Forgot Password?",
                                style:
                                    TextStyle(color: whiteUsed, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: ScaleUi.screenHeight * 0.01375,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: RawMaterialButton(
                            onPressed: () {
                              if (_key.currentState!.validate()) {
                                signIn();
                              }
                            },
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
                            child: signingIn
                                ? const CircularProgressIndicator(
                                    color: whiteUsed,
                                  )
                                : const Text("Sign In"),
                          ),
                        ),
                        SizedBox(
                          height: ScaleUi.screenHeight * 0.0082,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: RawMaterialButton(
                            onPressed: signInWithGoogle,
                            fillColor: const Color.fromARGB(255, 242, 242, 242),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 8,
                            ),
                            child: signingInWithGoogle
                                ? const CircularProgressIndicator(
                                    color: orangeUsed,
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/google_logo.png",
                                        height: 40,
                                        width: 40,
                                      ),
                                      const Text(
                                        "Continue with Google",
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 31, 31, 31),
                                          fontFamily: 'Roboto',
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        SizedBox(
                          height: ScaleUi.screenHeight * 0.0167,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const Text(
                                "Don't remember your password?  ",
                                style:
                                    TextStyle(color: whiteUsed, fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: widget.showRegisterPage,
                                child: const Text(
                                  "Register here!",
                                  style: TextStyle(
                                      color: blueUsedInLinks, fontSize: 14),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
