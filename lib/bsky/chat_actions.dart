import 'package:bluesky_chat/bluesky_chat.dart';
import 'package:vup_chat/main.dart';

Future<ListConvosOutput?> getChatTimeline() async {
  if (chatSession != null) {
    ListConvosOutput ref = (await chatSession!.convo.listConvos()).data;
    return ref;
  }
  return null;
}
