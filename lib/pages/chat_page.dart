import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'chat_controller.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 166, 126, 1),
        title: const Text(
          'GPT Chat',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Obx(
        () => DashChat(
          currentUser: chatController.currentUser,
          typingUsers: chatController.typingUsers.toList(),
          messageOptions: const MessageOptions(
            currentUserContainerColor: Colors.black,
            containerColor: Color.fromRGBO(0, 166, 126, 1),
            textColor: Colors.white,
          ),
          onSend: (ChatMessage m) => chatController.sendMessage(m),
          messages: chatController.messages.toList(),
        ),
      ),
    );
  }
}
