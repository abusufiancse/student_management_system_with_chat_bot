import 'package:flutter/material.dart';
import '../../chatbot/bot_engine.dart';

class ChatScreen extends StatefulWidget {
  final int studentId;
  final String role; // 'student' or 'parent'

  const ChatScreen({
    super.key,
    required this.studentId,
    required this.role,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final inputCtrl = TextEditingController();
  final List<Map<String, String>> messages = [];

  @override
  void dispose() {
    inputCtrl.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final text = inputCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'text': text});
    });

    inputCtrl.clear();

    final reply = await BotEngine.reply(
      question: text,
      studentId: widget.studentId,
      role: widget.role,
    );

    if (!mounted) return;
    setState(() {
      messages.add({'role': 'bot', 'text': reply});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
      ),
      body: Column(
        children: [
          // ================= CHAT AREA =================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final m = messages[i];
                final isUser = m['role'] == 'user';

                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(m['text']!),
                  ),
                );
              },
            ),
          ),

          // ================= INPUT =================
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: inputCtrl,
                    decoration: const InputDecoration(
                      hintText:
                      'Ask about results, fees, profile, etc...',
                    ),
                    onSubmitted: (_) => send(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

