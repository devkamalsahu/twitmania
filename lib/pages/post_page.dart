/*

  POST PAGE

  This page displays:

  - individual post 
  - comments on this post

*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitmania/components/my_comment_tile.dart';
import 'package:twitmania/components/my_post_tile.dart';
import 'package:twitmania/helper/navigate_pages.dart';
import 'package:twitmania/models/post.dart';
import 'package:twitmania/services/database/database_provider.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.post});
  final Post post;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  // provider
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    // listen to all comments for this post
    final allComments = listeningProvider.getComments(widget.post.id);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        children: [
          MyPostTile(
            post: widget.post,
            onUserTap: () => goUserPage(context, widget.post.uid),
            onPostTap: () {},
          ),

          // Comments on this post
          allComments.isEmpty
              ? const Center(
                  child: Text('No comments yet...'),
                )
              : ListView.builder(
                  itemCount: allComments.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    // get each comment
                    final comment = allComments[index];

                    return MyCommentTile(
                      comment: comment,
                      onUserTap: () => goUserPage(
                        context,
                        comment.uid,
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
