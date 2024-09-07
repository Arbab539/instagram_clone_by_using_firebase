import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String username;
  final String photoUrl;
  final String email;
  final String bio;
  final List following;
  final List followers;
  final List bookmarks; // Added bookmarks field

  User({
    required this.uid,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.bio,
    required this.following,
    required this.followers,
    required this.bookmarks, // Added bookmarks field
  });

  static User fromSnap(DocumentSnapshot documentSnapshot) {
    var snapshot = documentSnapshot.data() as Map<String, dynamic>?;

    if (snapshot == null) {
      throw Exception('User data is null');
    }

    return User(
      uid: snapshot['uid'],
      username: snapshot['username'],
      email: snapshot['email'],
      photoUrl: snapshot['photoUrl'],
      bio: snapshot['bio'],
      following: snapshot['following'],
      followers: snapshot['followers'],
      bookmarks: snapshot['bookmarks'] ?? [], // Added bookmarks field
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'username': username,
    'email': email,
    'photoUrl': photoUrl,
    'bio': bio,
    'following': following,
    'followers': followers,
    'bookmarks': bookmarks, // Added bookmarks field
  };
}
