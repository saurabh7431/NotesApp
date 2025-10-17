import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notesapp/core/utils/snackbar_utils.dart';
import 'package:notesapp/features/auth/data/auth_service.dart';

class SignInController extends GetxController {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  final RxBool isLoading = false.obs;
  final isVisible=false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
   void isPasswordVisible(){
    isVisible.value=!isVisible.value;
   }
   
  Future<void> signIn(BuildContext context) async {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      await AuthService.instance.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!context.mounted) return;
      SnackBarUtils.showMessage(context, 'Welcome back!');
    } catch (error) {
      if (!context.mounted) return;
      SnackBarUtils.showError(context, error.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
