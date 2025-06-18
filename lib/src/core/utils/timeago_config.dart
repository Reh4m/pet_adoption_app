import 'package:timeago/timeago.dart' as timeago;

class TimeAgoConfig {
  static void initialize() {
    timeago.setLocaleMessages('es', timeago.EsMessages());
  }
}
