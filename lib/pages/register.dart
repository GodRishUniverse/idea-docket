import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/misc/snack_bar.dart';
import 'package:idea_docket/scale/scale_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterScreen({super.key, required this.showLoginPage});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //Text contollers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  bool isSigningUp = false;

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool signingUpWithGoogle = false;

  bool passwordsMatch() {
    if (_confirmPasswordController.text.trim() ==
        _passwordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  Future signUp() async {
    if (passwordsMatch()) {
      setState(() {
        isSigningUp = true;
      });

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final prefs = await SharedPreferences.getInstance();

        prefs.setString(
          "signedInWithGoogle",
          "No",
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showSnackBarError(context, "Email already in use!");
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
          isSigningUp = false;
        });
      }
    } else {
      showSnackBarWarning(context, "Passwords don't match!");
    }
  }

  signUpWithGoogle() async {
    setState(() {
      signingUpWithGoogle = true;
    });

    try {
      final GoogleSignInAccount? user = await GoogleSignIn(
        scopes: [
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
        signingUpWithGoogle = false;
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
        signingUpWithGoogle = false;
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
    _confirmPasswordController.dispose();
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
        showSnackBarWarning(context, 'Password field is empty!');
      });
    }

    return null;
  }

  String? validateConfirmPassword(String? formConfirmPassword) {
    if (formConfirmPassword == null || formConfirmPassword == "") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBarWarning(context, 'Confirm password field is empty!');
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  height: ScaleUi.screenHeight * 0.21,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Image.asset(
                      "assets/bg_gif.gif",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                        "Register",
                        style: TextStyle(
                          color: whiteUsed,
                          fontSize: 30,
                        ),
                      ),
                      SizedBox(
                        height: ScaleUi.screenHeight * 0.04,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.0),
                        child: TextFormField(
                          validator: validateEmail,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: whiteUsed),
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
                        height: ScaleUi.screenHeight * 0.0167,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.0),
                        child: TextFormField(
                          validator: validatePassword,
                          controller: _passwordController,
                          obscureText: !isPasswordVisible,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: whiteUsed),
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
                        height: ScaleUi.screenHeight * 0.0167,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.0),
                        child: TextFormField(
                          validator: validateConfirmPassword,
                          controller: _confirmPasswordController,
                          obscureText: !isConfirmPasswordVisible,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: whiteUsed),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: orangeUsed),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            hintText: "Confirm Password",
                            hintStyle: const TextStyle(
                              color: greyUsed,
                            ),
                            prefixIcon: const Icon(
                              Icons.confirmation_num,
                              color: blackUsed,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() {
                                isConfirmPasswordVisible =
                                    !isConfirmPasswordVisible;
                              }),
                              child: isConfirmPasswordVisible
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
                        height: ScaleUi.screenHeight * 0.0167,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: RawMaterialButton(
                          onPressed: () async {
                            if (_key.currentState!.validate()) {
                              signUp();
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
                          child: isSigningUp
                              ? const CircularProgressIndicator(
                                  color: whiteUsed,
                                )
                              : const Text("Sign Up"),
                        ),
                      ),
                      SizedBox(
                        height: ScaleUi.screenHeight * 0.0127,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: RawMaterialButton(
                          onPressed: signUpWithGoogle,
                          fillColor: const Color.fromARGB(255, 242, 242, 242),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                          ),
                          child: signingUpWithGoogle
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
                                        color: Color.fromARGB(255, 31, 31, 31),
                                        fontFamily: 'Roboto',
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(
                        height: ScaleUi.screenHeight * 0.01,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Already have an Account?  ",
                            style: TextStyle(
                              color: whiteUsed,
                              fontSize: 17,
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.showLoginPage,
                            child: const Text(
                              "Login!",
                              style: TextStyle(
                                color: blueUsedInLinks,
                                fontSize: 17,
                                fontFamily: 'GilroyBold',
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
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
