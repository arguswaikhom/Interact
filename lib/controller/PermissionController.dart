import 'package:permission_handler/permission_handler.dart';

class PermissionController {
  /// Method to request storage permission
  Future<bool> requestStoragePermission() async {
    /// If the storage permission is already granted; return true otherwise ask for permission
    if (await Permission.storage.isGranted) {
      return true;
    } else {
      /// Request storage permission
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      /// Check whether the permission was granted or not
      if (statuses[Permission.storage] == PermissionStatus.granted) {
        /// Storage permission granted
        return true;
      }

      /// Storage permission denied
      return false;
    }
  }
}
