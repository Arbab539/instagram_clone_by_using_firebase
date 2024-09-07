
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CommentMethods{

  Future<String> postComment({
    required String postId,
    required String uid,
    required String text,
    required String name,
    required String profilePic,
  })async{
    String res = 'Some error occur';
    try{
      if(text.isNotEmpty){
        String commentId = Uuid().v1();
        FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic':profilePic,
          'name':name,
          'uid':uid,
          'text':text,
          'commentId':commentId,
          'datePublished':DateTime.now(),
        });
        res = 'success';
      }
      else{
        res = 'Please enter text';
      }
    }
    catch(e){
      res = e.toString();
    }
    return res;
  }
  Future<String> deleteComment(String postId,String commentId) async{
    String res = 'Some error occur';
    try{
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
      res = 'success';
    }
    catch(e){
      res = e.toString();
    }
    return res;
  }
  Future<String> editComment(String postId,String commentId,String newText) async{
    String res = 'Some error occur';
    try{
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update(
          {
            'text':newText
          });
      res = 'success';
    }
    catch(e){
      res = e.toString();
    }
    return res;
  }

}