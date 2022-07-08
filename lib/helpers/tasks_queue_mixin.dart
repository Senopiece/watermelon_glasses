import 'dart:async';

import 'package:watermelon_glasses/helpers/tasks_queue.dart';
import 'package:watermelon_glasses/datatypes/task.dart';

mixin SingleTasksQueueMixin {
  late TasksQueue _tasksQueue;

  void initTasksQueue() => _tasksQueue = TasksQueue();
  void freeTasksQueue() => _tasksQueue.finish();

  /// Note: if you added too many actions and don't want to do them all,
  /// you can call `flushActions()`,
  /// it will complete all the pending with exception [Cancelled]
  void flushActions() => _tasksQueue.flushActions();

  /// internal protector
  /// methods protected by him cannot be invoked in parallel
  Future<T> asyncSafe<T>(FutureProducer<T> f) => _tasksQueue.asyncSafe(f);
}
