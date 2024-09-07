import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/screens/profile_screen.dart';

import '../utils/colors.dart';
import 'feed_screen.dart';

class SearchScreen extends StatefulWidget {
  final String uid;
  const SearchScreen({super.key, required this.uid});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUser = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Form(
          child: TextFormField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search for a user',
            ),
            onFieldSubmitted: (_) {
              setState(() {
                isShowUser = true;
              });
            },
          ),
        ),
      ),
      body: isShowUser
          ? FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .where(
          'username',
          isGreaterThanOrEqualTo: searchController.text,
        )
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: (snapshot.data! as dynamic).docs.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        uid: (snapshot.data! as dynamic).docs[index]['uid'],
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      (snapshot.data! as dynamic).docs[index]['photoUrl'],
                    ),
                    radius: 16,
                  ),
                  title: Text(
                    (snapshot.data! as dynamic).docs[index]['username'],
                  ),
                ),
              );
            },
          );
        },
      )
          : FutureBuilder(
        future:FirebaseFirestore.instance
            .collection('posts')
            .orderBy('datePublished')
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return MasonryGridView.count(
            crossAxisCount: 3,
            itemCount: (snapshot.data! as dynamic).docs.length,
            itemBuilder: (ctx, index) {
              String postUrl = (snapshot.data! as dynamic).docs[index]['postUrl'];
              String postId = (snapshot.data! as dynamic).docs[index]['postId'];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedScreen(
                        uid: widget.uid,
                        postUrl: postUrl,
                        postId: postId,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  postUrl,
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
