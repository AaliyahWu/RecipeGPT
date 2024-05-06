//掃描控制器
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:image/image.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initCamera();
    initTFLite();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cameraController.dispose();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras; //相機描述.

  var isCameraInitialized = false.obs; //相機初始化的變數
  var cameraCount = 0;

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      //初始化相機，並檢查是否被授予了相機權限
      // 如果權限已經被授予，則初始化相機
      cameras = await availableCameras(); //取得所有CAMERA
      cameraController = CameraController(
          cameras[1], //使用相機[0]:後置鏡頭，[1]是前置
          ResolutionPreset.max //分辨率設為最大值
          );
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if (cameraCount % 10 == 0) {
            cameraCount = 0;
            ObjectDetector(image);
          }
          update();
        });
      });
      isCameraInitialized(true); //初始化為True
      update(); //更新
    } else {
      print("沒有權限");
    }
  }

  initTFLite() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
  }

  ObjectDetector(CameraImage image) async {
    var detector = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((e) {
        return e.bytes;
      }).toList(),
      asynch: true,
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 1,
      rotation: 90,
      threshold: 0.4,
    );

    if (detector != null) {
      print("Result is $detector");
    }
  }
}
