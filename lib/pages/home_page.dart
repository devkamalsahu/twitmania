import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/components/my_drawer.dart';
import '/components/my_input_alert_box.dart';
import '/components/my_post_tile.dart';
import '/helper/navigate_pages.dart';

import '../models/post.dart';
import '../services/database/database_provider.dart';

/*
    HOME PAGE

  This is the main page of this app: It displys a list of all posts.  

  -------------------------------------------------------------------------------------------------------

  We can organise this page using a tab bar to split into:

  - for you page
  - following page


*/

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _messageController = TextEditingController();

  // providers
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  late final listeningProvider = Provider.of<DatabaseProvider>(context);

  @override
  void initState() {
    super.initState();

    loadAllPosts();
  }

  // fetch all posts
  Future<void> loadAllPosts() async {
    await databaseProvider.loadAllPosts();
  }

  // show post message dialog box
  void _onPostMessageBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
          textController: _messageController,
          hintText: "What's on your mind?",
          onPressed: () async {
            await postMessage(_messageController.text);
          },
          onPressedText: 'Post'),
    );
  }

  // user wants to post a message
  Future<void> postMessage(String message) async {
    // post a message in firebase
    await databaseProvider.postMessage(message);

    // reload data from firebase
    await loadAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    // TAB CONTROLLER: 2 options -> for you / following
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        drawer: MyDrawer(),
        appBar: AppBar(
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            tabs: const [
              Text('For you'),
              Text('Following'),
            ],
          ),
          title: const Text('H O M E'),
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: TabBarView(
          children: [
            _buildPostList(listeningProvider.allPosts),
            _buildPostList(listeningProvider.followingPosts),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _onPostMessageBox,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
        ? const Center(
            child: Text('Nothing here..'),
          )
        : ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return MyPostTile(
                post: post,
                onUserTap: () => goUserPage(context, post.uid),
                onPostTap: () => goPostPage(context, post),
              );
            },
          );
  }
}
