import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class CameraController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  var imageBytes = Uint8List(0).obs;
  var classificationResult = ''.obs;
  var isLoading = false.obs;
  var isRefresh = false.obs;
  late Interpreter _interpreter;

  @override
  void onInit() {
    super.onInit();
    imageBytes.value = Uint8List(0);
    isRefresh.value = false;

    _loadModel();
  }

  void _loadModel() async {
    try {
      _interpreter =
          await Interpreter.fromAsset('assets/model/model_unquant.tflite');
      print('Model berhasil dimuat.');
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  void takePicture() async {
    isRefresh.value = false;
    classificationResult.value = '';
    imageBytes.value = Uint8List(0);
    final XFile? picture = await _picker.pickImage(source: ImageSource.camera);
    if (picture != null) {
      imageBytes.value = await picture.readAsBytes();
      // classifyImage(imageBytes.value);
      isRefresh.value = true;
    }
  }

  void classifyImage() async {
    try {
      isLoading.value = true;

      if (imageBytes.value.isEmpty) {
        classificationResult.value = "Gambar tidak ada atau tidak valid.";
        return;
      }

      var decodedImage = img.decodeImage(imageBytes.value);
      if (decodedImage == null) {
        classificationResult.value = "Gagal memproses gambar: Dekoding gagal.";
        isLoading.value = false;
        return;
      }

      var input = _preprocessImage(decodedImage);
      if (input == null) {
        classificationResult.value =
            "Gagal memproses gambar: Input tidak valid.";
        isLoading.value = false;
        return;
      }

      if (_interpreter == null) {
        classificationResult.value = "Interpreter belum dimuat dengan benar.";
        isLoading.value = false;
        return;
      }

      // Update the output buffer to match the model's output shape of [1, 3]
      var output = List.filled(3, 0.0).reshape([1, 3]);

      try {
        _interpreter.run(input, output);
      } catch (e) {
        print("Error running model: $e");
        classificationResult.value = "Gagal menjalankan model: $e";
        return;
      }

      // Update the classification logic based on the new output shape
      if (output[0][0] > output[0][1] && output[0][0] > output[0][2]) {
        classificationResult.value = "Kulit Kering"; // Class 0
      } else if (output[0][1] > output[0][0] && output[0][1] > output[0][2]) {
        classificationResult.value = "Kulit Lembab"; // Class 1
      } else {
        classificationResult.value =
            "Kulit Normal"; // Class 2 (new class added)
      }

      print('[INFO] $classificationResult');
    } catch (e) {
      print("Error processing image: $e");
      classificationResult.value = "Terjadi kesalahan saat memproses gambar.";
    } finally {
      isLoading.value = false;
    }
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Resize image
    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

    // Get the byte array of the image
    var convertedBytes = resizedImage.getBytes();

    // Check if the resized image's byte length is as expected (RGB only: 3 bytes per pixel)
    if (convertedBytes.length != 224 * 224 * 3) {
      throw Exception(
          'Ukuran gambar tidak sesuai dengan yang diharapkan: ${convertedBytes.length}');
    }

    // Normalize pixel values and prepare input for the interpreter
    var input = List.generate(
        1,
        (i) => List.generate(
            224,
            (y) => List.generate(
                224,
                (x) => [
                      convertedBytes[(y * 224 + x) * 3] / 255.0, // Red
                      convertedBytes[(y * 224 + x) * 3 + 1] / 255.0, // Green
                      convertedBytes[(y * 224 + x) * 3 + 2] / 255.0 // Blue
                    ])));

    return input; // Return the input ready for the model
  }
}
