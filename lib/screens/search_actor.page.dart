import 'package:bluesky/bluesky.dart';
import 'package:bluesky/bluesky_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vup_chat/bsky/chat_actions.dart';
import 'package:vup_chat/main.dart';
import 'package:flutter/src/widgets/scroll_view.dart' as fscroll;
import 'package:vup_chat/screens/chat_individual_page.dart';
import 'package:vup_chat/widgets/app_bar_back.dart';

class SearchActorPage extends StatefulWidget {
  final void Function(String id, String? mID)? onChatSelected;
  const SearchActorPage({super.key, this.onChatSelected});

  @override
  SearchActorPageState createState() => SearchActorPageState();
}

class SearchActorPageState extends State<SearchActorPage> {
  final TextEditingController _controller = TextEditingController();
  List<Actor> _actors = [];
  List<ActorProfile> _profiles = [];
  Map<String, bool> isPending = {};
  Map<String, bool> followedProfiles = {};

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
    if (chatID != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatIndividualPage(
            id: chatID,
          ),
        ),
      );
    }
    return;
  }

  Future<void> _splitToIndividualChat(Actor actor) async {
    ConvoView? convo = await getConvoFromUID(actor.did);
    if (convo != null) {
      widget.onChatSelected!.call(convo.id, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat'),
        leading: backButton(context),
      ),
      body: Center(
        child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            width: 200.w,
            height: 600.h,
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.h),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.h),
                          borderSide: BorderSide(
                            width: 1.h,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.h),
                          borderSide: BorderSide(
                            width: 1.h,
                          ),
                        ),
                        prefixIcon: (_controller.text.isEmpty)
                            ? const Icon(Icons.search)
                            : InkWell(
                                child: const Icon(Icons.clear),
                                onTap: () {
                                  _controller.clear();
                                },
                              ),
                        hintText: 'Search...',
                      ),
                    ),
                  ),
                ),
                _actors.isNotEmpty
                    ? Expanded(
                        child: fscroll.ListView.builder(
                          itemCount: _actors.length,
                          itemBuilder: (context, index) {
                            final actor = _actors[index];
                            final profile = _profiles[index];
                            return _buildActorListItem(actor, context, profile);
                          },
                        ),
                      )
                    : Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Center vertically
                            crossAxisAlignment: CrossAxisAlignment
                                .center, // Center horizontally
                            children: [
                              const Text(
                                "ATProto allows users to restrict their messaging preferences",
                                textAlign: TextAlign.center, // Center the text
                              ),
                              const SizedBox(
                                  height:
                                      10), // Add some spacing between the rows
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center the row horizontally
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(
                                      width:
                                          5), // Add some spacing between the circle and the text
                                  const Text("All incoming messages blocked"),
                                ],
                              ),
                              const SizedBox(
                                  height:
                                      10), // Add some spacing between the rows
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center the row horizontally
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.yellow,
                                    ),
                                  ),
                                  const SizedBox(
                                      width:
                                          5), // Add some spacing between the circle and the text
                                  const Text(
                                      "Only people they follow can message them"),
                                ],
                              ),
                              const SizedBox(
                                  height:
                                      10), // Add some spacing between the rows
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center the row horizontally
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(
                                      width:
                                          5), // Add some spacing between the circle and the text
                                  const Text("All incoming messages accepted"),
                                ],
                              )
                            ],
                          ),
                        ),
                      )
              ],
            )),
      ),
    );
  }

  Widget _buildActorListItem(
      Actor actor, BuildContext context, ActorProfile profile) {
    final String? title = actor.displayName;
    final CircleAvatar avatar = CircleAvatar(
      backgroundImage:
          actor.avatar != null ? NetworkImage(actor.avatar!) : null,
      child: actor.avatar != null ? null : const Icon(Icons.person),
    );

    late Widget allowIncomingMessages;

    String status = "none"; // Default status, change as per your logic

    try {
      if (profile.associated != null && profile.associated!.chat != null) {
        status = profile.associated!.chat!.allowIncoming;
      }
    } catch (e) {
      logger.e("Error fetching status: $e");
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

    late Widget followButton;

    if (isPending[profile.did] == true) {
      followButton = const Row(
        children: [
          SizedBox(width: 10),
          Icon(Icons.hourglass_empty),
          SizedBox(width: 5),
        ],
      );
    } else if (followedProfiles[profile.did] == true || profile.isFollowing) {
      followButton = const Row(
        children: [
          SizedBox(width: 10),
          Icon(Icons.check),
          SizedBox(width: 5),
        ],
      );
    } else if (profile.isNotFollowedBy) {
      followButton = IconButton(
        icon: const Icon(Icons.person_add),
        onPressed: () async {
          setState(() {
            isPending[profile.did] = true;
          });

          // Simulate network call
          await Future.delayed(const Duration(seconds: 2));

          // Assuming the follow request is successful
          setState(() {
            isPending[profile.did] = false;
            followedProfiles[profile.did] = true;
          });
        },
      );
    } else {
      followButton = const SizedBox(
        width: 40,
      );
    }

    return ListTile(
      title: Text(title ?? "null"),
      leading: avatar,
      trailing: SizedBox(
        width: 55,
        child: Align(
          alignment: Alignment.centerRight,
          child: Row(
            children: [
              followButton,
              const SizedBox(width: 5),
              allowIncomingMessages,
            ],
          ),
        ),
      ),
      onTap: () {
        if (widget.onChatSelected != null) {
          _splitToIndividualChat(actor);
        } else {
          _pushToIndividualChatPage(context, actor, avatar);
        }
      },
    );
  }
}
