import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vup_chat/bsky/chat_actions.dart';
import 'package:vup_chat/bsky/profile_actions.dart';
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
  List<ActorProfile> _profiles = [];

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
      final List<Actor> actors =
          (await session!.actor.searchActors(term: term)).data.actors;
      final List<ActorProfile> profiles = (await session!.actor
              .getProfiles(actors: actors.map((actor) => actor.did).toList()))
          .data
          .profiles;
      setState(() {
        _actors = actors;
        _profiles = profiles;
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
                final profile = _profiles[index];
                return _buildActorListItem(actor, context, profile);
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

  Widget _buildActorListItem(
      Actor actor, BuildContext context, ActorProfile profile) {
    final String? title = actor.displayName;
    final CircleAvatar avatar = CircleAvatar(
      backgroundImage:
          actor.avatar != null ? NetworkImage(actor.avatar!) : null,
      child: const Icon(Icons.person),
    );

    late Widget allowIncomingMessages;

    String status = "none"; // Default status, change as per your logic

    try {
      if (profile.associated != null && profile.associated!.chat != null) {
        status = profile.associated!.chat!.allowIncoming ?? "none";
      }
    } catch (e) {
      print("Error fetching status: $e");
    }

    switch (status) {
      case "none":
        allowIncomingMessages = Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
        );
        break;
      case "following":
        allowIncomingMessages = Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.yellow,
          ),
        );
        break;
      case "all":
        allowIncomingMessages = Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
        );
        break;
      default:
        allowIncomingMessages = Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
          ),
        );
    }

    // TODO, fix align and make this dissapear
    bool showFollow = true;

    return ListTile(
      title: Text(title ?? "null"),
      leading: avatar,
      trailing: SizedBox(
        width: 55,
        child: Align(
          alignment: Alignment.centerRight,
          child: Row(
            children: [
              if (!showFollow || profile.isNotFollowing)
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    // Update showFollow state and perform action
                    setState(() {
                      showFollow = false;
                    });
                    followUser(profile.did);
                  },
                ),
              const SizedBox(width: 5),
              allowIncomingMessages,
            ],
          ),
        ),
      ),
      onTap: () {
        _pushToIndividualChatPage(context, actor, avatar);
      },
    );
  }
}
