import 'package:vup_chat/main.dart';

Future<void> getChatTimeline() async {
  if (chatSession != null) {
    final ref = await chatSession!.convo.listConvos();
  }
}
