import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:welding/main.dart';
import 'dart:convert';
import 'package:welding/screens/pipe_image_screen.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> pipesData = [];

  @override
  void initState() {
    super.initState();
    fetchPipes();
  }

Future<void> fetchPipes() async {
  final response = await http.get(
    Uri.parse('http://192.168.1.42:5000/api/pipes/'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);

    setState(() {
      pipesData = data.map((item) {
        return {
          'pipe_id': item['pipe_id'],
          'name': item['name'],
          'comment': item['comment'] ?? 'No comment available',
          'images': List<String>.from(item['images'] ?? []), 
        };
      }).toList();
    });
  } else {
    throw Exception('Failed to load pipes');
  }
}



void navigateToPipeDetails(BuildContext context, Map<String, dynamic> pipe) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PipeDetailsScreen(
        pipeId: pipe['pipe_id'].toString(), 
        pipeName: pipe['name'],
        comment: pipe['comment'],
        cameras: cameras,
      ),
    ),
  );
}


  Future<void> showCreatePipeDialog(BuildContext context) async {
    final TextEditingController pipeNameController = TextEditingController();
    final TextEditingController pipeCommentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Create a New Pipe"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pipeNameController,
                decoration: InputDecoration(labelText: "Pipe Name"),
              ),
              TextField(
                controller: pipeCommentController,
                decoration: InputDecoration(labelText: "Pipe Comment"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                String name = pipeNameController.text;
                String comment = pipeCommentController.text;
                createPipe(name, comment);
                Navigator.pop(context);
              },
              child: Text("Create"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> createPipe(String name, String comment) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.42:5000/api/pipes/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'comment': comment,
      }),
    );
    if (response.statusCode == 201) {
      fetchPipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 20,
            child: Text(
              "Welding Detector",
              style: TextStyle(
                color: Color(0xFF1E88E5),
                fontSize: 30,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(top: 100, left: 10, right: 10, bottom: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E88E5),
                    Color(0xFF64B5F6),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(20),
                  topRight: Radius.circular(80),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF64B5F6),
                    offset: Offset(3, 6),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Pipes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: pipesData.length,
                      itemBuilder: (context, index) {
                        final pipe = pipesData[index];
                        return GestureDetector(
                          onTap: () {
                            navigateToPipeDetails(context, pipe);
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 4.0,
                            child: ListTile(
                              title: Text(
                                pipe['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreatePipeDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      
    );
  }
}