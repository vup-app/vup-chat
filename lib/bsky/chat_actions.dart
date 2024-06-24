import 'package:bluesky_chat/bluesky_chat.dart';
import 'package:vup_chat/main.dart';

Future<ListConvosOutput?> getChatTimeline() async {
  if (chatSession != null) {
    ListConvosOutput ref = (await chatSession!.convo.listConvos()).data;
    return ref;
  }
  return null;
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

Future<ConvoView?> getConvoFromUID(String uid) async {
  if (chatSession != null && uid.isNotEmpty) {
    GetConvoForMembersOutput resp =
        (await chatSession!.convo.getConvoForMembers(members: [uid])).data;
    return (resp.convo);
  }
  return null;
}
