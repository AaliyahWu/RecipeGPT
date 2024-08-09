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

class PickImage1 extends StatefulWidget {
  const PickImage1({super.key});

  @override
  State<PickImage1> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage1> {
  Uint8List? _image;
  File? selectedIMage;
  bool _isNextButtonEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '生成食譜',
          style: TextStyle(color: Colors.black), // Set text color to white
        ),
        backgroundColor: Color(0xFFF1E9E6),
        iconTheme: IconThemeData(color: Colors.black), // Set back button
      ),
      backgroundColor: Color(0xFFF1E9E6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '拍照! 尋找可用食材~',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 80),
            _image != null
                ? AspectRatio(
                    aspectRatio: 1, // 固定比例 1:1
                    child: Image.memory(_image!),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                      color: Color.fromRGBO(255, 255, 255, 0.8),
                      image: DecorationImage(
                        image: AssetImage('assets/image/note.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5),
                          BlendMode.dstATop,
                        ),
                      ),
                    ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF2B892), // 背景顏色
                    foregroundColor: Colors.white, // 文字顏色
                  ),
                  child: const Icon(Icons.add_a_photo,
                      color: Colors.white), // 調整圖標顏色
                ),
                SizedBox(width: 20), // 在兩個按鈕之間增加空間
                ElevatedButton(
                  onPressed: _isNextButtonEnabled
                      ? () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => CheckList()), // 勾選辨識清單頁面
                          // );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF2B892), // 背景顏色
                    foregroundColor: Colors.white, // 文字顏色
                  ),
                  child: Text('下一步'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Color(0xFFF2B892),
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
                              color: Colors.white, // Set icon color to white
                            ),
                            Text("相簿",
                                style: TextStyle(
                                    color: Colors
                                        .white)) // Set text color to white
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
                              color: Colors.white, // Set icon color to white
                            ),
                            Text("相機",
                                style: TextStyle(
                                    color: Colors
                                        .white)) // Set text color to white
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
    setState(() {
      selectedIMage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
      _isNextButtonEnabled = true;
    });
    Navigator.of(context).pop(); // 關閉模態對話框
  }

  //Camera
  Future<void> _pickImageFromCamera() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      selectedIMage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
      _isNextButtonEnabled = true;
    });
    Navigator.of(context).pop(); // 關閉模態對話框
  }
}
