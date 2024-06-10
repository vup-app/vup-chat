import 'package:bluesky_chat/bluesky_chat.dart';
import 'package:vup_chat/main.dart';

Future<ListConvosOutput?> getChatTimeline() async {
  if (chatSession != null) {
    ListConvosOutput ref = (await chatSession!.convo.listConvos()).data;
    return ref;
  }
  return null;
}

Future<void> sendMessage(String text, String uid) async {
  if (chatSession != null && text.isNotEmpty) {
    await chatSession!.convo
        .sendMessage(convoId: uid, message: MessageInput(text: text));
  }
}

Future<String?> getChatIDFromUID(String uid) async {
  if (chatSession != null && uid.isNotEmpty) {
    GetConvoForMembersOutput resp =
        (await chatSession!.convo.getConvoForMembers(members: [uid])).data;
    return (resp.convo.id);
  }
  return null;
}

Future<String?> getUserFromUID(String uid) async {
  if (chatSession != null && uid.isNotEmpty) {
    GetConvoForMembersOutput resp =
        (await chatSession!.convo.getConvoForMembers(members: [uid])).data;
    return (resp.convo.members.last.displayName);
  }
  return null;
}
