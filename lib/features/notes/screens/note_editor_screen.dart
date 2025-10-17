import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notesapp/core/constants/note_colors.dart';
import 'package:notesapp/features/notes/models/note.dart';

import 'controllers/note_editor_controller.dart';

class NoteEditorScreen extends StatelessWidget {
  const NoteEditorScreen({
    super.key,
    this.note,
  });

  final Note? note;

  @override
  Widget build(BuildContext context) {
    return GetX<NoteEditorController>(
      init: NoteEditorController(note),
      builder: (controller) {
        final selectedColor = controller.selectedColor.value;
        final isPinned = controller.isPinned.value;
        final isSaving = controller.isSaving.value;
        final isEditing = controller.isEditing;

        return Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            title: Text(isEditing ? 'Edit Note' :"Save Note", style: TextStyle(color: Colors.white),),
            actions: [
              IconButton(
                onPressed: controller.togglePin,
                icon: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: Colors.white,
                ),
                tooltip: isPinned ? 'Unpin' : 'Pin',
              ),
              const SizedBox(width: 4),
              FilledButton.tonalIcon(
                onPressed:
                    isSaving ? null : () => controller.saveNote(context),
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.done),
                label: Text(isEditing ? 'Update' : 'Save'),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: selectedColor.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: controller.titleController,
                          decoration: const InputDecoration(
                            hintText: 'Title',
                            border: InputBorder.none,
                            enabledBorder:InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            filled: false
                          ),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: null,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controller.contentController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder:InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            filled: false,
                            hintText: 'Write your thoughts here...',
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select a Colour',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 16,
                    children: [
                      for (final color in NoteColors.palette)
                        GestureDetector(
                          onTap: () => controller.selectColor(color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: color == selectedColor
                                    ? Colors.black87
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: color == selectedColor
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.black87,
                                  )
                                : null,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
