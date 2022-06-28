import 'dart:async';

/// wrapper to attach a stream to a value
/// so any time the value becomes updated, stream listeners will be notified
class Listenable<T> {
  final _stream = StreamController<T>.broadcast();
  T _data;

  Listenable(this._data);

  T get data => _data;
  set data(T newVal) {
    _data = newVal;
    _stream.add(_data);
  }

  Stream<T> get stream => _stream.stream;
}
