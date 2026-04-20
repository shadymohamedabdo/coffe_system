import 'package:get/get.dart';

import 'controllers/employees_controller.dart';
import 'controllers/login_controller.dart';
import 'controllers/products_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // هنا بنستخدم lazyPut عشان يتكريت أول ما نروح للشاشة بس
    Get.lazyPut<LoginController>(() => LoginController());
  }
}

class EmployeesBinding extends Bindings {
  @override
  void dependencies() {
    // الكنترولر ده مش هيتحمل في الرامات غير لما الشاشة تطلبه
    Get.lazyPut<EmployeesController>(() => EmployeesController());
  }
}
class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductsController>(() => ProductsController());
  }
}