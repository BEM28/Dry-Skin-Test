import 'package:dry_skin/src/features/home_screen/controllers/camera_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyHomePageScreen extends StatelessWidget {
  const MyHomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraController = Get.put(CameraController());
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                cameraController.isLoading.value
                    ? const CircularProgressIndicator()
                    : const SizedBox(),
                cameraController.imageBytes.value.isEmpty
                    ? const SizedBox()
                    : Image.memory(cameraController.imageBytes.value,
                        width: 224, height: 224),
                cameraController.imageBytes.value.isEmpty
                    ? const SizedBox()
                    : Text(cameraController.classificationResult.value),
                ElevatedButton(
                    onPressed: cameraController.takePicture,
                    child: Text('Open Camera'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
