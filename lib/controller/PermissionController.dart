import 'package:permission_handler/permission_handler.dart';

class PermissionController {
  allPermissionGranted() async {
    return await Permission.storage.isGranted;
  }

  askAllPermission() async {
    if (!await allPermissionGranted()) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      print('Permission status: ${statuses[Permission.storage]}');
    } else {
      print('Permission status: already granted');
    }
  }

  /// Request storage permission to the user
  ///
  /// call [onPermissionGranted()] on permission granted.
  /// call [onPermissionDenied()] on permission not granted; it could be [denied], [rejected], [restricted], etc...
  requestStoragePermission(
      Function onPermissionGranted, Function onPermissionDenied) async {
    /// Request storage permission
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    /// Check whether the permission was granted or not
    if (statuses[Permission.storage] == PermissionStatus.granted) {
      /// Storage permission granted
      onPermissionGranted();
      return;
    }

    /// Storage permission denied
    onPermissionDenied();
  }
}
