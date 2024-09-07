import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/colors.dart';
import '../widgets/PostCard.dart';


class FeedScreen extends StatefulWidget {
  final String uid;
  final String? postUrl;
  final String? postId;

  const FeedScreen({super.key, required this.uid, this.postUrl, this.postId});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {

  int? selectedPostIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: SvgPicture.asset('assets/ic_instagram.svg', color: primaryColor, height: 32),
        actions: [Icon(Icons.messenger_outline)],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts available.'));
          }

          // List of posts for the current user
          var posts = snapshot.data!.docs;

          // Find the index of the postId in the list of posts
          selectedPostIndex = posts.indexWhere((doc) => doc['postId'] == widget.postId);

          // If postId is not found, default to the first post
          if (selectedPostIndex == -1) selectedPostIndex = null;

          // Scroll to the selected post when the screen loads or when it is selected
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (selectedPostIndex != null && selectedPostIndex! < posts.length) {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent
                  * (selectedPostIndex! / posts.length));
            }
          });

          return ListView.builder(
            controller: _scrollController,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index].data() as Map<String, dynamic>;

              // Highlight the selected post
              bool isSelected = index == selectedPostIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPostIndex = index;
                  });
                  // Automatically scroll to the selected post
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent * (index / posts.length),
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: isSelected ? Border.all(color: Colors.blue, width: 2.0) : null,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: PostCard(
                    snap: post,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
