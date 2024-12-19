import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:welding/screens/photo_screen.dart';

class PipeDetailsScreen extends StatefulWidget {
  final String pipeName;
  final String comment;
  final String pipeId;
  final List<CameraDescription> cameras;

  const PipeDetailsScreen({
    Key? key,
    required this.pipeName,
    required this.comment,
    required this.pipeId,
    required this.cameras,
  }) : super(key: key);

  @override
  _PipeDetailsScreenState createState() => _PipeDetailsScreenState();
}

class _PipeDetailsScreenState extends State<PipeDetailsScreen> {
  late Future<List<Map<String, dynamic>>> imageList;
  late TextEditingController _commentController;
  late String _localComment; 

  @override
  void initState() {
    super.initState();
    imageList = fetchImages();
    _localComment = widget.comment;
    _commentController = TextEditingController(text: _localComment);
  }

  // Función para cargar imágenes
  Future<List<Map<String, dynamic>>> fetchImages() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.42:5000/api/images/pipe/${widget.pipeId}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      return List<Map<String, dynamic>>.from(data.map((item) {
        return {
          "id": item["image_id"],
          "imageBytes": base64Decode(item["generated_image"]),
        };
      }));
    } else {
      throw Exception('Failed to load images');
    }
  }

  // Función para eliminar una imagen
  Future<void> deleteImage(int imageId) async {
    final response = await http.delete(
      Uri.parse('http://192.168.1.42:5000/api/images/$imageId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        imageList = fetchImages(); 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen eliminada correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar la imagen')),
      );
    }
  }

  // Función para eliminar un pipe
  Future<void> deletePipe(String pipeId) async {
    final response = await http.delete(
      Uri.parse('http://192.168.1.42:5000/api/pipes/$pipeId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pipe eliminado correctamente')),
      );
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el pipe')),
      );
    }
  }

  // Función para editar el comentario
  Future<void> editComment(String newComment, String pipeName, String pipeId) async {
    final response = await http.put(
      Uri.parse('http://192.168.1.42:5000/api/pipes/$pipeId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': pipeName,
        'comment': newComment,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _localComment = newComment;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario actualizado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el comentario')),
      );
    }
  }

  
  void _onSaveComment() {
    String newComment = _commentController.text;
    if (newComment.isNotEmpty) {
      editComment(newComment, widget.pipeName, widget.pipeId);
      Navigator.of(context).pop(); 
    }
  }

  
  void showImageDialog(Map<String, dynamic> imageData) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.memory(
                  imageData['imageBytes'],
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.5,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    deleteImage(imageData['id']); 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:Color.fromARGB(255, 4, 110, 172),
                  ),
                  child: Text(
                    "Eliminar",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pipeName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 4, 110, 172),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Eliminar Pipe'),
                    content: const Text('¿Estás seguro de que deseas eliminar este pipe?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          deletePipe(widget.pipeId);
                          Navigator.pop(context);
                        },
                        child: const Text('Eliminar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: (){
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Editar Comentario'),
                    content: TextField(
                      controller: _commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Ingresa el nuevo comentario'),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          _onSaveComment();
                        },
                        child: const Text('Guardar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
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
                color: Color.fromARGB(255, 4, 110, 172),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _localComment,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Text(
              "Imágenes:",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 4, 110, 172),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: imageList,
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
                    List<Map<String, dynamic>> images = snapshot.data!;
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => showImageDialog(images[index]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              images[index]['imageBytes'],
                              fit: BoxFit.cover,
                            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  PhotoScreen(cameras: widget.cameras, pipeId: widget.pipeId),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween =
                    Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
