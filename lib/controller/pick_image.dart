// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_gpt/homepage.dart';
import 'package:recipe_gpt/services/openai/chat_screen.dart';
import 'package:recipe_gpt/checklist.dart';
import 'package:image_cropper/image_cropper.dart';

class PickImage extends StatefulWidget {
  const PickImage({super.key});

  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  Uint8List? _image;
  File? selectedIMage;
  bool _isNextButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CAMERA'),
      ),
      backgroundColor: Color.fromARGB(255, 247, 238, 163),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image != null
                ? AspectRatio(
                    aspectRatio: 1, // 固定比例 1:1
                    child: Image.memory(_image!),
                  )
                : Container(
                    width: 400,
                    height: 300,
                    color: Colors.grey[300],
                    child: Center(child: Text('還沒有照片哦!')),
                  ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    showImagePickerOption(context);
                  },
                  child: const Icon(Icons.add_a_photo),
                ),
                SizedBox(width: 20), // 在兩個按鈕之間增加空間
                ElevatedButton(
                  onPressed: _isNextButtonEnabled
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CheckList()), // 勾選辨識清單頁面
                          );
                        }
                      : null,
                  child: Text('下一步'),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_image != null)
              Text(
                '目前食材：番茄',
                style: TextStyle(
                  color: Color.fromARGB(255, 62, 62, 62),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Color.fromARGB(255, 255, 196, 106),
        context: context,
        builder: (builder) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4.5,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromGallery();
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.image,
                              size: 70,
                            ),
                            Text("Gallery")
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromCamera();
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 70,
                            ),
                            Text("Camera")
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void onInit() {
    // TODO: implement onInit
    //super.onInit();
    //initCamera();
    initTFLite();
  }

  Future<void> initTFLite() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
  }

  //Gallery
  Future<void> _pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;

    final croppedImage = await ImageCropper().cropImage(
      sourcePath: returnImage.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1), // 固定比例 1:1
    );

    if (croppedImage == null) return;

    setState(() {
      selectedIMage = File(croppedImage.path);
      _image = File(croppedImage.path).readAsBytesSync();
      _isNextButtonEnabled = true;
    });

    Navigator.of(context).pop(); // 關閉模態對話框
  }

  //Camera
  Future<void> _pickImageFromCamera() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;

    final croppedImage = await ImageCropper().cropImage(
      sourcePath: returnImage.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1), // 固定比例 1:1
    );

    if (croppedImage == null) return;

    setState(() {
      selectedIMage = File(croppedImage.path);
      _image = File(croppedImage.path).readAsBytesSync();
      _isNextButtonEnabled = true;
    });

    Navigator.of(context).pop(); // 關閉模態對話框
  }

  // ObjectDetector(Uint8List image) async{
  //     var detector = await Tflite.runModelOnFrame(
  //       bytesList: [image],
  //     );
  //     if(detector != null){
  //       print("Result is $detector");
  //     }
  //   }
  bool _isModelRunning = false;

  // ObjectDetector(Uint8List image) async {
  //   if (_isModelRunning) {
  //     // 模型正在運行，跳過這個請求
  //     return;
  //   }
  //   _isModelRunning = true;
  //   try {
  //     var detector = await Tflite.runModelOnFrame(
  //       bytesList: [image],
  //     );
  //     if (detector != null) {
  //       print("Result is $detector");
  //     }
  //   } finally {
  //     _isModelRunning = false;
  //   }
  // }
}
