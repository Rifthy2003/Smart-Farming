import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'database_helper.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  File? _image;
  bool _isLoading = false;
  String _plantName = "";
  String _details =
      "Take a photo of a leaf to identify the plant and get a diagnosis.";

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
    var uri = Uri.parse(
        'https://my-api.plantnet.org/v2/identify/all?api-key=$_plantNetKey');

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
        var result = data['results'][0];

        String name = result['species']['commonNames']?[0] ??
            result['species']['scientificNameWithoutAuthor'];
        String confidence = (result['score'] * 100).toStringAsFixed(1);
        String family = result['species']['family']['scientificNameWithoutAuthor'];

        setState(() {
          _plantName = name;
          _details = "Match: $confidence% | Family: $family";
          _isLoading = false;
        });

        await DatabaseHelper().insertHistory(_plantName, _details);
      } else {
        setState(() {
          _plantName = "Scan Failed";
          _details = "Could not identify. Ensure the leaf is clear.";
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
      // ================= FULL SCREEN BACKGROUND =================
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ===== HEADER BUBBLE =====
                _glassBubble(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Plant Doctor",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                ),

                const SizedBox(height: 24),

                // ===== IMAGE BUBBLE =====
                _glassBubble(
                  child: _image == null
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.filter_center_focus,
                                  size: 80, color: Colors.white),
                              SizedBox(height: 10),
                              Text(
                                "No image selected",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                            height: 320,
                            width: double.infinity,
                          ),
                        ),
                  height: 320,
                ),

                const SizedBox(height: 30),

                // ===== RESULT BUBBLE =====
                _glassBubble(
                  child: Column(
                    children: [
                      Text(
                        _plantName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _details,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                ),

                const SizedBox(height: 30),

                // ===== ACTION BUTTONS =====
                if (!_isLoading)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _glassCircleButton(Icons.camera_alt, "Camera",
                          () => _pickImage(ImageSource.camera)),
                      _glassCircleButton(Icons.photo_library, "Gallery",
                          () => _pickImage(ImageSource.gallery)),
                    ],
                  ),

                if (_isLoading) ...[
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 10),
                  const Text("Analyzing...",
                      style: TextStyle(color: Colors.white70)),
                ],

                const SizedBox(height: 30),

                // ===== TREATMENT BUTTON =====
                if (_plantName.isNotEmpty &&
                    !_isLoading &&
                    _plantName != "Analyzing..." &&
                    _plantName != "Error")
                  _glassBubble(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/chatbot',
                            arguments: _plantName);
                      },
                      icon: const Icon(Icons.auto_fix_high),
                      label: const Text("GET TREATMENT PLAN"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orangeAccent.withAlpha((0.85 * 255).round()),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= GLASS BUBBLE =================
  Widget _glassBubble(
      {required Widget child, double? height, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: height,
          padding: padding,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.15 * 255).round()),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha((0.2 * 255).round())),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glassCircleButton(
      IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.15 * 255).round()),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withAlpha((0.2 * 255).round())),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 4)),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
