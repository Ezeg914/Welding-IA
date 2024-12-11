import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class PhotoScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String pipeId;

  PhotoScreen({required this.cameras, required this.pipeId});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  late CameraController controller;
  int _selectedCameraIndex = 0;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    _initCamera(_selectedCameraIndex);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _initCamera(int cameraIndex) async {
    controller = CameraController(
      widget.cameras[cameraIndex],
      ResolutionPreset.max,
    );

    try {
      await controller.initialize();
      setState(() {
        _isFrontCamera = cameraIndex == 1; // Ajustar según la configuración de tus cámaras
      });
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  void _toggleFlashLight() {
    if (_isFlashOn) {
      controller.setFlashMode(FlashMode.off);
      setState(() {
        _isFlashOn = false;
      });
    } else {
      controller.setFlashMode(FlashMode.torch);
      setState(() {
        _isFlashOn = true;
      });
    }
  }

  void _switchCamera() async {
    if (controller != null) {
      await controller.dispose();
    }
    _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
    _initCamera(_selectedCameraIndex);
  }

  Future<void> _capturePhoto() async {
    try {
      final XFile photo = await controller.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await photo.saveTo(path);

      // Enviar la imagen al servidor
      final response = await _uploadPhoto(File(path));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo uploaded successfully: ${response.body}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload photo: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("Error capturing photo: $e");
    }
  }

  Future<http.Response> _uploadPhoto(File photo) async {
    final uri = Uri.parse('http://192.168.1.42:5000/api/pipes/${widget.pipeId}/images/');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', photo.path));

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Stack(
              children: [
                Positioned.fill(
                  child: controller.value.isInitialized
                      ? CameraPreview(controller)
                      : Center(child: CircularProgressIndicator()),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    color: Colors.black.withOpacity(0.5),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                          ),
                          onPressed: _toggleFlashLight,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 130,
                    color: Colors.black.withOpacity(0.7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.cameraswitch,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: _switchCamera,
                        ),
                        GestureDetector(
                          onTap: _capturePhoto,
                          child: Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
