import 'package:covit_check/main.dart';
import 'package:covit_check/screens/loginpage.dart';
import 'package:covit_check/services/auth.dart';

import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(HomePage());
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _auth = AuthService();

  late CameraImage cameraImage;
  late CameraController cameraController;
  String result = "";

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  Map attendance = {
    '20BCE0594': 'Aryan Khubchandani',
    '20BCE0966': 'Sagar Munshi',
    '19BCE0496': 'Pritisha Nakhwa',
  };

  initCamera() {
    cameraController = CameraController(cameras[1], ResolutionPreset.medium);
    cameraController.initialize().then((value) {
      if (!mounted) return;
      setState(() {
        cameraController.startImageStream((imageStream) {
          cameraImage = imageStream;
          runModel();
        });
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/models/model_unquant.tflite",
        labels: "assets/models/labels.txt");
  }

  runModel() async {
    if (cameraImage != null) {
      var recognitions = await Tflite.runModelOnFrame(
          bytesList: cameraImage.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: cameraImage.height,
          imageWidth: cameraImage.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 2,
          threshold: 0.1,
          asynch: true);
      recognitions!.forEach((element) {
        setState(() {
          result = element["label"];
          if (result == "With Mask") {
            _startListening();
            print("I am listening");
          } else {
            _stopListening();
          }
          // print("CHECK THIS OUT " + result);
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera();
    loadModel();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("CoVIT Check"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                height: MediaQuery.of(context).size.height - 240,
                width: MediaQuery.of(context).size.width,
                child: !cameraController.value.isInitialized
                    ? Container()
                    : AspectRatio(
                        aspectRatio: cameraController.value.aspectRatio,
                        child: CameraPreview(cameraController),
                      ),
              ),
            ),
            Text(result),
            Text(
              _speechToText.isListening
                  ? (_lastWords.isNotEmpty)
                      ? '$_lastWords'
                      : 'Please say your registration number'
                  : _speechEnabled
                      ? 'Wear Mask'
                      : 'Speech not available',
            ),
            // FloatingActionButton(
            //   onPressed: _speechToText.isNotListening
            //       ? _startListening
            //       : _stopListening,
            //   child: Icon(
            //       _speechToText.isNotListening ? Icons.mic_off : Icons.mic),
            // ),
            Text(_lastWords.toUpperCase().replaceAll(" ", "")),
            if (attendance
                .containsKey(_lastWords.toUpperCase().replaceAll(" ", ""))) ...[
              Text(attendance[_lastWords.toUpperCase().replaceAll(" ", "")] +
                  " is marked present"),
            ] else if (_lastWords.isEmpty) ...[
              Text(""),
            ] else ...[
              Text("Try Again"),
            ],
          ],
        ),
      ),
    );
  }
}
