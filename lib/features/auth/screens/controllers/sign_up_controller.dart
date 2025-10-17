import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notesapp/core/utils/snackbar_utils.dart';
import 'package:notesapp/features/auth/data/auth_service.dart';

class SignUpController extends GetxController {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;
  final RxBool isLoading = false.obs;
  final RxBool isVisible =false.obs;
  final RxBool isConfirmVisible =false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void isPasswordVisible(){
    isVisible.value=!isVisible.value;
  }
  void isConfirmPasswordVisible(){
    isConfirmVisible.value=!isConfirmVisible.value;
  }

  Future<void> signUp(BuildContext context) async {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      await AuthService.instance.signUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!context.mounted) return;
      
      SnackBarUtils.showMessage(
        context,
        'Your account is ready, please log in!',
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!context.mounted) return;
      SnackBarUtils.showError(context, error.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
