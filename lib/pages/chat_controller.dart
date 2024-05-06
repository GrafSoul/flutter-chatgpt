import 'package:get/get.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatController extends GetxController {
  late final String apiKey;
  late final OpenAI _openAI;

  final ChatUser currentUser = ChatUser(id: '1', firstName: 'John', lastName: 'Doe');
  final ChatUser gptChatUser = ChatUser(id: '2', firstName: 'Chat', lastName: 'GPT');

  var messages = <ChatMessage>[].obs;
  var typingUsers = <ChatUser>[].obs;

  @override
  void onInit() {
    super.onInit();
    apiKey = dotenv.get('API_OPENAI_KEY', fallback: 'Unknown');
    _openAI = OpenAI.instance.build(
      token: apiKey,
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 5),
      ),
      enableLog: true,
    );
  }

  Future<void> sendMessage(ChatMessage m) async {
    messages.insert(0, m);
    typingUsers.add(gptChatUser);

    List<Messages> messagesHistory = messages.reversed.map((m) {
      if (m.user == currentUser) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();

    String getRoleString(Role role) {
      switch (role) {
        case Role.user:
          return 'user';
        case Role.assistant:
          return 'assistant';
        default:
          return 'user';
      }
    }

    List<Map<String, dynamic>> messagesAsMaps = messagesHistory.map((message) {
      return {'role': getRoleString(message.role), 'content': message.content};
    }).toList();

    final request = ChatCompleteText(
      model: GptTurbo0301ChatModel(),
      messages: messagesAsMaps,
      maxToken: 200,
    );

    final response = await _openAI.onChatCompletion(request: request);

    for (var element in response!.choices) {
      if (element.message != null) {
        messages.insert(
          0,
          ChatMessage(user: gptChatUser, createdAt: DateTime.now(), text: element.message!.content),
        );
      }
    }

    typingUsers.remove(gptChatUser);
  }
}
