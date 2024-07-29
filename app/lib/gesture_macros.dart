import 'package:flutter/material.dart';
import 'package:keyboard_invoker/keyboard_invoker.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<KeyboardInvoker>(
      create: (context) => KeyboardInvoker(),
      child: const MyApp(),
    ),
  );
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
  MyHomePageState createState() => MyHomePageState();
}

class Gesture {
  Gesture({
    required this.title,
    required this.binding,
    this.selectedValue,
  });

  String title;
  List<String> binding;
  String? selectedValue;
}

class MyHomePageState extends State<MyHomePage> {
  final List<Gesture> _gestures = [];

  void _showAddGestureDialog() {
    final TextEditingController gestureNameController = TextEditingController();
    String? selectedValue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final keyboardInvokerPlugin = Provider.of<KeyboardInvoker>(context, listen: false);
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          keyboardInvokerPlugin.recordedKeys = []; // Clear recorded keys
        });

        return AlertDialog(
          title: const Text('Add New Gesture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: gestureNameController,
                decoration: const InputDecoration(
                  hintText: 'Gesture Name',
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedValue,
                onChanged: (newValue) {
                  setState(() {
                    selectedValue = newValue;
                  });
                },
                items: <String>['Look Up', 'Look Down', 'Look Left', 'Look Right']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Select a value',
                ),
              ),
              const SizedBox(height: 8),
              Focus(
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    keyboardInvokerPlugin.startRecording();
                  } else {
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      keyboardInvokerPlugin.stopRecording();
                    });
                  }
                },
                child: Builder(
                  builder: (context) {
                    return TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: keyboardInvokerPlugin.isRecording
                            ? 'Recording... press keys'
                            : 'Tap to start recording',
                      ),
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Consumer<KeyboardInvoker>(
                builder: (context, keyboardInvoker, child) {
                  final recordedKeys = keyboardInvoker.recordedKeys
                      .map((e) => e["keyLabel"] as String)
                      .toList();
                  return Text(
                    'Recorded Keys: ${recordedKeys.join(", ")}',
                  );
                },
              ),
            ],
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
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  setState(() {
                    _gestures.add(
                      Gesture(
                        title: gestureNameController.text,
                        binding: keyboardInvokerPlugin.recordedKeys
                            .map((e) => e["keyLabel"] as String)
                            .toList(),
                        selectedValue: selectedValue,
                      ),
                    );
                  });
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
    gestureNameController.text = _gestures[index].title;
    String? selectedValue = _gestures[index].selectedValue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final keyboardInvokerPlugin = Provider.of<KeyboardInvoker>(context, listen: false);
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          keyboardInvokerPlugin.recordedKeys = _gestures[index].binding
              .map((keyLabel) => {"keyLabel": keyLabel})
              .toList();
        });

        return AlertDialog(
          title: const Text('Edit Gesture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: gestureNameController,
                decoration: const InputDecoration(
                  hintText: 'Gesture Name',
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedValue,
                onChanged: (newValue) {
                  setState(() {
                    selectedValue = newValue;
                  });
                },
                items: <String>['Look Up', 'Look Down', 'Look Left', 'Look Right']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Select a value',
                ),
              ),
              const SizedBox(height: 8),
              Focus(
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    keyboardInvokerPlugin.startRecording();
                  } else {
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      keyboardInvokerPlugin.stopRecording();
                    });
                  }
                },
                child: Builder(
                  builder: (context) {
                    return TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: keyboardInvokerPlugin.isRecording
                            ? 'Recording... press keys'
                            : 'Tap to start recording',
                      ),
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Consumer<KeyboardInvoker>(
                builder: (context, keyboardInvoker, child) {
                  final recordedKeys = keyboardInvoker.recordedKeys
                      .map((e) => e["keyLabel"] as String)
                      .toList();
                  return Text(
                    'Recorded Keys: ${recordedKeys.join(", ")}',
                  );
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Clear'),
              onPressed: () {
                keyboardInvokerPlugin.recordedKeys = []; // Clear recorded keys
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  setState(() {
                    _gestures[index].title = gestureNameController.text;
                    _gestures[index].binding = keyboardInvokerPlugin.recordedKeys
                        .map((e) => e["keyLabel"] as String)
                        .toList();
                    _gestures[index].selectedValue = selectedValue;
                  });
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
                                    // This button could be used to show more details about the gesture
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
