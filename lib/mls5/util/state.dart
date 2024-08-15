import 'dart:async';

class StateNotifier {
  final _ctrl = StreamController<void>.broadcast();
  Stream<void> get stream => _ctrl.stream;
  void update() => _ctrl.add(null);
}
