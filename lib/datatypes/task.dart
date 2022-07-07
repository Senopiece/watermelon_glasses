import 'dart:async';

class Cancelled extends Error {}

typedef FutureProducer<T> = Future<T> Function();

class Task<T> {
  final FutureProducer<T> f;
  final Completer<T> c;
  Task(this.f, this.c);
}
