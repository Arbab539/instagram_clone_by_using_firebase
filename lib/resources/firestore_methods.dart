
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/resources/storage_methods.dart';

import 'package:uuid/uuid.dart';

import '../models/post.dart';

class FireStoreMethods{

  Future<String> uploadPost({
    required String description,
    required String username,
    required String uid,
    required String profileImage,
    required Uint8List file,
  })async{
    String res = 'Some error occur';
    try{
      String postUrl = await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = Uuid().v1();
      Post post = Post(
        uid: uid,
        username: username,
        profileImage: profileImage,
        postId: postId,
        postUrl: postUrl,
        description: description,
        likes: [],
        datePublished: DateTime.now(),
      );
      await FirebaseFirestore.instance.collection('posts').doc(postId).set(post.toMap());
      res = 'success';
    }
    catch(e){
      res = e.toString();
    }
    return res;
  }

  Future<String> deletePost(String postId) async{
    String res = 'Some error occur';
    try{
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      res = 'success';
    }
    catch(e){
      res = e.toString();
    }
    return res;
  }

  Future<String> likePost({
    required String uid,
    required String postId,
    required List likes
  })async{
    String res = 'Some error occur';
    try{
      if(likes.contains(uid)){
        FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      }
      else{
        FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    }
    catch(e){
      res = e.toString();
    }
    return res;
  }

  Future<void> followUser(String uid,String followId) async{

    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    List following = (snapshot.data()! as dynamic)['following'];

    if(following.contains(followId)){
      await FirebaseFirestore.instance.collection('users').doc(followId).update({
        'followers':FieldValue.arrayRemove([uid]),
      });
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'following': FieldValue.arrayRemove([followId]),
      });
    }
    else{
      await FirebaseFirestore.instance.collection('users').doc(followId).update({
        'followers': FieldValue.arrayUnion([uid]),
      });
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'following': FieldValue.arrayUnion([followId]),
      });
    }
  }

  Future<String> bookmarkPost({required String uid, required String postId}) async {
    String res = 'Some error occur';
    try {
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      DocumentSnapshot userSnapshot = await userRef.get();
      List<dynamic> bookmarks = userSnapshot['bookmarks'] ?? [];

      if (bookmarks.contains(postId)) {
        bookmarks.remove(postId);
      } else {
        bookmarks.add(postId);
      }

      await userRef.update({'bookmarks': bookmarks});
      res = 'success';
    } catch (e) {
      throw e.toString();
    }
    return res;
  }

}