import 'package:flutter_bloc/flutter_bloc.dart';

class EventSelectedDateCubit extends Cubit<DateTime> {
  EventSelectedDateCubit()
      : super(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ));

  void selectDate(DateTime selectedDate) {
    emit(selectedDate);
  }
}
