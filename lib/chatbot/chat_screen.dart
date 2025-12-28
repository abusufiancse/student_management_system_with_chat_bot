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
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('AI Assistant'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ================= CHAT AREA =================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final m = messages[i];
                  final isUser = m['role'] == 'user';

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors.black
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 16),
                        ),
                      ),
                      child: Text(
                        m['text']!,
                        style: TextStyle(
                          color:
                          isUser ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ================= INPUT BAR =================
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: inputCtrl,
                        decoration: const InputDecoration(
                          hintText:
                          'Ask about results, fees, profile…',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => send(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.black,
                      ),
                      onPressed: send,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
