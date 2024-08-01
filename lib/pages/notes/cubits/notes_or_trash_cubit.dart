import 'package:flutter_bloc/flutter_bloc.dart';

class NotesOrTrashCubit extends Cubit<int> {
  NotesOrTrashCubit() : super(0);

  void changeNotesDisplayed(int value) {
    emit(value);
  }
}
