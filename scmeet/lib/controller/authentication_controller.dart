import 'package:get/get.dart';

class AuthenticationController extends GetxController {
  RxBool authenticationFormState = true.obs;

    void updateAuthFormState(bool i) =>
      i ? authenticationFormState.value = true : authenticationFormState.value = false;
}