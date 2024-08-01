import 'package:flutter_bloc/flutter_bloc.dart';

class DeletedFileUrlsCubit extends Cubit<List<String>> {
  DeletedFileUrlsCubit() : super([]);

  void addToCubit(String url) {
    final curr = state;
    final updated = List<String>.from(curr)..add(url);
    emit(updated);
  }

  void emptyTempList() {
    emit([]);
  }
}
