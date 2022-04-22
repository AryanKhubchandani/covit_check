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
          if (result == "Mask Detected") {
            _startListening();
          } else {
            _stopListening();
          }
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
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text("CoVIT Check",
              style: TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              )),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            const Text("Please stand in front of the camera",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(result,
                  style: TextStyle(
                    color: (result == "Mask Detected"
                        ? Colors.greenAccent
                        : Colors.redAccent),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                _speechToText.isListening
                    ? ((_lastWords.isNotEmpty)
                        ? '$_lastWords'
                        : 'Please say your registration number')
                    : _speechEnabled
                        ? 'Please wear your mask'
                        : 'Speech not available',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            // FloatingActionButton(
            //   onPressed: _speechToText.isNotListening
            //       ? _startListening
            //       : _stopListening,
            //   child: Icon(
            //       _speechToText.isNotListening ? Icons.mic_off : Icons.mic),
            // ),
            // Text(_lastWords.toUpperCase().replaceAll(" ", "")),
            if (attendance
                .containsKey(_lastWords.toUpperCase().replaceAll(" ", ""))) ...[
              Text(
                attendance[_lastWords.toUpperCase().replaceAll(" ", "")] +
                    " " +
                    _lastWords.toUpperCase().replaceAll(" ", "") +
                    " is marked present",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ] else if (_lastWords.isEmpty) ...[
              const Text(""),
            ] else ...[
              const Text(
                "Try Again",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
