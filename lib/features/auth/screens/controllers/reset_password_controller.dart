import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notesapp/core/utils/snackbar_utils.dart';
import 'package:notesapp/features/auth/data/auth_service.dart';

class ResetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController emailController;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendResetLink(BuildContext context) async {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      await AuthService.instance.sendPasswordReset(
        emailController.text.trim(),
      );

      if (!context.mounted) return;
      SnackBarUtils.showMessage(
        context,
        'We just emailed you a password reset link.',
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
