import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:twitmania/components/my_bio_box.dart';
import 'package:twitmania/components/my_follow_button.dart';
import 'package:twitmania/components/my_input_alert_box.dart';
import 'package:twitmania/components/my_post_tile.dart';
import 'package:twitmania/components/my_profile_stats.dart';
import 'package:twitmania/models/user.dart';
import 'package:twitmania/pages/follow_list_page.dart';
import 'package:twitmania/services/auth/auth_service.dart';

import '../helper/navigate_pages.dart';
import '../services/database/database_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.uid});
  final String uid;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);

  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  final bioTextController = TextEditingController();

  bool _isLoading = true;

  UserProfile? user;

  String currentUserId = AuthService().getCurrentUserId();

  // isFollowing stat
  bool _isFollowing = false;

  // show edit bio box
  void _showEditBioBox() {
    showDialog(
        context: context,
        builder: (ctx) => MyInputAlertBox(
              textController: bioTextController,
              hintText: 'Edit bio',
              onPressed: saveBio,
              onPressedText: 'Save',
            ));
  }

  // save updated bio
  Future<void> saveBio() async {
    // start loading
    setState(() {
      _isLoading = true;
    });

    // update the bio
    await databaseProvider.updateBio(bioTextController.text);
    await loadUser();
    // done loading
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    // let's load user info
    loadUser();
  }

  Future<void> loadUser() async {
    // get the user profile info
    user = await databaseProvider.userProfile(widget.uid);

    // load followers & following for this user
    await databaseProvider.loadUserFollowers(widget.uid);
    await databaseProvider.loadUserFollowing(widget.uid);

    // update following state
    _isFollowing = databaseProvider.isFollowing(widget.uid);

    // finished loading..
    setState(() {
      _isLoading = false;
    });
  }

  // toggle follow -> follow / unfollow
  Future<void> toggleFollow() async {
    // unfollow
    if (_isFollowing) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unfollow'),
          content: const Text('Are you sure you want to unfollow'),
          actions: [
            // cancle
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            // yes
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                //  perform unfollow
                await databaseProvider.unFollowUser(widget.uid);
              },
              child: Text('Yes'),
            )
          ],
        ),
      );
    }
    // follow
    else {
      await databaseProvider.followUser(widget.uid);
    }

    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    // get user posts
    final allUserPosts = listeningProvider.filterUserPosts(widget.uid);

    // listen to followers & following count
    final followerCount = listeningProvider.getFollowerCount(widget.uid);

    // listen to following count
    final followingCount = listeningProvider.getFollowingCount(widget.uid);

    // listen to isFollowing status
    _isFollowing = listeningProvider.isFollowing(widget.uid);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => goHomePage(context),
        ),
        title: Text(_isLoading ? '' : user!.name),
      ),
      body: ListView(
        children: [
          // username handle
          Center(
            child: Text(
              _isLoading ? '' : '@${user!.name}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(
            height: 25,
          ),
          // profile stats -> number of posts / followers / following
          MyProfileStats(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FollowListPage(
                    uid: widget.uid,
                  ),
                )),
            postCount: allUserPosts.length,
            followerCount: followerCount,
            followingCount: followingCount,
          ),
          const SizedBox(height: 25),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.all(25),
            child: Icon(
              Icons.person,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          // profile stats -> number of posts / followers / following

          // follow / unfollow button
          // only show if the user is viewing someone else's  profile
          if (user != null && user!.uid != currentUserId)
            MyFollowButton(
              onPressed: toggleFollow,
              isFollowing: _isFollowing,
            ),
          // edit bio
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bio',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                // only show edit button if it's current user page
                if (user != null && user!.uid == currentUserId)
                  GestureDetector(
                    onTap: _showEditBioBox,
                    child: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(width: 10),

          // bio box
          MyBioBox(text: _isLoading ? '...' : user!.bio),

          Padding(
            padding: const EdgeInsets.only(left: 25, top: 25),
            child: Text(
              'Posts',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          // list of posts from user
          allUserPosts.isEmpty
              ? const Center(
                  child: Text('No post yet..'),
                )
              : SizedBox(
                  height: 400,
                  child: ListView.builder(
                    itemCount: allUserPosts.length,
                    // physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      // get individual post
                      final post = allUserPosts[index];

                      return MyPostTile(
                        post: post,
                        onPostTap: () => goPostPage(context, post),
                        onUserTap: () {},
                      );
                    },
                  ),
                )
        ],
      ),
    );
  }
}
