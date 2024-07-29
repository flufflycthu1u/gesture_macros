import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:app/grpc_generated/client.dart';
import 'package:app/grpc_generated/init_py.dart';
import 'package:grpc/grpc_connection_interface.dart';
import 'package:path/path.dart';
import 'service.dart' as service;

Future<void> pyInitResult = Future(() => null);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  pyInitResult = initPy();

  runApp(const GestureMacros());
}

class GestureMacros extends StatefulWidget {
  const GestureMacros({Key? key}) : super(key: key);

  @override
  GestureMacrosState createState() => GestureMacrosState();
}

class GestureMacrosState extends State<GestureMacros> with WidgetsBindingObserver {
  bool streaming = false;

  @override
  Future<ui.AppExitResponse> didRequestAppExit() {
    shutdownPyIfAny();
    return super.didRequestAppExit();
  }

  Map blendshapes = Map();
  service.CancelationToken cancelationToken = () {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Using',
                        ),
                        TextSpan(
                          text: ' $defaultHost:$defaultPort',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ', ${localPyStartSkipped ? 'skipped launching local server' : 'launched local server'}'
                        ),
                      ]
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: 
                      FutureBuilder<void>(
                        future: pyInitResult,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Stack(
                              children: [
                                SizedBox(height: 4, child: LinearProgressIndicator()),
                                Positioned.fill(child: Center(
                                  child: Text(
                                    'Loading Python',
                                  ),
                                ))
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return const Text(
                              'Python has been loaded',
                              style: TextStyle(
                                color: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                  ),
                  const SizedBox(height: 16),
                  Text("${blendshapes.length} = ${blendshapes.toString()}"),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _onPlay(context),
            ),
          );
        }
      ),
    );
  }

  void _onPlay(BuildContext context) {
    if (streaming) {
      cancelationToken.call();
      streaming = false;
      return;
    }
    var (blendshapeStream, cn) = service.streamBlendshapes();
    streaming = true;

    cancelationToken = cn;

    blendshapeStream.listen(
      (value) {
        blendshapes = value.blendshape;
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