import 'dart:ui';

import 'package:dry_skin/src/features/home_screen/controllers/camera_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyHomePageScreen extends StatelessWidget {
  const MyHomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraController = Get.put(CameraController());
    return Scaffold(
      body: Obx(
        () => Stack(
          children: [
            cameraController.imageBytes.value.isEmpty
                ? const SizedBox()
                : Image.memory(
                    cameraController.imageBytes.value,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
            cameraController.classificationResult.value.isEmpty
                ? const SizedBox()
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            color: Colors.transparent,
                            child: Text(
                              cameraController.classificationResult.value,
                              style: const TextStyle(
                                  color: Color(0xFF161616),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  height: 150,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: cameraController.isRefresh.value
                                ? cameraController.classifyImage
                                : cameraController.takePicture,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF45D782)),
                            child: cameraController.isLoading.value
                                ? const CircularProgressIndicator()
                                : Text(
                                    cameraController.isRefresh.value
                                        ? 'Scan'
                                        : 'Open Camera',
                                    style: const TextStyle(
                                        color: Color(0xFF161616),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  )),
                      ),
                      cameraController.isRefresh.value
                          ? const SizedBox(width: 10)
                          : const SizedBox(),
                      cameraController.isRefresh.value
                          ? ElevatedButton(
                              onPressed: cameraController.takePicture,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF26E65)),
                              child: const Icon(
                                Icons.refresh,
                                color: Color(0xFF161616),
                              ))
                          : const SizedBox(),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
