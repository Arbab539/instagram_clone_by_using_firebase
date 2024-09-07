import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/screens/user_post.dart';

import '../resources/auth_methods.dart';
import '../resources/firestore_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/follow_button.dart';


class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key,required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async{
    setState(() {
      isLoading = true;
    });
    try{
      var userSnap = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      var postSnap = await FirebaseFirestore.instance.collection('posts')
          .where('uid',isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();

      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap.data()!['followers'].contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {

      });

    }
    catch(e){
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ?
    Center(
      child: CircularProgressIndicator(),
    )
        :
    Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(userData['username'],),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(userData['photoUrl']),
                      radius: 40,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildStatColumn(postLen, 'Posts'),
                              buildStatColumn(followers, 'Followers'),
                              buildStatColumn(following, 'Following'),
                            ],
                          ),
                          FirebaseAuth.instance.currentUser!.uid == widget.uid
                              ?
                          FollowButton(
                              text: 'Sign Out',
                              function: (){
                                AuthMethods().signOut();
                                if(context.mounted){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                                }
                              },
                              backgroundColor: mobileBackgroundColor,
                              borderColor: Colors.grey,
                              textColor: primaryColor
                          )
                              :isFollowing
                              ?
                          FollowButton(
                              text: 'unfollow',
                              function: (){
                                FireStoreMethods().followUser(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  userData['uid'],
                                );
                                setState(() {
                                  isFollowing = false;
                                  followers--;
                                });
                              },
                              backgroundColor: primaryColor,
                              borderColor: primaryColor,
                              textColor: Colors.black
                          )
                              :FollowButton(
                              text: 'Follow',
                              function: (){
                                FireStoreMethods().followUser(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  userData['uid'],
                                );
                                setState(() {
                                  isFollowing = true;
                                  followers++;
                                });
                              },
                              backgroundColor: blueColor,
                              borderColor: blueColor,
                              textColor: Colors.white
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData['username'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          userData['bio'],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Divider(),
          FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('posts').where('uid',isEqualTo: widget.uid).get(),
              builder: (context,snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 1.5,
                    childAspectRatio: 1,
                  ),
                  itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                  itemBuilder: (context, index) {
                    String postId = (snapshot.data! as dynamic).docs[index]['postId'];
                    String postUrl = (snapshot.data! as dynamic).docs[index]['postUrl'];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserPostScreen(
                              postId: postId, // Pass the initially clicked post index
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        child: Image.network(
                          postUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );

              }
          ),
        ],
      ),
    );
  }

  Widget buildStatColumn(int num,String label){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),


      ],
    );
  }

}
