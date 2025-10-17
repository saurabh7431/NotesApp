import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/core/constants/note_colors.dart';

class Note {
  const Note({
    this.id,
    required this.title,
    required this.content,
    required this.colorValue,
    required this.isPinned,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String title;
  final String content;
  final int colorValue;
  final bool isPinned;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Color get color => Color(colorValue);

  factory Note.empty() => Note(
        title: '',
        content: '',
        colorValue: NoteColors.palette.first.toARGB32(),
        isPinned: false,
      );

  Note copyWith({
    String? id,
    String? title,
    String? content,
    int? colorValue,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      colorValue: colorValue ?? this.colorValue,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Note.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return Note(
      id: doc.id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      colorValue: data['colorValue'] as int? ?? NoteColors.palette.first.toARGB32(),
      isPinned: data['isPinned'] as bool? ?? false,
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> saveToFirestore(DateTime now) {
    return {
      'title': title,
      'content': content,
      'colorValue': colorValue,
      'isPinned': isPinned,
      'createdAt': (createdAt ?? now),
      'updatedAt': now,
    };
  }
}
