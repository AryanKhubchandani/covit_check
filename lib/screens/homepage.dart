import 'package:covit_check/main.dart';
import 'package:covit_check/screens/loginpage.dart';
import 'package:covit_check/services/auth.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("CHECK THIS");
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
        model: "assets/models/model.tflite",
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
          print(result);
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera();
    loadModel();
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
              padding: const EdgeInsets.all(10),
              child: Container(
                height: MediaQuery.of(context).size.height - 180,
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
              (() {
                if (result == "with_mask") {
                  return "MASK DETECTED";
                } else {
                  return "MASK NOT DETECTED";
                }
              })(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            )
          ],
        ),
      ),
    );
  }
}
