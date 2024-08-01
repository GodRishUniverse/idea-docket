import 'package:flutter_bloc/flutter_bloc.dart';

class ColourBlindnessThemeManualOrGeminiCubit extends Cubit<String> {
  ColourBlindnessThemeManualOrGeminiCubit() : super("Manual");

  void changeType() {
    if (state == "Manual") {
      emit("Gemini");
    } else {
      emit("Manual");
    }
  }
}
