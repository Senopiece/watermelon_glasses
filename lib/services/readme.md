Here are declarations of services.

So service by itself is a singleton, but as here are only declarations, they must be registered somewhere else (using GetX dependency injection they are registered in [binding.dart](binding.dart), but the `binding.dart` by itself is invoked in the [main.dart](../main.dart)).