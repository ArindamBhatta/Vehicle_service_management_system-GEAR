class TodoModel {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;

  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
