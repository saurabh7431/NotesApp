import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notesapp/core/utils/snackbar_utils.dart';
import 'package:notesapp/features/auth/data/auth_service.dart';
import 'package:notesapp/features/notes/data/notes_service.dart';
import 'package:notesapp/features/notes/models/note.dart';
import 'package:notesapp/features/notes/screens/note_editor_screen.dart';
import 'package:notesapp/features/notes/screens/widgets/note_card.dart';

import 'controllers/notes_home_controller.dart';

class NotesHomeScreen extends StatefulWidget {
  const NotesHomeScreen({super.key});

  @override
  State<NotesHomeScreen> createState() => _NotesHomeScreenState();
}

class _NotesHomeScreenState extends State<NotesHomeScreen> {
  late final NotesHomeController controller;

  Future<void> _reloadUser() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await user.reload();
    setState(() {}); // Force UI rebuild with updated displayName
  }
}


  @override
  void initState() {
    super.initState();
    _reloadUser();
    if (Get.isRegistered<NotesHomeController>()) {
      Get.delete<NotesHomeController>();
    }
    controller = Get.put(NotesHomeController());
  }

  @override
  void dispose() {
    Get.delete<NotesHomeController>();
    super.dispose();
  }

  void _openEditor(BuildContext context, [Note? note]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(note: note),
      ),
    );
  }

  Future<void> _deleteNote(BuildContext context, Note note) async {
    if (note.id == null) return;

    try {
      await NotesService.instance.deleteNote(note.id!);
      if (!context.mounted) return;
      SnackBarUtils.showMessage(context, 'Note deleted.');
    } catch (error) {
      if (!context.mounted) return;
      SnackBarUtils.showError(context, error.toString());
    }
  }

  Future<void> _togglePin(BuildContext context, Note note) async {
    try {
      await NotesService.instance.togglePin(note);
    } catch (error) {
      if (!context.mounted) return;
      SnackBarUtils.showError(context, error.toString());
    }
  }

  Future<void> _signOut() async {
    await AuthService.instance.signOut();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<Note> notes) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 900
        ? 4
        : width > 600
            ? 3
            : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: () => _openEditor(context, note),
          onTogglePin: () => _togglePin(context, note),
          onDelete: () => _deleteNote(context, note),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.lightbulb_circle_outlined,
          size: 80,
          color: Colors.black38,
        ),
        SizedBox(height: 16),
        Text(
          'Your notes will appear here',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Tap + to capture a new idea.',
          style: TextStyle(color: Colors.black45),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.split(' ').first ?? 'User';

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Hi, $displayName', style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search your notes...',
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: controller.updateSearch,
            ),
          ),
        ),
      ),
      body: Obx(() {
        final searchQuery = controller.searchQuery.value.trim();

        return StreamBuilder<List<Note>>(
          stream: NotesService.instance.watchNotes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load notes. ${snapshot.error}',
                ),
              );
            }

            final notes = snapshot.data ?? [];
            final filtered = searchQuery.isEmpty
                ? notes
                : notes.where((note) {
                    final query = searchQuery.toLowerCase();
                    return note.title.toLowerCase().contains(query) ||
                        note.content.toLowerCase().contains(query);
                  }).toList();

            if (filtered.isEmpty) {
              return Center(child: _buildEmptyState());
            }

            final pinned =
                filtered.where((note) => note.isPinned).toList(growable: false);
                
            final others = filtered
                .where((note) => !note.isPinned)
                .toList(growable: false);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (pinned.isNotEmpty) ...[
                  _buildSectionTitle('Pinned'),
                  _buildGrid(context, pinned),
                  if (others.isNotEmpty) const SizedBox(height: 24),
                ],
                if (others.isNotEmpty) ...[
                  if (pinned.isNotEmpty) _buildSectionTitle('Others'),
                  _buildGrid(context, others),
                ],
              ],
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}
