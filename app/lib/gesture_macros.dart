import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:keyboard_invoker/keyboard_invoker.dart';
import 'package:provider/provider.dart';
//import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'package:app/grpc_generated/init_py.dart';
import 'package:grpc/grpc_connection_interface.dart';
import 'service.dart' as service;
import 'model.dart';

Future<void> pyInitResult = Future(() => null);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  pyInitResult = initPy();

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
      debugShowCheckedModeBanner: false,
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

class MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool _gestureReady = true;
  Duration delay = const Duration(milliseconds: 1000);

  final List<GestureMacro> _gestures = [];
  final List<Gesture> gestureList = [
    Gesture(name: 'Look left', values: {'eyeLookOutLeft' : 0.7, 'eyeLookInRight' : 0.7}),
    Gesture(name: 'Look right', values: {'eyeLookInLeft' : 0.7, 'eyeLookOutRight' : 0.7}),
    Gesture(name: 'Look up', values: {'eyeLookUpLeft' : 0.5, 'eyeLookUpRight' : 0.5}),
    Gesture(name: 'Look down', values: {'eyeLookDownLeft' : 0.4, 'eyeLookDownRight' : 0.4}),
    Gesture(name: 'Brow down', values: {'browDownLeft' : 0.5, 'browDownRight' : 0.5}),
    Gesture(name: 'Brow up', values: {'browOuterUpLeft' : 0.5, 'browOuterUpRight' : 0.5, 'browInnerUp' : 0.3}),
    Gesture(name: 'Mouth open', values: {'jawOpen' : 0.4}),
  ];
  bool ready = false;
  bool streaming = false;

  @override
  Future<ui.AppExitResponse> didRequestAppExit() {
    shutdownPyIfAny();
    return super.didRequestAppExit();
  }

  Map<String, double> blendshapes = {};

  //Timer? timer;
  //List<ChartData> data = [];
  
  service.CancelationToken cancelationToken = () {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _onPyLoaded();
  }

  void _showAddGestureDialog() {
    final TextEditingController gestureNameController = TextEditingController();
    Gesture? selectedGesture;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final keyboardInvokerPlugin = Provider.of<KeyboardInvoker>(context, listen: false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          keyboardInvokerPlugin.recordedKeys = []; // Clear recorded keys
        });

        var formkey = GlobalKey<FormState>();

        return AlertDialog(
          title: const Text('Add New Gesture'),
          content: Form(
            key: formkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a name';
                    }
                    return null;
                  },
                  controller: gestureNameController,
                  decoration: const InputDecoration(
                    hintText: 'Gesture Name',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Gesture>(
                  value: selectedGesture,
                  onChanged: (Gesture? newGesture) {
                    setState(() {
                      selectedGesture = newGesture;
                    });
                  },
                  validator: (value) => value == null ? 'field required' : null,
                  items: gestureList
                      .map<DropdownMenuItem<Gesture>>((Gesture gesture) {
                    return DropdownMenuItem<Gesture>(
                      value: gesture,
                      child: Text(gesture.name),
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
                      WidgetsBinding.instance.addPostFrameCallback((_) {
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
                        .map((e) => e["keyLabel"])
                        .toList();
                    return Text(
                      'Recorded Keys: ${recordedKeys.join(", ")}',
                    );
                  },
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
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (formkey.currentState!.validate()) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _gestures.add(
                        GestureMacro(
                          title: gestureNameController.text,
                          binding: keyboardInvokerPlugin.recordedKeys,
                          selectedGesture: selectedGesture!,
                        ),
                      );
                    });
                  });
                  Navigator.of(context).pop();
                }
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
    Gesture? selectedGesture = _gestures[index].selectedGesture;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final keyboardInvokerPlugin = Provider.of<KeyboardInvoker>(context, listen: false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          keyboardInvokerPlugin.recordedKeys = _gestures[index].binding;
        });

        var formkey = GlobalKey<FormState>();

        return AlertDialog(
          title: const Text('Edit Gesture'),
          content: Form(
            key: formkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a name';
                    }
                    return null;
                  },
                  controller: gestureNameController,
                  decoration: const InputDecoration(
                    hintText: 'Gesture Name',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Gesture>(
                  value: selectedGesture,
                  validator: (value) => value == null ? 'field required' : null,
                  onChanged: (Gesture? newGesture) {
                    setState(() {
                      selectedGesture = newGesture;
                    });
                  },
                  items: gestureList
                      .map<DropdownMenuItem<Gesture>>((Gesture gesture) {
                    return DropdownMenuItem<Gesture>(
                      value: gesture,
                      child: Text(gesture.name),
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
                      WidgetsBinding.instance.addPostFrameCallback((_) {
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
                if (formkey.currentState!.validate()) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _gestures[index].title = gestureNameController.text;
                      _gestures[index].binding = keyboardInvokerPlugin.recordedKeys;
                      _gestures[index].selectedGesture = selectedGesture!;
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

/*   Future<void> _showBlendshapeDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Blendshapes'),
          content: SfCartesianChart(
            plotAreaBorderWidth: 0,
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(
              
            ),
            series: <CartesianSeries>[
              BarSeries(
                xValueMapper: xValueMapper,
                yValueMapper: yValueMapper,
              ),
            ],
          ),
        );
      }
    );
  }

  void _updateDataSource(Timer timer) {

  }
 */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Visual Assistant'),
        actions: <Widget>[
          IconButton(
            icon: Icon(streaming? Icons.pause : Icons.play_arrow),
            onPressed: () => _onPlay(context),
          ),
        ],
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
        heroTag: null,
        onPressed: _showAddGestureDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onPyLoaded() {
    pyInitResult.then((v) {
      setState(() {
        ready = true;
      });
    }, onError: (error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}'))
      );
    });
  }

  void _onPlay(BuildContext context) {
    if (streaming) {
      cancelationToken.call();
      setState(() {
          streaming = false;
      });
      return;
    }
    var (blendshapeStream, cn) = service.streamBlendshapes();

    setState(() {
      streaming = true;
    });

    cancelationToken = cn;

    blendshapeStream.listen(
      (value) async {
        blendshapes = value.blendshape;
        final keyboardInvokerPlugin = Provider.of<KeyboardInvoker>(context, listen: false);

        for (GestureMacro e in _gestures) {
          if (_gestureReady && e.selectedGesture.isActive(blendshapes)) {
            _gestureReady = false;
            keyboardInvokerPlugin.invokeMacroList(e.binding);
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Active gesture ${e.selectedGesture.name}'))
            );
            Timer(delay, () => _gestureReady = true);
          }
        }
        setState(() {});
      },
      cancelOnError: true,
      onError: (error, stackTrace) {
        if (error is GrpcError && error.code == 1) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occured\n$error')));
      }
    );
  }
}
