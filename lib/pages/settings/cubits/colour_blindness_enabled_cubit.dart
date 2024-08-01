import 'package:flutter_bloc/flutter_bloc.dart';

class ColourBlindnessEnabledCubit extends Cubit<bool> {
  ColourBlindnessEnabledCubit() : super(false);

  void change(bool val) {
    emit(val);
  }
}
