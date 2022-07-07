Here are placed declarations of pages, we'll use it for further registration (1) and routing (2).

(1) By convention we register pages in the [main.dart](../main.dart).

(2) Example of routing application:
``` dart
import 'package:get/get.dart';
import 'package:watermelon_glasses/pages/a_page.dart';

...

Get.to(aPage.name);
```

So a page is a couple of `controller` and `UI` (a widget by itself can depend on a controller, but only declared inside `GetPage` it satisfies it's dependency).