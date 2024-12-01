/*
          This class handles all the data from and to firebase.
---------------------------------------------------------------------------

  - User Profile
  - Post messages
  - Likes
  - Comments
  - Account stuff (report, block, delete account)
  - Follow / unfollow
  - Search users
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitmania/models/comment.dart';
import 'package:twitmania/models/post.dart';
import 'package:twitmania/models/user.dart';
import 'package:twitmania/services/auth/auth_service.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // save user info
  Future<void> saveUserInfoInFirebase(
      {required String name, required String email}) async {
    // get current user uid
    String uid = _auth.currentUser!.uid;

    // extract username from email
    String username = email.split('@')[0];

    // create a user profile
    UserProfile user = UserProfile(
      uid: uid,
      name: name,
      email: email,
      username: username,
      bio: '',
    );

    // convert user to map
    final userMap = user.toMap();

    // save info in firebase
    await _db.collection('Users').doc(uid).set(userMap);
  }

  // get user info
  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('Users').doc(uid).get();
      return UserProfile.fromDocument(userDoc);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // update the user bio
  Future<void> updateUserBioInFirebase(String bio) async {
    // get current user id
    String uid = AuthService().getCurrentUserId();

    //  attempt to update in firebase
    try {
      await _db.collection('Users').doc(uid).update({'bio': bio});
    } catch (e) {
      print(e.toString());
    }
  }

  // delete user info
  Future<void> deleteUserInfoFromFirebase(String uid) async {
    WriteBatch batch = _db.batch();

    // delete user doc
    DocumentReference userDoc = _db.collection('Users').doc(uid);
    batch.delete(userDoc);

    // delete user posts
    QuerySnapshot userPosts =
        await _db.collection('Posts').where('uid', isEqualTo: uid).get();
    for (var post in userPosts.docs) {
      batch.delete(post.reference);
    }

    // delete likes done by this user
    QuerySnapshot allPosts = await _db.collection('Posts').get();
    for (QueryDocumentSnapshot post in allPosts.docs) {
      Map<String, dynamic> postData = post.data() as Map<String, dynamic>;

      var likedBy = postData['likedBy'] as List<dynamic>? ?? [];

      if (likedBy.contains(uid)) {
        batch.update(post.reference, {
          'likedBy': FieldValue.arrayRemove([uid]),
          'likes': FieldValue.increment(-1),
        });
      }
    }

    // delete user comments
    QuerySnapshot userComments =
        await _db.collection('Comments').where('uid', isEqualTo: uid).get();
    for (var comment in userComments.docs) {
      batch.delete(comment.reference);
    }

    // update follower & following recods accordingly..

    // commit batch
    await batch.commit();
  }

/*
    POST MESSAGE
*/

  // post a message
  Future<void> postMessageInFirebase(String message) async {
    try {
      // get current use id
      String uid = _auth.currentUser!.uid;

      // use this id to get the user's profile
      UserProfile? user = await getUserFromFirebase(uid);

      // create a new post
      Post newPost = Post(
          id: '',
          uid: uid,
          name: user!.name,
          username: user!.username,
          message: message,
          timestamp: Timestamp.now(),
          likeCount: 0,
          likedBy: []);

      // convert post object -> map
      Map<String, dynamic> newPostMap = newPost.toMap();

      // add to firebase
      await _db.collection('Posts').add(newPostMap);
    } catch (e) {
      print(e);
    }
  }
  // delete a message

  // get all posts from Firebase
  Future<List<Post>> getAllPostFromFirebase() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('Posts')
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // delete a post
  Future<void> deletePostFormFirebase(String postId) async {
    try {
      await _db.collection('Posts').doc(postId).delete();
    } catch (e) {
      print(e);
    }
  }

  // get individual posts

/*
    LIKES
*/
  // like a post
  Future<void> toggleLikeInFirebase(String postId) async {
    try {
      //  get current uid
      String uid = _auth.currentUser!.uid;

      // go to doc for this post
      DocumentReference postDoc = _db.collection('Posts').doc(postId);

      // execute like
      await _db.runTransaction(
        (transaction) async {
          // get post data
          DocumentSnapshot postSnapshot = await transaction.get(postDoc);

          // get like count
          List<String> likedBy =
              List<String>.from(postSnapshot['likedBy'] ?? []);

          // get like count
          int currentLikeCount = postSnapshot['likes'];

          // if user has not liked post yet -> like
          if (!likedBy.contains(uid)) {
            // add user to the like list
            likedBy.add(uid);

            // increment like count
            currentLikeCount++;
          }
          // if user has already liked this post -> then unlike
          else {
            // remove user from like list
            likedBy.remove(uid);

            // decrement like count
            currentLikeCount--;
          }
          transaction.update(postDoc, {
            'likes': currentLikeCount,
            'likedBy': likedBy,
          });
        },
      );
    } catch (e) {
      print(e);
    }
  }

/*
  COMMENTS
*/

  // Add a comment to a post
  Future<void> addCommentInFirebase(String postId, message) async {
    try {
      // get current user
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);

      // create a new comment
      Comment newComment = Comment(
        id: '',
        postId: postId,
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
      );

      Map<String, dynamic> newCommentMap = newComment.toMap();

      await _db.collection('Comments').add(newCommentMap);
    } catch (e) {
      print(e);
    }
  }

  // Delete a comment from a post
  Future<void> deleteCommentInFirebase(String commentId) async {
    try {
      await _db.collection('Comments').doc(commentId);
    } catch (e) {
      print(e);
    }
  }

  // Fetch comment from a post
  Future<List<Comment>> getCommentsFromFirebase(String postId) async {
    try {
      // get comments from firebase
      QuerySnapshot snapshot = await _db
          .collection('Comments')
          .where('postId', isEqualTo: postId)
          .get();
      return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

/*
  ACCOUNT STUFF

  These are requirement if you wish to publish this to the app store:
*/

  // Report post
  Future<void> reportUserInFirebase(String postId, userId) async {
    // get current user id
    final currentUserId = _auth.currentUser!.uid;

    // create a report map
    final report = {
      'reportedBy': currentUserId,
      'messageId': postId,
      'messageOwnerId': userId,
      'timestamp': Timestamp.now(),
    };

    // update in firestore
    await _db.collection('Reports').add(report);
  }

  // Block user
  Future<void> blockUserInFirebase(String userId) async {
    // get current user id
    final currentUserId = _auth.currentUser!.uid;

    // add this user to the blocked list
    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUser')
        .doc(userId)
        .set(
      {},
    );
  }

  // Unblock user
  Future<void> unblockUserInFirebase(String blockedUserId) async {
    // get current user id
    final currentUserId = _auth.currentUser!.uid;

    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUser')
        .doc(blockedUserId)
        .delete();
  }

  // get list of blocked user ids
  Future<List<String>> getBlockedUidsFromFirebase() async {
    // get current user id
    final currentUserId = _auth.currentUser!.uid;

    // get data of blocked users
    final snapshot = await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUsers')
        .get();

    return snapshot.docs
        .map(
          (doc) => doc.id.toString(),
        )
        .toList();
  }

  /*
  FOLLOW
  */

  // Follow user
  Future<void> followUserInFirebase(String uid) async {
    // get current logged in user
    final currentUserId = _auth.currentUser!.uid;

    // add target user to the current user's following
    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('Following')
        .doc(uid)
        .set({});

    // add current user to the target user's followers
    await _db
        .collection('Users')
        .doc(uid)
        .collection('Followers')
        .doc(currentUserId)
        .set({});
  }

  // unfollow user
  Future<void> unFollowUserInFirebase(String uid) async {
    // get current logged in user
    final currentUserId = _auth.currentUser!.uid;

    // remove target user form current users following
    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('Following')
        .doc(uid)
        .delete();

    // remove current user from target user's followers
    await _db
        .collection('Users')
        .doc(uid)
        .collection('Followers')
        .doc(currentUserId)
        .delete();
  }

  // get a user's following list of uid's
  Future<List<String>> getFollowerUidsFromFirebase(String uid) async {
    // get followers from firebase
    final snapshot =
        await _db.collection('Users').doc(uid).collection('Followers').get();

    // return as a nice simple list uids
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // get a user's followers list of uid's
  Future<List<String>> getFollowingUidsFromFirebase(String uid) async {
    // get following from firebase
    final snapshot =
        await _db.collection('Users').doc(uid).collection('Following').get();

    // return as a nice simple list uids
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /*
   SEARCH

  */

  // Search for user by name
  Future<List<UserProfile>> searchUsersInFirebase(String searchTerm) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('Users')
          .where('username', isGreaterThanOrEqualTo: searchTerm)
          .where('username', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .get();

      return snapshot.docs
          .map(
            (doc) => UserProfile.fromDocument(doc),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }
}
