import 'dart:async';
import 'dart:collection';

import 'package:watermelon_glasses/datatypes/task.dart';

class TasksQueue {
  Queue<Task>? _actions = Queue<Task>();

  TasksQueue() {
    // queue processor
    Future(
      () async {
        while (_actions != null) {
          // pick task
          while (_actions!.isEmpty) {
            await Future.delayed(const Duration(milliseconds: 10));
            if (_actions == null) return;
          }
          Task nextTask = _actions!.first;
          _actions!.removeFirst();

          // do task
          try {
            final res = await nextTask.f();
            nextTask.c.complete(res);
          } catch (e) {
            nextTask.c.completeError(e);
          }
        }
      },
    );
  }

  /// Note: if you added too many actions and don't want to do them all,
  /// you can call `flushActions()`,
  /// it will complete all the pending with exception [Cancelled]
  void flushActions() {
    if (_actions != null) {
      for (final action in _actions!) {
        action.c.completeError(Cancelled());
      }
      _actions!.clear();
    }
  }

  void finish() {
    flushActions();
    _actions = null;
  }

  Future<T> asyncSafe<T>(FutureProducer<T> f) {
    final completer = Completer<T>();
    _actions!.add(Task<T>(f, completer));
    return completer.future;
  }
}
