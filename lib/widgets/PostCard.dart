import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';


import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/user.dart' as model;
import '../providers/user_provider.dart';
import '../resources/firestore_methods.dart';
import '../screens/comments_screen.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import 'like_animation.dart';


class PostCard extends StatefulWidget {
  final snap;
  const PostCard({super.key, required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimation = false;
  int commentLen = 0;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snapshot.docs.length;
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {});
  }

  deletePost(String postId) {
    try {
      FireStoreMethods().deletePost(postId);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  _showDeletationConformation(String postId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Confirmation'),
            content: Text('Are you sure you want to delete this post?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('No'),
              ),
              TextButton(
                  onPressed: () async {
                    deletePost(postId);
                    Navigator.of(context).pop();
                  },
                  child: Text('Yes'))
            ],
          );
        });
  }

  void share(String postUrl, String description) {
    Share.share('Check out this post: $postUrl\n\n$description');
  }

  void bookmarkPost(String uid, String postId) async {
    await FireStoreMethods().bookmarkPost(uid: uid, postId: postId);
    Provider.of<UserProvider>(context, listen: false).refreshUser();
    showSnackBar(context, 'Bookmark updated!');
  }

  @override
  Widget build(BuildContext context) {
    final model.User? user = Provider.of<UserProvider>(context).getUser;
    final bool isBookmarked = user!.bookmarks.contains(widget.snap['postId']);

    return Container(
      color: mobileBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage:
                  NetworkImage(widget.snap['profileImage'].toString()),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.snap['username'].toString(),
                          style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                        )
                      ],
                    )),
                widget.snap['uid'].toString() == user.uid
                    ? PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'Delete') {
                        _showDeletationConformation(widget.snap['postId']);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(value: 'Delete', child: Text('Delete'))
                      ];
                    })
                    : Container(),
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: () {
              FireStoreMethods().likePost(
                uid: user.uid,
                postId: widget.snap['postId'].toString(),
                likes: widget.snap['likes'],
              );
              setState(() {
                isLikeAnimation = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: Image.network(
                    widget.snap['postUrl'].toString(),
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  opacity: isLikeAnimation ? 1 : 0,
                  duration: Duration(milliseconds: 200),
                  child: LikeAnimation(
                    isAnimating: isLikeAnimation,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 200,
                    ),
                    onEnd: () {
                      setState(() {
                        isLikeAnimation = false;
                      });
                    },
                  ),
                )
              ],
            ),
          ),
          Row(
            children: [
              LikeAnimation(
                  smallLike: true,
                  isAnimating: widget.snap['likes'].contains(user.uid),
                  child: IconButton(
                    onPressed: () {
                      FireStoreMethods().likePost(
                        uid: user.uid,
                        postId: widget.snap['postId'].toString(),
                        likes: widget.snap['likes'],
                      );
                    },
                    icon: widget.snap['likes'].contains(user.uid)
                        ? Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                        : Icon(
                      Icons.favorite_border,
                    ),
                  )),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommentScreen(
                              postId: widget.snap['postId'].toString())));
                },
                icon: Icon(Icons.comment_outlined),
              ),
              IconButton(
                onPressed: () {
                  share(widget.snap['postUrl'].toString(),
                      widget.snap['description'].toString());
                },
                icon: Icon(Icons.send),
              ),
              Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                        onPressed: () {
                          bookmarkPost(user.uid, widget.snap['postId']);
                        },
                        icon: isBookmarked
                            ? Icon(CupertinoIcons.bookmark_fill)
                            : Icon(CupertinoIcons.bookmark)),
                  )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.snap['likes'].length} likes',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.snap['username'].toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                     Expanded(
                       child: Text(widget.snap['description'].toString(),
                       style: TextStyle(
                         overflow: TextOverflow.ellipsis
                       ),
                       ),
                     ),
                  ],
                ),
                Text(
                  'View all $commentLen comments',
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  DateFormat.yMMMd().format(
                    widget.snap['datePublished'].toDate(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
