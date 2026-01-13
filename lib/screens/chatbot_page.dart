import 'package:flutter/material.dart';
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

  // Replace with your actual Gemini API Key from Google AI Studio
  final String _apiKey = "AIzaSyAvAiMzpfCWI-Ge-FdLmhhUOkML3eItYvs";
  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
    _chat = _model.startChat();

    // Check for arguments after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plantName = ModalRoute.of(context)?.settings.arguments as String?;
      if (plantName != null && plantName.isNotEmpty) {
        _autoSendTreatmentPrompt(plantName);
      }
    });
  }

  // Automatically asks Gemini for treatment when coming from the Doctor Page
  void _autoSendTreatmentPrompt(String plantName) {
    String prompt = "I have a $plantName plant. It looks unhealthy based on my scan. "
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
        _messages.add({"role": "bot", "text": response.text ?? "I'm not sure how to help with that."});
      });
    } catch (e) {
      setState(() {
        _messages.add({"role": "bot", "text": "Error: Could not connect to AI. Check your API key."});
      });
    } finally {
      setState(() => _isTyping = false);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI FARM ASSISTANT"),
        backgroundColor: Colors.greenAccent[400],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.greenAccent[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(msg["text"]!, style: const TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
          ),
          if (_isTyping) const Padding(padding: EdgeInsets.all(8.0), child: LinearProgressIndicator()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Ask about crops, pests...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.green),
            onPressed: () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }
}