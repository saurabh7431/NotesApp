import 'package:flutter/material.dart';
import 'package:notesapp/features/notes/models/note.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onTogglePin,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  String _formatUpdatedAt(BuildContext context) {
    final updated = note.updatedAt;
    final created = note.createdAt;
    if (updated == null || created == null) return '';
    final now = DateTime.now();

    final isEdited = updated.difference(created).inSeconds > 5;

    final targetDate = isEdited ? updated : created;

    final difference = now.difference(targetDate);

    String prefix = isEdited ? 'Edited' : 'Created';

    if (difference.inDays >= 7) {
      return '$prefix on${updated.day}/${updated.month}/${updated.year}';
    }
    if (difference.inDays >= 1) {
      final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '$prefix on${weekDays[updated.weekday - 1]}';
    }
    final timeOfDay = TimeOfDay.fromDateTime(updated);
    return '$prefix at${timeOfDay.format(context)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasTitle = note.title.trim().isNotEmpty;
    final hasContent = note.content.trim().isNotEmpty;

    return Material(
      color: note.color.withAlpha(229),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasTitle)
                          Text(
                            note.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (hasTitle && hasContent) const SizedBox(height: 8),
                        if (hasContent)
                          Text(
                            note.content,
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onTogglePin,
                    icon: Icon(
                      note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatUpdatedAt(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
