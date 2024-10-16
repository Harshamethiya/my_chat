
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/models/ChatRoomModel.dart';
import 'package:my_chat/models/usermodel.dart';
import 'package:my_chat/pages/ChatRoomPage.dart';

class Searchpage extends StatefulWidget {
 final UserModel userModel;
 final User firebaseUser;

  const Searchpage({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  TextEditingController searchController=TextEditingController();
  Future<ChatRoomModel?> getchatroom(UserModel targetuser) async {
    ChatRoomModel? chatRoom;
   QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("chatrooms").
    where("participants.${widget.firebaseUser.uid}", isEqualTo: true).where
      ("participants.${targetuser.uid}", isEqualTo: true).get();

    if(snapshot.docs.length > 0) {
      // Fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom = ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      print("Chatroom already exist");
      chatRoom = existingChatroom;
    }
    else{
      //create new chatroom
      ChatRoomModel newchatroom=ChatRoomModel(
        chatroomid:uuid.v1(),
        lastmessage: "",
        participants: {
          widget.userModel.uid.toString():true,
          targetuser.uid.toString():true,
        },
      );
      await FirebaseFirestore.instance.collection("chatrooms").
      doc(newchatroom.chatroomid).set(newchatroom.toMap());
      print("new chatrooom created");
    }
    return chatRoom;

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Color(0xFF006BFF),
        centerTitle: true,
        title: Text("Search",style: TextStyle(color: Colors.white),),
      ),
      body: SafeArea(child: Container(
        child: Column(
          children: [
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10
              ),
              child: TextField(
                controller:searchController ,

                decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black,),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(25)),

                    ),
                    labelText: "Email Address"

                ),
              ),
            ),
            SizedBox(height: 20,),
            CupertinoButton(
                color:Color(0xFF006BFF),
                child: Text("Search",),
                onPressed: (){
                  setState(() {

                  });
                }

            ),
            SizedBox(height: 20,),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection("users").where("email",isNotEqualTo: widget.userModel.email).where("email", isEqualTo: searchController.text).snapshots(),
              builder: (context, snapshot) {
                //it check snapshot is connected to the firebase or not
                if(snapshot.connectionState == ConnectionState.active)
                  {
                    // it check snapshot has a data?
                      if(snapshot.hasData)
                        {
                          //At that time We conver snapshot to the querysnapshot 
                          QuerySnapshot datasnapshot =snapshot.data as QuerySnapshot;
                          //it check is datasnapshot has data or not?
                          if(datasnapshot.docs.length>0){
                            //create datasnapshot to map
                            Map<String,dynamic> usermap=datasnapshot.docs[0].data() as Map<String,dynamic>;
                            //calling frommap from UserModel
                            UserModel searchuser=UserModel.fromMap(usermap);
                            return ListTile(
                              onTap: ()async{
                               ChatRoomModel? chatroommodel= await getchatroom(searchuser);
                                if(chatroommodel !=null)
                                  {
                                    Navigator.pop(context);
                                    Navigator.push(context,MaterialPageRoute(builder: (context) =>Chatroompage(
                                      targetuser: searchuser,
                                      firebaseuser: widget.firebaseUser,
                                      chatroom: chatroommodel,
                                      userModel: widget.userModel,

                                    ),));
                                  }

                              },
                              leading: CircleAvatar(backgroundImage: NetworkImage(searchuser.profilepic!),
                              backgroundColor: Colors.grey,),
                              title: Text(searchuser.fullname!),
                              subtitle: Text(searchuser.email!),
                              trailing: Icon(Icons.keyboard_arrow_right),
                            );
                          }
                          else{
                            return Text("No Result Found");
                          }
                          //At that moment we convert  querysnapshot to the map and fatch user map 
                          
                        }else if(snapshot.hasError){
                        return Text("An Error Occur");
                      }else{
                        return Text("No Result Found");
                      }
                  }
                else{
                  return CircularProgressIndicator();
                }
              },),
          ],
        ),
      )),
    );
  }
}
