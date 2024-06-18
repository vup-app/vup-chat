import 'package:bluesky_chat/bluesky_chat.dart';
import 'package:flutter/material.dart';
import 'package:vup_chat/screens/chat_individual_page.dart';
import 'package:vup_chat/screens/search_actor.page.dart';
import 'package:vup_chat/screens/settings_page.dart';

class HomeRoutingService {
  Widget rightPanel;
  final void Function(Widget widget) onRightPanelChanged;

  HomeRoutingService(
      {required this.rightPanel, required this.onRightPanelChanged});

  void onNewChatSelected() {
    onRightPanelChanged(SearchActorPage(onChatSelected: onChatSelected));
  }

  void onChatSelected(ConvoView convo) {
    onRightPanelChanged(ChatIndividualPage(
      id: convo.id,
      otherName: convo.members.map((m) => m.displayName).last ?? "null",
      avatar: convo.members.last.avatar != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(convo.members.last.avatar!),
            )
          : const CircleAvatar(child: Icon(Icons.person)),
    ));
  }

  void navigateToSettings() {
    onRightPanelChanged(const SettingsPage());
  }
}
