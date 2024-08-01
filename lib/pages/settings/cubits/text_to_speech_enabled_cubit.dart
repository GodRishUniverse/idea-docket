import 'package:flutter_bloc/flutter_bloc.dart';

class TextToSpeechEnabledCubit extends Cubit<bool> {
  TextToSpeechEnabledCubit() : super(false);

  void changeState() {
    emit(!state);
  }

  void changeStateAccordingToValue(bool newState) {
    emit(newState);
  }
}
