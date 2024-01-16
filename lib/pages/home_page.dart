import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/models/todo_item_model.dart';
import 'package:todo_app/services/hivedb_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Box<TodoItemModel>? box;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await HiveDBService.initService();
      box = await HiveDBService.openBox<TodoItemModel>();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: HiveDBService.serviceStarted.future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (box != null) {
              return ValueListenableBuilder(
                valueListenable: box!.listenable(),
                builder: (context, box, child) {
                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final element = box.getAt(index) as TodoItemModel;

                      return Dismissible(
                        onDismissed: (direction) {
                          HiveDBService.remove(box!, index);
                        },
                        key: Key(element.createdAt.toIso8601String()),
                        child: ListTile(
                          leading: Checkbox(
                            value: element.checked,
                            onChanged: (value) {
                              element.checked = !element.checked;
                              HiveDBService.update(box!, index, element);
                            },
                          ),
                          title: Text(
                            element.title,
                            style: TextStyle(
                              decoration: element.checked
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () async {
          final response = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialogEditTodo();
            },
          );

          if (response != null) {
            HiveDBService.addToBox(box!, response);
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class SimpleDialogEditTodo extends StatelessWidget {
  final TextEditingController _textEditingController = TextEditingController();

  SimpleDialogEditTodo({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Görev Ekle',
        style: TextStyle(color: Colors.purple),
      ),
      content: TextField(
        controller: _textEditingController,
        decoration: const InputDecoration(
          hintText: 'Görev giriniz',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('İptal',
              style: TextStyle(
                color: Colors.purple,
              )),
        ),
        TextButton(
          onPressed: () {
            final newTodo = TodoItemModel(
              title: _textEditingController.text,
              checked: false,
              createdAt: DateTime.now(),
            );
            Navigator.pop(context, newTodo);
          },
          child: const Text('Ekle',
              style: TextStyle(
                color: Colors.purple,
              )),
        ),
      ],
    );
  }
}
