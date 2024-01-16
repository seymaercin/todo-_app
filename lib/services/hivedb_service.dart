import 'dart:async';
import 'package:hive_flutter/adapters.dart';
import 'package:todo_app/models/todo_item_model.dart';



class HiveDBService {
  static final serviceStarted = Completer<bool>();

  HiveDBService._();

  static Future<bool> initService() async {
    if (serviceStarted.isCompleted) {
      return false;
    }
    await Hive.initFlutter();
    Hive.registerAdapter(TodoItemModelAdapter());
    serviceStarted.complete(true);
    return true;
  }

  static Future<Box<T>> openBox<T>() async {
    if (Hive.isBoxOpen('$T')) {
      return Hive.box('$T');
    }
    return await Hive.openBox('$T');
  }

  static Future<bool> closeBox<T>() async {
    if (Hive.isBoxOpen('$T')) {
      final box = Hive.box('$T');
      await box.close();
      return true;
    }
    return false;
  }

  static Future<int> addToBox<T>(Box<T> box, T data) async {
    return box.add(data);
  }

  static Future<bool> remove<T>(Box<T> box, int index) async {
    await box.deleteAt(index);
    return true;
  }

  static Future<bool> update<T>(Box<T> box, int index, T data) async {
    await box.putAt(index, data);
    return true;
  }
}
