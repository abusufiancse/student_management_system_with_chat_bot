import 'package:flutter/material.dart';
import '../chatbot/bot_engine.dart';

class ChatScreen extends StatefulWidget {
  final int studentId;

  const ChatScreen({super.key, required this.studentId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'text': text});
    });

    controller.clear();

    final reply = await BotEngine.reply(text, widget.studentId);

    setState(() {
      messages.add({'role': 'bot', 'text': reply});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: messages.map((m) {
                final isUser = m['role'] == 'user';
                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      m['text']!,
                      style: TextStyle(
                          color: isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration:
                  const InputDecoration(hintText: 'Ask something...'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: sendMessage,
              )
            ],
          )
        ],
      ),
    );
  }
}
