class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final String? importance;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    required this.importance,
  });
}
