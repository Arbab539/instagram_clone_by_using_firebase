
import 'package:cloud_firestore/cloud_firestore.dart';

class Post{
  final String description;
  final String uid;
  final String username;
  final  likes;
  final String postId;
  final String postUrl;
  final String profileImage;
  final DateTime datePublished;

  Post({
    required this.description,
    required this.uid,
    required this.likes,
    required this.username,
    required this.postId,
    required this.postUrl,
    required this.profileImage,
    required this.datePublished,
  });

  static Post fromSnap(DocumentSnapshot snapshot){
    var snapshots = snapshot.data() as Map<String,dynamic>?;
    return Post(
      description: snapshots!['description'],
      uid: snapshots['uid'],
      likes: snapshots['likes'],
      username: snapshots['username'],
      postId: snapshots['postId'],
      postUrl: snapshots['postUrl'],
      profileImage: snapshots['profileImage'],
      datePublished: snapshots['datePublished'],
    );

  }

  Map<String,dynamic> toMap()=>{
    'description': description,
    'uid': uid,
    'likes': likes,
    'username': username,
    'postId': postId,
    'postUrl': postUrl,
    'profileImage': profileImage,
    'datePublished': datePublished
  };

}