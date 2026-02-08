import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'database_helper.dart'; // Ensure this file exists from previous step

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  File? _image;
  bool _isLoading = false;
  String _plantName = "";
  String _details = "Take a photo of a leaf to identify the plant and get a diagnosis.";
  
  // REPLACE with your key from https://my.plantnet.org/
  final String _plantNetKey = "2b10Y984WSGSCFU7hhergHbrDO"; 

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80, 
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
        _plantName = "Analyzing...";
      });
      _analyzeWithPlantNet(_image!);
    }
  }

  Future<void> _analyzeWithPlantNet(File imageFile) async {
    // API Route for identification
    var uri = Uri.parse('https://my-api.plantnet.org/v2/identify/all?api-key=$_plantNetKey');
    
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath(
      'images', 
      imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var result = data['results'][0]; // Get top match
        
        String name = result['species']['commonNames']?[0] ?? 
                     result['species']['scientificNameWithoutAuthor'];
        String confidence = (result['score'] * 100).toStringAsFixed(1);
        String family = result['species']['family']['scientificNameWithoutAuthor'];

        setState(() {
          _plantName = name;
          _details = "Match: $confidence% | Family: $family";
          _isLoading = false;
        });

        // SAVE TO LOCAL DATABASE HISTORY
        await DatabaseHelper().insertHistory(_plantName, _details);

      } else {
        setState(() {
          _plantName = "Scan Failed";
          _details = "Could not identify. Please ensure the leaf is centered and clear.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _plantName = "Error";
        _details = "Please check your internet connection.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("PLANT DOCTOR", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.greenAccent[400],
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Image Preview Card
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 320,
                decoration: BoxDecoration(
                  color: Colors.greenAccent[50],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.greenAccent[400]!, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                  ],
                ),
                child: _image == null 
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_center_focus, size: 80, color: Colors.greenAccent[400]),
                        const SizedBox(height: 10),
                        const Text("No image selected", style: TextStyle(color: Colors.black45)),
                      ],
                    ) 
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(28), 
                      child: Image.file(_image!, fit: BoxFit.cover)
                    ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Result Display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Text(_plantName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 10),
                  Text(_details, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Interface Buttons
            if (!_isLoading) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _circleIconButton(Icons.camera_alt, "Camera", () => _pickImage(ImageSource.camera)),
                  const SizedBox(width: 50),
                  _circleIconButton(Icons.photo_library, "Gallery", () => _pickImage(ImageSource.gallery)),
                ],
              ),
              const SizedBox(height: 40),
              
              // TREATMENT BUTTON (Appears only if a plant is found)
              if (_plantName.isNotEmpty && _plantName != "Analyzing..." && _plantName != "Error") 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to Chatbot and pass plant name as argument
                      Navigator.pushNamed(context, '/chatbot', arguments: _plantName);
                    },
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text("GET TREATMENT PLAN"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 5,
                    ),
                  ),
                ),
            ] else 
              const Column(
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 10),
                  Text("Consulting Database...", style: TextStyle(color: Colors.grey)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _circleIconButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.greenAccent[400],
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)],
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}