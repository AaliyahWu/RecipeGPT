// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_gpt/homepage.dart';
import 'package:recipe_gpt/services/openai/chat_screen.dart';

class PickImage extends StatefulWidget {
  const PickImage({super.key});

  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  Uint8List? _image;
  File? selectedIMage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CAMERA'),
      ),
      backgroundColor: Color.fromARGB(255, 247, 238, 163),
      body: Center(
        child: Stack(
          children: [
            _image != null
                ? Container(
                      width: 400, height: 500, 
                      decoration: BoxDecoration(
                        image: DecorationImage(image: MemoryImage(_image!),
                        fit: BoxFit.cover,),shape: BoxShape.rectangle,
                        ),
                )
                : Container(
                      width: 400, height: 500, decoration: const BoxDecoration(
                        image: DecorationImage(image: NetworkImage(
                          "https://cdn.photoroom.com/v1/assets-cached.jpg?path=backgrounds_v3/white/Photoroom_white_background_extremely_fine_texture_only_white_co_d4046f3b-0a21-404a-891e-3f8d37c5aa94.jpg"),
                          fit: BoxFit.cover,),shape: BoxShape.rectangle,
                          ),
                ),

            Positioned(
                bottom: -0,
                left: 240,
                child: IconButton(
                    onPressed: () {
                      showImagePickerOption(context);
                    },
                    icon: const Icon(Icons.add_a_photo),
                    )),
            Positioned(
              bottom: 10, // 距離底部10像素
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 196, 106),),// 設置按鈕顏色
                  onPressed: () {
                    // 按鈕點擊時執行的代碼
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatPage()),
                    );
                  },
                  child: const Text('確認送出'),
                ),
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
    final returnImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      selectedIMage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    ObjectDetector(_image!); // 呼叫物件偵測函式
    Navigator.of(context).pop(); // 關閉模態對話框
  }

  //Camera
  Future<void> _pickImageFromCamera() async {
    final returnImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      selectedIMage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    ObjectDetector(_image!); // 呼叫物件偵測函式
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

  ObjectDetector(Uint8List image) async {
    if (_isModelRunning) {
      // 模型正在運行，跳過這個請求
      return;
    }
    _isModelRunning = true;
    try {
      var detector = await Tflite.runModelOnFrame(
        bytesList: [image],
      );
      if (detector != null) {
        print("Result is $detector");
      }
    } finally {
      _isModelRunning = false;
    }
  }
}
