import 'package:shared_preferences/shared_preferences.dart';

class SignedInWithGoogleCheck {
  static Future<bool> isSignedInWithGoogle() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final signedInWithGoogle = prefs.getString("signedInWithGoogle");
    if (signedInWithGoogle == "Yes") {
      return true;
    }
    return false;
  }
}
