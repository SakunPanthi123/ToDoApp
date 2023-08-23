// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CollectionReference toDo = FirebaseFirestore.instance.collection('toDos');
  final toDoController = TextEditingController();
  final toDoUpdateController = TextEditingController();
  void addTodo() {
    toDo.add({
      'title': toDoController.text,
      'time': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void updateToDo(docID) {
    toDo.doc(docID).update({
      'title': toDoUpdateController.text,
    });
  }

  void removeTodo(docID) {
    toDo.doc(docID).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My To Dos'),
      ),
      body: Center(
        child: FutureBuilder(
          future: toDo.orderBy('time', descending: true).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return (CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return (Text('Error'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return (Text('No Todos, Add one'));
            } else {
              return SizedBox(
                height: 400,
                child: ListView(
                  children: snapshot.data!.docs.map((document) {
                    Map<String, dynamic> toDos =
                        document.data() as Map<String, dynamic>;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            toDos['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  toDoUpdateController.text = toDos['title'];
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('Update title'),
                                                TextField(
                                                  controller:
                                                      toDoUpdateController,
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    updateToDo(document.id);
                                                    toDoUpdateController.text =
                                                        '';
                                                    Navigator.of(context).pop();
                                                    setState(() {});
                                                  },
                                                  child: Text('Update'),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: Text(
                                  'Update',
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    removeTodo(document.id);
                                  });
                                },
                                child: Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Add Todo'),
                        TextField(
                          controller: toDoController,
                          decoration: InputDecoration(hintText: 'Talk to mom'),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              addTodo();
                              toDoController.text = '';
                              Navigator.of(context).pop();
                              setState(() {});
                            },
                            child: Text('Add')),
                      ],
                    ),
                  ),
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
