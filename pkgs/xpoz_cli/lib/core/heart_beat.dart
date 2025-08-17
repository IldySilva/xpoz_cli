import 'dart:async';

class HeartBeat {
  final void Function() onTimeout;
  Timer? _t;
  DateTime _lastPong = DateTime.now();

  HeartBeat({required this.onTimeout});

  void start(void Function() sendPing) {
    sendPing();
    _t?.cancel();
    _t = Timer.periodic(const Duration(seconds: 20), (_) {
      final since = DateTime.now().difference(_lastPong);
      if (since > const Duration(seconds: 50)) {
        onTimeout();
      } else {
        sendPing();
      }
    });
  }

  void onPong() {
    _lastPong = DateTime.now();
  }

  void stop() {
    _t?.cancel();
  }
}
