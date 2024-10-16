import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/models/ChatRoomModel.dart';
import 'package:my_chat/models/UIhelper.dart';
import 'package:my_chat/models/firebasehelper.dart';
import 'package:my_chat/models/notification.dart';
import 'package:my_chat/models/usermodel.dart';
import 'package:my_chat/pages/ChatRoomPage.dart';
import 'package:my_chat/pages/LoginPage.dart';
import 'package:my_chat/pages/SearchPage.dart';

class Homepage extends StatefulWidget {

    final UserModel usermodel;
    final User firebaseUser;

  const Homepage({super.key, required this.usermodel, required this.firebaseUser});


  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Notificationservice service_noti=Notificationservice();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    service_noti.reqestNotificationPermision();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        actions: [
          IconButton(onPressed: () async{
            await FirebaseAuth.instance.signOut();
            Navigator.popUntil(context, (route) => route.isFirst,);
            Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => LoginPage(),));
          }, icon: Icon(Icons.exit_to_app,color: Colors.white,))
        ],
      automaticallyImplyLeading: false,
      backgroundColor: Color(0xFF006BFF),
      centerTitle: true,
      title: Text("Chat App",style: TextStyle(color: Colors.white),),
    ),
        body: SafeArea(child: Container(
          child: StreamBuilder(stream: FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.usermodel.uid}",isEqualTo: true).snapshots(), 
              builder:(context, snapshot) {
                if(snapshot.connectionState == ConnectionState.active){
                  if(snapshot.hasData){
                    QuerySnapshot chatroomsnapshot =snapshot.data as QuerySnapshot;
                    return ListView.builder(itemCount: chatroomsnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatroommodel =ChatRoomModel.fromMap(chatroomsnapshot.docs[index].data() as Map<String,dynamic>);
                      Map<String,dynamic> participant =chatroommodel.participants!;
                      List<String> participantkey =participant.keys.toList();
                      participantkey.remove(widget.usermodel.uid);
                      return FutureBuilder(future: firebasehelper.getusermodel(participantkey[0]), 
                          builder: (context, userdata) {
                         if(userdata.data != null){
                           if(userdata.connectionState ==ConnectionState.done){
                             UserModel targetuser =userdata.data as UserModel;
                             return Container(
                               color: Color(0xFFF4F6FF),
                               child: ListTile(

                                 onTap: (){
                                   Navigator.push(context,
                                   MaterialPageRoute(builder: (context) => Chatroompage(chatroom: chatroommodel,
                                       userModel: widget.usermodel,
                                       targetuser: targetuser,
                                       firebaseuser: widget.firebaseUser),));
                                 },
                                 leading: CircleAvatar(
                                   backgroundImage: NetworkImage(targetuser.profilepic.toString()),
                                 ),
                                 title: Text(targetuser.fullname.toString()),
                                 subtitle:(chatroommodel.lastmessage.toString() != "")? Text(chatroommodel.lastmessage.toString()) : Text("Say Hii To Your Friend",style: TextStyle(
                                   color: Theme.of(context).colorScheme.primary
                                 ),),
                               ),
                             );
                              }
                           else{
                             return Container();
                           }

                          }
                          else{
                            return Container();
                          }

                          }
                      );
                    }

                    );
                  }
                  else if (snapshot.hasError){
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  }
                  else{
                    return Center(child: Text("No Chat"),);
                  }
                }
                else{
                  return Center(child: CircularProgressIndicator(),);
                }
              },),
        )),
      floatingActionButton: FloatingActionButton(
        onPressed: (){

          Navigator.push(context, MaterialPageRoute(builder: (context) => Searchpage(userModel:widget.usermodel, firebaseUser: widget.firebaseUser),));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
