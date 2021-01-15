import 'package:toast/toast.dart';

class MessageUtils {
  final _context;

  MessageUtils(this._context);

  /// Display a short duration toast message
  showSToast(String msg) {
    Toast.show(msg, _context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
  }

  /// Display a long duration toast message
  showLToast(String msg) {
    Toast.show(msg, _context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}
