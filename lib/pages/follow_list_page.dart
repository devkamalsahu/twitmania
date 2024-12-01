/*
  FOLLOW LIST PAGE

  This page display a tab bar for ( a given uid ): 

  - a list of all followers
  - a list of all following

*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitmania/components/my_user_tile.dart';
import 'package:twitmania/services/database/database_provider.dart';

import '../models/user.dart';

class FollowListPage extends StatefulWidget {
  const FollowListPage({super.key, required this.uid});
  final String uid;

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  // providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  void initState() {
    // load follower list
    loadFollowerList();

    // load following list
    loadFollowingList();
    super.initState();
  }

  // load followers
  Future<void> loadFollowerList() async {
    await databaseProvider.loadUserFollowerProfiles(widget.uid);
  }

  // load following
  Future<void> loadFollowingList() async {
    await databaseProvider.loadUserFollowingProfiles(widget.uid);
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // listen to followers & following
    final followers = listeningProvider.getListOfFollowersProfile(widget.uid);
    final following = listeningProvider.getListOfFollowingProfile(widget.uid);

    // TAB CONTROLLER
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          foregroundColor: Theme.of(context).colorScheme.primary,
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            tabs: const [
              Text('Followers'),
              Text('Following'),
            ],
          ),
        ),
        // Tab Bar View
        body: TabBarView(
          children: [
            _buildUserList(followers, 'No followers..'),
            _buildUserList(following, 'No following..')
          ],
        ),
      ),
    );
  }
}

//  build user list, given a list of profiles
Widget _buildUserList(List<UserProfile> userList, String emptyMessage) {
  return userList.isEmpty
      ?
      // empty message if there are no user
      Center(
          child: Text(emptyMessage),
        )
      :
      // user list
      ListView.builder(
          itemCount: userList.length,
          itemBuilder: (context, index) {
            // get each user
            final user = userList[index];

            // return as a user list tile
            return MyUserTile(user: user);
          },
        );
}
