import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';
import '../resources/comment_method.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/comment_card.dart';



class CommentScreen extends StatefulWidget {
  final String postId;
  const CommentScreen({super.key,required this.postId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {

  final TextEditingController commentController = TextEditingController();

  postComment(String uid,String name,String profilePic) async{
    try{
      String res = await CommentMethods().postComment(
          postId: widget.postId,
          uid: uid,
          text: commentController.text,
          name: name,
          profilePic: profilePic
      );
      if(res != 'success'){
        if(context.mounted){
          showSnackBar(context, res);
        }

      }
      setState(() {
        commentController.text = '';
      });
    }
    catch(e){
      showSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {

    final User? user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('comments'),
        backgroundColor: mobileBackgroundColor,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('posts').doc(widget.postId)
              .collection('comments').snapshots(),
          builder: (context,AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
            // if(snapshot.connectionState == ConnectionState.waiting){
            //   return Center(child: CircularProgressIndicator(),);
            // }
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (ctx,index){
                  return CommentCard(
                    snap: snapshot.data!.docs[index],
                  );
                }
            );
          }
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kTextTabBarHeight,
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,),
          padding: EdgeInsets.only(left: 16,right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user!.photoUrl),
                radius: 18,
              ),
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0,right: 8),
                    child: TextFormField(
                      controller: commentController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Comment as ${user.username}',
                      ),
                    ),
                  )
              ),
              TextButton(
                  onPressed: (){
                    postComment(user.uid, user.username, user.photoUrl);
                  },
                  child: Text('Post')
              )
            ],
          ),
        ),
      ),
    );
  }
}
