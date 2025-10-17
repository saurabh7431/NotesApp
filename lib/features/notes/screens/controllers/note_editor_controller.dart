import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notesapp/core/constants/note_colors.dart';
import 'package:notesapp/core/utils/snackbar_utils.dart';
import 'package:notesapp/features/notes/data/notes_service.dart';
import 'package:notesapp/features/notes/models/note.dart';

class NoteEditorController extends GetxController {
  NoteEditorController(this.note);

  final Note? note;

  late final TextEditingController titleController;
  late final TextEditingController contentController;
  late final Rx<Color> selectedColor;
  final RxBool isPinned = false.obs;
  final RxBool isSaving = false.obs;

  bool get isEditing => note != null;

  @override
  void onInit() {
    super.onInit();
    titleController = TextEditingController(text: note?.title ?? '');
    contentController = TextEditingController(text: note?.content ?? '');
    selectedColor = Color(
      note?.colorValue ?? NoteColors.palette.first.toARGB32(),
    ).obs;
    isPinned.value = note?.isPinned ?? false;
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }

  Future<void> saveNote(BuildContext context) async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      SnackBarUtils.showError(
        context,
        'Write something or add a title, then save.',
      );
      return;
    }

    if (isSaving.value) return;
    isSaving.value = true;

    try {
      final now = DateTime.now();
      final noteToSave = (note ?? Note.empty()).copyWith(
        title: title,
        content: content,
        colorValue: selectedColor.value.toARGB32(),
        isPinned: isPinned.value,
        createdAt: note?.createdAt ?? now,
      );

      await NotesService.instance.saveNote(noteToSave);

      if (!context.mounted) return;
      SnackBarUtils.showMessage(context, 'Note has been saved.');
      Navigator.of(context).pop();
    } catch (error) {
      if (!context.mounted) return;
      SnackBarUtils.showError(context, error.toString());
    } finally {
      isSaving.value = false;
    }
  }

  void togglePin() {
    isPinned.toggle();
  }

  void selectColor(Color color) {
    selectedColor.value = color;
  }
}
