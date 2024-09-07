import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../resources/comment_method.dart';
import '../utils/utils.dart';


class CommentCard extends StatefulWidget {
  final DocumentSnapshot snap;
  const CommentCard({super.key,required this.snap});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {

  final TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    editingController.text = widget.snap['text'];
  }

  deletePost(String postId,String commentId) async{
    try{
      String res = await CommentMethods().deleteComment(postId, commentId);
      if(res == 'success'){
        showSnackBar(context, 'Comment Deleted Successfully');
      }
      else{
        showSnackBar(context, res);
      }
    }
    catch(e){
      showSnackBar(context, e.toString());
    }
  }
  editPost(String postId,String commentId) async{
    try{
      String res = await CommentMethods().editComment(postId, commentId, editingController.text);
      if(res == 'success'){
        showSnackBar(context, res);
      }
      else{
        showSnackBar(context, res);
      }
    }
    catch(e){
      showSnackBar(context, e.toString());
    }
  }

  _showDeleteDialog(String postId,String commentId){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Delete Confirmation'),
            content: Text('Are you sure you want to delete this comment?'),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')
              ),
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                    deletePost(postId, commentId);
                  },
                  child: Text('Yes')
              )
            ],
          );
        }
    );
  }
  _showEditDialog(String postId,String commentId){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Edit Comment'),
            content: TextFormField(
              controller: editingController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Edit your comment'
              ),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('No')
              ),
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                  editPost(postId, commentId);
                },
                child: Text('Yes'),
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {

    String postId = widget.snap.reference.parent.parent!.id;
    String commentId = widget.snap.id;

    return Container(
      margin: EdgeInsets.only(left: 10,right: 10,top: 10),
      child: Material(
        elevation: 3,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.snap['profilePic']),
                radius: 18,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(widget.snap['name'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text('${widget.snap['text']}'),
                      ],
                    ),
                    Text(DateFormat.yMMMd().format(widget.snap['datePublished'].toDate()),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400
                      ),
                    )
                  ],
                ),
              ),
              PopupMenuButton(
                  onSelected: (value){
                    if(value == 'Edit'){
                      _showEditDialog(postId, commentId);
                    }
                    else if(value == 'Delete'){
                      _showDeleteDialog(postId, commentId);
                    }
                  },
                  itemBuilder: (BuildContext context){
                    return [
                      PopupMenuItem(
                        value: 'Edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                          value: 'Delete',
                          child: Text('Delete')
                      )
                    ];
                  }
              )
            ],
          ),
        ),
      ),
    );
  }
}
