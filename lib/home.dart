import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ImagePicker _picker = ImagePicker();
  XFile? imagePicked;
  String? resultText = 'Result: ';
  final Map<int, String> labels = {
    0: 'Blast',
    1: 'Blight',
    2: 'Tungro',
  };

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/leaf_disease_model.tflite",
        labels: "assets/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false,
      );
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  Future<void> detectImage(File image) async {
    try {
      print('Detecting image...');

      final recognitions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 10,
        threshold: 0.90,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      if (recognitions!.isNotEmpty) {
        final topRecognition = recognitions.first;
        final predictedLabel =
            labels[topRecognition['index'] as int] ?? 'Unknown';
        final confidence = topRecognition['confidence'] as double;

        setState(() {
          resultText = 'Result: $predictedLabel';
        });
      } else {
        setState(() {
          resultText = 'No results found';
        });
      }
    } catch (e) {
      print('Error during detection: $e');
      setState(() {
        resultText = 'Error: $e';
      });
    }
  }

  void _pickImage(ImageSource source) async {
    final XFile? pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        imagePicked = pickedImage;
      });
      detectImage(File(pickedImage.path));
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen[700],
        centerTitle: false,
        titleSpacing: 10.0,
        title: const Text(
          'Leaf Disease Detection',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleTextStyle: const TextStyle(
          decorationStyle: TextDecorationStyle.solid,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 16, 10, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MaterialButton(
                  elevation: 5.0,
                  height: 42.0,
                  onPressed: () => _pickImage(ImageSource.camera),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.camera),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: const Text('Open Camera'),
                      ),
                    ],
                  ),
                ),
                MaterialButton(
                  elevation: 5.0,
                  minWidth: 180.0,
                  height: 42.0,
                  onPressed: () => _pickImage(ImageSource.gallery),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.file_copy),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: const Text('Open File'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (imagePicked != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image.file(
                  File(imagePicked!.path),
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.55,
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 0),
              child: MaterialButton(
                elevation: 5,
                onPressed: () {
                  if (imagePicked != null) {
                    detectImage(File(imagePicked!.path));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please pick an image first')),
                    );
                  }
                },
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: const Text("Detect"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 0),
            child: Text(
              resultText!,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
