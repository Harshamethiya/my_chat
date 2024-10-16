import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/models/ChatRoomModel.dart';
import 'package:my_chat/models/messagemodel.dart';
import 'package:my_chat/models/usermodel.dart';

class Chatroompage extends StatefulWidget {
    final UserModel targetuser;
    final ChatRoomModel chatroom;
    final UserModel userModel;
    final User firebaseuser;

  const Chatroompage({super.key, required this.chatroom, required this.userModel, required this.targetuser, required this.firebaseuser});

  @override
  State<Chatroompage> createState() => _ChatroompageState();
}


class _ChatroompageState extends State<Chatroompage> {
  TextEditingController messageController =TextEditingController();


  void sendmessage()async{
    String msg=messageController.text.trim();
    //when user click send button then textfield clear
    messageController.clear();
    if(msg != null){
      //send message
     Messagemodel newMessage =Messagemodel(
       messageid: uuid.v1(),
       sender: widget.userModel.uid,
       createdon: DateTime.now(),
       seen: false,
       text: msg
     );
     //there we dont used await because we cant wait user .if user offline then
     // firebase save data to local storage when user  come online then it store data cloud
     //listen await used for wait user while data not come
     FirebaseFirestore.instance.collection('chatrooms').
     doc(widget.chatroom.chatroomid).collection('messages').
     doc(newMessage.messageid).set(newMessage.toMap());
     widget.chatroom.lastmessage =msg;
     FirebaseFirestore.instance.collection('chatrooms').
     doc(widget.chatroom.chatroomid).set(widget.chatroom.toMap());
     print('message send');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       
        backgroundColor:Color(0xFF006BFF),
        centerTitle: true,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(widget.targetuser.profilepic.toString()),
            ),
            SizedBox(width: 10,),
            Text(widget.targetuser.fullname.toString(),style: TextStyle(color: Colors.white),)
          ],
        )
      ),
      body: SafeArea(child: Container(
        child: Column(
          children: [
            Expanded(child: Container(
              padding:  EdgeInsets.symmetric(
                horizontal: 10
              ),
              child: StreamBuilder(stream: FirebaseFirestore.instance.collection("chatrooms").
              doc(widget.chatroom.chatroomid).collection("messages").orderBy("createdon",descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if(snapshot.connectionState== ConnectionState.active)
                      {
                        if(snapshot.hasData){
                          //we convert snapshot to querysnapshot for fatch documents
                          QuerySnapshot datasnapshot= snapshot.data as QuerySnapshot;
                          return ListView.builder(
                            reverse: true,
                            itemCount: datasnapshot.docs.length,
                            itemBuilder: (context, index) {
                              Messagemodel currentMessage= Messagemodel.fromMap(datasnapshot.docs[index].data() as Map<String,dynamic>);
                              return Row(
                                mainAxisAlignment: (currentMessage.sender == widget.userModel.uid) ? MainAxisAlignment.end :MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                      vertical: 2
                                    ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10
                                      ),
                                      decoration: BoxDecoration(

                                          borderRadius:(currentMessage.sender == widget.userModel.uid) ?BorderRadius.only(topLeft: Radius.circular(10),
                                          topRight:  Radius.circular(10),
                                            bottomLeft:  Radius.circular(10)
                                          ) : BorderRadius.only(topLeft: Radius.circular(10),
                              topRight:  Radius.circular(10),
                              bottomRight:  Radius.circular(10)
                              ),
                              color: (currentMessage.sender == widget.userModel.uid) ?Color(0xFF0D92F4): Color(0xFF77CDFF)
                                      ),
                                      child: Text(currentMessage.text.toString(),style: TextStyle(color: Colors.white),)),
                                ],
                              );
                            },
                          );
                        }
                        else if(snapshot.hasError){
                          return Center(
                            child: Text("An error occur plaese check your internet connection"),
                          );
                        }
                        else{
                          return Center(
                            child: Text("Say hii to your new friend"),
                          );
                        }
                      }
                    else{
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },),
            )),
            Container(
                color: Color(0xFFE4E0E1),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5
                ),
                child: Row(
                  children: [
                    Flexible(
                        child:
                        TextField(
                        controller:messageController,
                      maxLines: null,
                      decoration: InputDecoration(

                        border: InputBorder.none,
                        hintText: "Enter the message"
                      ),
                    )),
                    IconButton(onPressed: (){
                      sendmessage();

                    }, icon: Icon(Icons.send))
                  ],
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
