import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:vup_chat/bsky/chat_actions.dart';
import 'package:vup_chat/main.dart';
import 'package:flutter/src/widgets/scroll_view.dart' as fscroll;
import 'package:vup_chat/screens/chat_individual_page.dart';

class SearchActorPage extends StatefulWidget {
  const SearchActorPage({super.key});

  @override
  SearchActorPageState createState() => SearchActorPageState();
}

class SearchActorPageState extends State<SearchActorPage> {
  final TextEditingController _controller = TextEditingController();
  List<Actor> _actors = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchActors(_controller.text);
  }

  Future<void> _searchActors(String term) async {
    if (term.isEmpty) {
      setState(() {
        _actors = [];
      });
      return;
    }

    // Replace with your actual session and search method
    if (session != null) {
      final response = await session!.actor.searchActors(term: term);
      setState(() {
        _actors = response.data.actors;
      });
    }
  }

  Future<void> _pushToIndividualChatPage(
      BuildContext context, Actor actor, CircleAvatar avatar) async {
    String? chatID = await getChatIDFromUID(actor.did);
    String? otherDispName = await getUserFromUID(actor.did);
    if (chatID != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatIndividualPage(
            id: chatID,
            otherName: otherDispName ?? "",
            avatar: avatar,
          ),
        ),
      );
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Signify which users you can and cannot chat with
    // TODO: Add follow request button to those you cannot chat with
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
      ),
      body: Column(
        children: [
          Expanded(
            child: fscroll.ListView.builder(
              reverse: true,
              itemCount: _actors.length,
              itemBuilder: (context, index) {
                final actor = _actors[index];
                return _buildActorListItem(actor, context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActorListItem(Actor actor, BuildContext context) {
    final String? title = actor.displayName;
    final CircleAvatar avatar = actor.avatar != null
        ? CircleAvatar(backgroundImage: NetworkImage(actor.avatar!))
        : const CircleAvatar(child: Icon(Icons.person));
    return ListTile(
      title: Text(title ?? "null"),
      leading: avatar,
      onTap: () {
        _pushToIndividualChatPage(context, actor, avatar);
      },
    );
  }
}
