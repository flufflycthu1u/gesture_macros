import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Gesture> _gestures = [];

  void _showAddGestureDialog() {
    final TextEditingController gestureNameController = TextEditingController();
    List<String> menuEntries = ['1', '2', '3'];
    LogicalKeyboardKey? selectedKey;
    FocusNode focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Gesture'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: gestureNameController,
                    decoration: const InputDecoration(
                      hintText: 'Gesture Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownMenu(
                    width: 200,
                    label: const Text('Gesture'),
                    dropdownMenuEntries: menuEntries.map<DropdownMenuEntry>((e) {
                      return DropdownMenuEntry(value: e, label: e);
                    }).toList()
                  ),
                  const SizedBox(height: 16),
                  KeyboardListener(
                    focusNode: focusNode,
                    onKeyEvent: (KeyEvent event) {
                      if (event is KeyDownEvent) {
                        setState(() {
                          selectedKey = event.logicalKey;
                        });
                      }
                    },
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(focusNode);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.grey[300],
                        child: Text(selectedKey != null
                            ? 'Key Binding: ${selectedKey!.debugName}'
                            : 'Tap to select key binding'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                setState(() {
                  _gestures.add(Gesture(
                    title: gestureNameController.text,
                    binding: selectedKey ?? LogicalKeyboardKey.space,
                  ));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditGestureDialog(int index) {
    final TextEditingController gestureNameController = TextEditingController();
    LogicalKeyboardKey selectedKey = _gestures[index].binding;
    gestureNameController.text = _gestures[index].title;
    FocusNode focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Gesture'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: gestureNameController,
                    decoration: const InputDecoration(
                      hintText: 'Gesture Name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  KeyboardListener(
                    focusNode: focusNode,
                    onKeyEvent: (KeyEvent event) {
                      if (event is KeyDownEvent) {
                        setState(() {
                          selectedKey = event.logicalKey;
                        });
                      }
                    },
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(focusNode);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.grey[300],
                        child: Text(selectedKey != null
                            ? 'Key Binding: ${selectedKey.debugName}'
                            : 'Tap to select key binding'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  _gestures[index].title = gestureNameController.text;
                  _gestures[index].binding = selectedKey;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Visual Assistant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _gestures.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: _gestures.length,
                      itemBuilder: (context, index) {
                        final gesture = _gestures[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Handle gesture name press
                                  },
                                  child: Text(gesture.title),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showEditGestureDialog(index);
                                  },
                                  child: const Text('Edit'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _gestures.removeAt(index);
                                    });
                                  },
                                  child: const Text('Delete'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : const Text('No gestures added yet'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGestureDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Gesture {
  Gesture({
    required this.title,
    required this.binding,
  });

  String title;
  LogicalKeyboardKey binding;
}
