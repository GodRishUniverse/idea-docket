import 'package:flutter_bloc/flutter_bloc.dart';

class AttachmentUrlsCubit extends Cubit<List<String>> {
  AttachmentUrlsCubit() : super([]);

  void removeFromCubit(String attachmentUrl) {
    final currentVal = state;
    final updatedVal = currentVal.toList()
      ..removeWhere((url) => url == attachmentUrl);
    emit(updatedVal);
  }

  void updateCubit(List<String> attachmentUrls) {
    emit(attachmentUrls);
  }

  void emptyTempList() {
    emit([]);
  }
}
