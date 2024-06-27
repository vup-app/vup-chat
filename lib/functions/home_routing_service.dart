import 'package:flutter/material.dart';
import 'package:vup_chat/screens/chat_individual_page.dart';
import 'package:vup_chat/screens/profile_page.dart';
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

  void onChatSelected(
      String id, String title, CircleAvatar avatar, String? mID) {
    onRightPanelChanged(ChatIndividualPage(
      id: id,
      otherName: title,
      avatar: avatar,
      messageIdToScrollTo: mID,
    ));
  }

  void navigateToSettings() {
    onRightPanelChanged(const SettingsPage());
  }

  void navigateToProfile() {
    onRightPanelChanged(const ProfilePage());
  }
}
