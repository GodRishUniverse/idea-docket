import 'package:flutter_bloc/flutter_bloc.dart';

enum MultimediaPermission {
  noStoragePermission,
  noStoragePermissionPermanently,
  permissionGranted
}

class MultimediaPermissionCubit extends Cubit<MultimediaPermission> {
  MultimediaPermissionCubit() : super(MultimediaPermission.noStoragePermission);

  void updateMultimediaPermission(MultimediaPermission permission) {
    emit(permission);
  }
}
