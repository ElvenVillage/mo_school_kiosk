import 'package:flutter/services.dart';

class GtkMultitouchEventChannel {
  static const eventChannel = EventChannel('ru.nintegra/kiosk.dovuz/events');

  static Stream streamFromNative() => eventChannel.receiveBroadcastStream();
}
