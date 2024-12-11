import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class PipeDetailsScreen extends StatefulWidget {
  final String pipeName;
  final String comment;
  final String pipeId;

  const PipeDetailsScreen({
    Key? key,
    required this.pipeName,
    required this.comment,
    required this.pipeId,
  }) : super(key: key);

  @override
  _PipeDetailsScreenState createState() => _PipeDetailsScreenState();
}

class _PipeDetailsScreenState extends State<PipeDetailsScreen> {
  late Future<List<Uint8List>> imageBytesList;

  @override
  void initState() {
    super.initState();
    imageBytesList = fetchImages();
  }

  Future<List<Uint8List>> fetchImages() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.42:5000/api/images/pipe/${widget.pipeId}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Uint8List>.from(data.map((item) {
        String base64String = item['generated_image'];
        return base64Decode(base64String);
      }));
    } else {
      throw Exception('No load images');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pipeName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5A04AC),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Comentario:",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A04AC),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.comment,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Text(
              "Imágenes:",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A04AC),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Uint8List>>(
                future: imageBytesList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No hay imágenes disponibles.",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    );
                  } else {
                    List<Uint8List> images = snapshot.data!;
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            images[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
