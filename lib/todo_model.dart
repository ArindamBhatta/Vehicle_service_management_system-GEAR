class TodoModel {
  final String id;
  final String title;
  final bool isCompleted;

  TodoModel({required this.id, required this.title, this.isCompleted = false});

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
