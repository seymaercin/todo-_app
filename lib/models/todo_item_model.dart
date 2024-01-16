
import 'package:hive/hive.dart';
part 'todo_item_model.g.dart';

@HiveType(typeId: 1)
class TodoItemModel {
  @HiveField(0)
  String title;
  @HiveField(1)
  DateTime createdAt;
  @HiveField(2)
  bool checked;

  TodoItemModel(
      {required this.title, required this.createdAt, required this.checked});

  factory TodoItemModel.empty() =>
      TodoItemModel(title: '', createdAt: DateTime.now(), checked: false);
}
