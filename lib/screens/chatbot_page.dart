import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  // Replace with your actual Gemini API Key
  final String _apiKey = "AIzaSyADifM0OsBdwWFYnOiDC2mveLDX4b8xDo4";
  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
    _chat = _model.startChat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plantName = ModalRoute.of(context)?.settings.arguments as String?;
      if (plantName != null && plantName.isNotEmpty) {
        _autoSendTreatmentPrompt(plantName);
      }
    });
  }

  void _autoSendTreatmentPrompt(String plantName) {
    String prompt =
        "I have a $plantName plant. It looks unhealthy based on my scan. "
        "Can you provide a detailed organic treatment plan and prevention tips?";
    _sendMessage(prompt, isVisible: false);
  }

  Future<void> _sendMessage(String text, {bool isVisible = true}) async {
    if (text.isEmpty) return;

    setState(() {
      if (isVisible) _messages.add({"role": "user", "text": text});
      _isTyping = true;
    });

    try {
      final response = await _chat.sendMessage(Content.text(text));
      setState(() {
        _messages.add({
          "role": "bot",
          "text": response.text ?? "I'm not sure how to help with that."
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "bot",
          "text": "Error: Could not connect to AI. Check your API key."
        });
      });
    } finally {
      setState(() => _isTyping = false);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Glass-style header
                _glassBubble(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "AI Chatbot",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Chat area with glass bubbles
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg["role"] == "user";

                      return Align(
                        alignment:
                            isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: _glassBubble(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Text(
                              msg["text"]!,
                              style: TextStyle(
                                fontSize: 16,
                                color: isUser ? Colors.black87 : Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            gradientColors: isUser
                                ? [
                                    Colors.white.withAlpha((0.25 * 255).round()),
                                    Colors.white.withAlpha((0.15 * 255).round())
                                  ]
                                : [
                                    Colors.white.withAlpha((0.15 * 255).round()),
                                    Colors.white.withAlpha((0.05 * 255).round())
                                  ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                if (_isTyping)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white12,
                      color: Colors.greenAccent,
                    ),
                  ),

                // Input area as glass bubble
                _glassBubble(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Ask about crops, pests...",
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.greenAccent),
                        onPressed: () => _sendMessage(_controller.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Glass bubble widget
Widget _glassBubble({
  required Widget child,
  double? height,
  EdgeInsetsGeometry? padding,
  List<Color>? gradientColors,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        height: height,
        padding: padding,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors ??
                [
                  Colors.white.withAlpha((0.15 * 255).round()),
                  Colors.white.withAlpha((0.05 * 255).round())
                ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withAlpha((0.2 * 255).round())),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}
