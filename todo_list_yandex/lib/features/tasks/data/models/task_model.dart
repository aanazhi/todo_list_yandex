import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String importance;

  @HiveField(3)
  final DateTime? deadline;

  @HiveField(4)
  final bool done;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime changedAt;

  @HiveField(7)
  final String lastUpdatedBy;

  Task({
    required this.id,
    required this.text,
    this.importance = 'basic',
    this.deadline,
    this.done = false,
    required this.createdAt,
    required this.changedAt,
    required this.lastUpdatedBy,
  });

  @override
  String toString() {
    return 'Task{id: $id, text: $text, done: $done, deadline: $deadline, importance: $importance, createdAt: $createdAt, changedAt: $changedAt, lastUpdatedBy: $lastUpdatedBy}';
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final text = json['text'] as String? ?? '';
    final importance = json['importance'] as String? ?? 'basic';
    final deadline = json['deadline'] != null
        ? DateTime.fromMillisecondsSinceEpoch((json['deadline'] as int) * 1000)
        : null;
    final done = json['done'] as bool? ?? false;
    final createdAt = json['created_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            (json['created_at'] as int) * 1000)
        : DateTime.now();
    final changedAt = json['changed_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            (json['changed_at'] as int) * 1000)
        : DateTime.now();
    final lastUpdatedBy = json['last_updated_by'] as String? ?? '';

    return Task(
      id: id,
      text: text,
      importance: importance,
      deadline: deadline,
      done: done,
      createdAt: createdAt,
      changedAt: changedAt,
      lastUpdatedBy: lastUpdatedBy,
    );
  }

  Map<String, dynamic> toJson() {
    final cleanedId = id.replaceAll(RegExp(r'[\[\]#]'), '');
    final data = {
      'id': cleanedId,
      'text': text,
      'importance': importance,
      'done': done,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'changed_at': changedAt.millisecondsSinceEpoch ~/ 1000,
      'last_updated_by': lastUpdatedBy,
    };

    if (deadline != null) {
      data['deadline'] = deadline!.millisecondsSinceEpoch ~/ 1000;
    }

    return data;
  }

  Task copyWith({
    String? id,
    String? text,
    String? importance,
    DateTime? deadline,
    bool? done,
    DateTime? createdAt,
    DateTime? changedAt,
    String? lastUpdatedBy,
  }) {
    return Task(
      id: id ?? this.id,
      text: text ?? this.text,
      importance: importance ?? this.importance,
      deadline: deadline ?? this.deadline,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
      changedAt: changedAt ?? this.changedAt,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
    );
  }
}
