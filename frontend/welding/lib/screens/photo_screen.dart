import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';

class PhotoScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  PhotoScreen(this.cameras);

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  late CameraController controller;
  bool _isTakingPhoto = false;
  String _imagePath = '';

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      controller = CameraController(widget.cameras[0], ResolutionPreset.high);
      controller.initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      }).catchError((e) {
        print("Error initializing camera: $e");
      });
    } else {
      print("No cameras available");
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (!_isTakingPhoto) {
      setState(() {
        _isTakingPhoto = true;
      });

      try {
        final XFile file = await controller.takePicture();
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await file.saveTo(path);
        
        setState(() {
          _imagePath = path;
        });

        _showUploadDialog();
      } catch (e) {
        print("Error taking photo: $e");
        setState(() {
          _isTakingPhoto = false;
        });
      }
    }
  }

  Future<void> _uploadImageToServer(String imagePath) async {
    final Uri url = Uri.parse('http://192.168.1.42:5000/api/pipes/1/images/');
    final request = http.MultipartRequest('POST', url)
      ..headers.addAll({'Accept': 'application/json'});

    final file = await http.MultipartFile.fromPath(
      'image',
      imagePath,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(file);

    try {
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);

      if (response.statusCode == 200) {
        print('Image uploaded successfully: $responseString');
        Navigator.pop(context); 
      } else {
        print('Failed to upload image: ${response.statusCode}');
        print('Error details: $responseString');
        Navigator.pop(context); 
        _showErrorDialog('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      Navigator.pop(context); 
      _showErrorDialog('Error uploading image: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_imagePath.isNotEmpty) {
                  _uploadImageToServer(_imagePath);
                } else {
                  print('Image path is empty');
                }
              },
              child: Text('Upload'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                File(_imagePath).delete();
                setState(() {
                  _imagePath = '';
                });
              },
              child: Text('Discard'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take Photos')),
      body: Column(
        children: [
          controller.value.isInitialized
              ? CameraPreview(controller)
              : Center(child: CircularProgressIndicator()),

          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _takePhoto,
          ),
          Expanded(
            child: _imagePath.isNotEmpty
                ? Image.file(File(_imagePath))
                : Center(child: Text('No image selected')),
          ),
        ],
      ),
    );
  }
}
