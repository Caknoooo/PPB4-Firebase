import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _noteController = TextEditingController();

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: _noteController,
          decoration: const InputDecoration(hintText: 'Enter your note'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _noteController.clear();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_noteController.text.isNotEmpty) {
                await addNote(_noteController.text);
              }
              Navigator.pop(context);
              _noteController.clear();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showUpdateNoteDialog(DocumentSnapshot doc) {
    final TextEditingController _updateController =
        TextEditingController(text: doc['note']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Note'),
        content: TextField(
          controller: _updateController,
          decoration: const InputDecoration(hintText: 'Update your note'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_updateController.text.isNotEmpty) {
                await updateNote(doc.id, _updateController.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notesList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notesList.length,
            itemBuilder: (context, index) {
              final doc = notesList[index];
              return ListTile(
                title: Text(doc['note']),
                subtitle: Text(doc['timestamp'].toDate().toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showUpdateNoteDialog(doc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteNote(doc.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
