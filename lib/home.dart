import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'word.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Word> _wordBox;

  @override
  void initState() {
    super.initState();
    _openHiveBox();
  }

  Future<void> _openHiveBox() async {
    _wordBox = await Hive.openBox<Word>('words');
    setState(() {}); // Trigger a rebuild to show the loaded data
  }

  // Function to add a new word
  Future<void> _addWord(BuildContext context) async {
    TextEditingController wordController = TextEditingController();
    TextEditingController definitionController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Word'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: wordController,
                  decoration: const InputDecoration(labelText: 'Word'),
                ),
                TextField(
                  controller: definitionController,
                  decoration: const InputDecoration(labelText: 'Definition'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (wordController.text.isNotEmpty &&
                    definitionController.text.isNotEmpty) {
                  final newWord = Word(
                    word: wordController.text,
                    definition: definitionController.text,
                  );
                  _wordBox.add(newWord);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Function to edit an existing word
  Future<void> _editWord(BuildContext context, int index) async {
    if (_wordBox.isEmpty) return;
    final wordToEdit = _wordBox.getAt(index);
    if (wordToEdit == null) return;

    TextEditingController wordController =
        TextEditingController(text: wordToEdit.word);
    TextEditingController definitionController =
        TextEditingController(text: wordToEdit.definition);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Word'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: wordController,
                  decoration: const InputDecoration(labelText: 'Word'),
                ),
                TextField(
                  controller: definitionController,
                  decoration: const InputDecoration(labelText: 'Definition'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (wordController.text.isNotEmpty &&
                    definitionController.text.isNotEmpty) {
                  final updatedWord = Word(
                    word: wordController.text,
                    definition: definitionController.text,
                  );
                  _wordBox.putAt(index, updatedWord);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Function to delete a word
  void _deleteWord(int index) {
    _wordBox.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Practice'),
      ),
      body: ValueListenableBuilder<Box<Word>>(
        valueListenable: Hive.box<Word>('words').listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                  'No vocabulary words added yet. Click the "+" button to add some!'),
            );
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final word = box.getAt(index)!;
              return Dismissible(
                key: UniqueKey(), // Use UniqueKey for Dismissible with Hive
                onDismissed: (direction) {
                  _deleteWord(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${word.word} deleted')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  title: Text(word.word,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(word.definition),
                  onTap: () {
                    _editWord(context, index);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addWord(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    Hive.close(); // Close all open boxes when the widget is disposed
    super.dispose();
  }
}