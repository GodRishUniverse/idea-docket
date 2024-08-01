import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

class TemporaryAttachmentForNotesCubit extends Cubit<List<File>> {
  TemporaryAttachmentForNotesCubit() : super([]);

  void addToCubit(File attachment) {
    final currentVal = state;
    final updatedVal = currentVal.toList()..add(attachment);
    emit(updatedVal);
  }

  void removeFromCubit(File attachmentToBeRemoved) {
    final currentVal = state;
    final updatedVal = currentVal.toList()
      ..removeWhere((file) => file == attachmentToBeRemoved);
    emit(updatedVal);
  }

  void updateCubit(List<File> tempAttachments) {
    emit(tempAttachments);
  }

  void emptyTempList() {
    emit([]);
  }
}
