import 'package:get/get.dart';

class NotesHomeController extends GetxController {
  final RxString searchQuery = ''.obs;

  void updateSearch(String value) {
    searchQuery.value = value;
  }
}
