import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat/models/UIhelper.dart';
import 'package:my_chat/models/notification.dart';
import 'package:my_chat/models/usermodel.dart';
import 'package:my_chat/pages/HomePage.dart';
class Completeprofile extends StatefulWidget {
  final UserModel usermodel;
  final User firebaseUser;

  const Completeprofile({super.key, required this.usermodel, required this.firebaseUser});


  @override
  State<Completeprofile> createState() => _CompleteprofileState();
}

class _CompleteprofileState extends State<Completeprofile> {
  File? imagefile;
  TextEditingController fulllname_controller = TextEditingController();
  //TextEditingController fullname = TextEditingController();

  void imagecropper(XFile file) async {
    var cropimage = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1,),
        compressQuality: 5
    );
    if (cropimage != null) {
      setState(() {
        imagefile = File(cropimage.path);
      });
    }
    // CroppedFile? cropimage=await ImageCropper.cropImage(sourcePath: file.path);
  }

  void selectimage(ImageSource imagesource) async {
    XFile? pickfile = await ImagePicker().pickImage(source: imagesource);
    if (pickfile != null) {
      imagecropper(pickfile);
    }
  }

  void photooption() {
    Notificationservice service_noti=Notificationservice();
    var per=service_noti.reqestNotificationPermision();

    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Upload Profile Picture"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                Navigator.pop(context);
                selectimage(ImageSource.gallery);
              },
              leading: Icon(Icons.photo_album),
              title: Text("Select from Gallery"),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                selectimage(ImageSource.camera);
              },
              leading: Icon(Icons.photo_camera),
              title: Text("Select from Camera"),
            )
          ],
        ),
      );
    });
  }

  void checkvalue() {
    String fullname = fulllname_controller.text.trim();
    if (fullname == "" || imagefile == "") {
      UIhelper.showAlertDialog(context, "Incomplete Data",'Please enter all the field and upload profile pic' );
      print('Please enter all the fielda');
    }
    else {
      uploaddata();
    }
  }

  void uploaddata() async {
    UIhelper.showloaddingDialog(context, "Uploadding Image");
    UploadTask uploadtask = FirebaseStorage.instance.ref("profilepicture").child(widget.usermodel.uid.toString()).putFile(imagefile!);
    TaskSnapshot snapshot = await uploadtask;
    String imageUrl =await snapshot.ref.getDownloadURL();
    String fullname=fulllname_controller.text.trim();
    widget.usermodel.fullname=fullname;
    widget.usermodel.profilepic=imageUrl;
    await FirebaseFirestore.instance.collection("users").doc(widget.usermodel.uid).set(widget.usermodel.toMap());
    //it pop while firast page is not come
    Navigator.popUntil(context, (route) => route.isFirst,);
    // we are replase first page to navigator page
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) =>
          Homepage(usermodel: widget.usermodel, firebaseUser: widget.firebaseUser) ,));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:Color(0xFF006BFF),
        centerTitle: true,
        title: Text("Complete Profile"),
      ),
      body: SafeArea(
          child: Container(

            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 40
              ),
              child: ListView(
                children: [
                  SizedBox(height: 20,),
                  CupertinoButton(
                    onPressed: () {
                      photooption();
                    },
                    child: CircleAvatar(
                      backgroundImage: (imagefile != null) ? FileImage(
                          imagefile!) : null,
                      radius: 60,
                      child: (imagefile == null)
                          ? Icon(Icons.person, size: 60,)
                          : null,


                    ),

                  ),

                  SizedBox(height: 20,),
                  TextField(
                    controller: fulllname_controller,

                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black,),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(25)),

                        ),
                        labelText: "Enter Your Full Name"

                    ),
                  ),
                  SizedBox(height: 20,),
                  CupertinoButton(
                      child: const Text("Submit"),
                      color: Theme
                          .of(context)
                          .colorScheme
                          .secondary,
                      onPressed: () {checkvalue();}),
                ],
              ),
            ),
          )
      ),
    );
  }
}

