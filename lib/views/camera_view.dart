//相機視圖
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_gpt/controller/scan_controller.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ScanController>(
        init: ScanController(),
        //初始化控制器
        builder: (controller) {
          return controller.isCameraInitialized.value ? 
          CameraPreview(controller.cameraController): 
          const Center(child: Text("載入中......"));
        }
      ),
    );
  }
}