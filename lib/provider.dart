import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_riverpod/todo_model.dart';

//create a provider intance R.H.S. and store the intance
final Provider<String> appTitleProvider = Provider<String>(
  (ref) => 'Flutter Demo Home Page',
);

//but this not change the state of the app, it just provides a value

//if you want to change the state of the app, you need to use a StateProvider
//StateProvider is for simple, mutable values like counters, booleans, etc.

//it's similar to cubit

class TodoNotifier extends StateNotifier<List<TodoModel>> {
  //when the constructor is called, it initializes the state with an empty list
  TodoNotifier() : super([]);

  void addTodo(String title) {
    final newTodo = TodoModel(
      id: DateTime.now().toString(),
      title: title,
      description: '',
    );
    state = [...state, newTodo]; //update the state with the new todo
  }

  void toggleTodo(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(
            isCompleted: !todo.isCompleted,
          ) //toggle the isCompleted value
        else
          todo,
    ];
  }

  void deleteTodo(String id) {
    state = state
        .where((todo) => todo.id != id)
        .toList(); //remove the todo with the given id
  }

  void updateTodo(String id, String title) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(title: title) //update the title
        else
          todo,
    ];
  }
}

final todoProvider = StateNotifierProvider<TodoNotifier, List<TodoModel>>(
  (ref) => TodoNotifier(),
);
