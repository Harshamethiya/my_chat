import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/models/UIhelper.dart';
import 'package:my_chat/models/notification.dart';
import 'package:my_chat/models/usermodel.dart';
import 'package:my_chat/pages/CompleteProfile.dart';
import 'package:my_chat/pages/HomePage.dart';
import 'package:my_chat/pages/SignUpPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();

  void checkvalue() {
    String loginemail = email.text.trim();
    String loginpass = pass.text.trim();
    if (loginemail == "" || loginpass == "") {
      UIhelper.showAlertDialog(context,"Incomplate Data", 'Please Fill All The  Fields');

    }
    else {
      login(loginemail, loginpass);
    }
  }

  void login(String email, String pass) async {
    UserCredential? credential;
    UIhelper.showloaddingDialog(context, "Logging In....");
    try{
      credential= await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
    }on FirebaseAuthException catch(e){
      // When user fill wrong password then it close means pop loadding dialog
      Navigator.pop(context);
      UIhelper.showAlertDialog(context, "An Error Occur", e.message.toString());

    }
      if(credential !=null){
        String uid= credential.user!.uid;
        DocumentSnapshot userdate =await FirebaseFirestore.instance.collection('users').doc(uid).get();
        UserModel usermodel=UserModel.fromMap(userdate.data() as Map<String,dynamic>);
        Navigator.popUntil(context, (route) => route.isFirst,);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage(usermodel: usermodel, firebaseUser: credential!.user!,),));
       // print('Login Successfull');
      }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 30
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                      child: Image.asset("assets/images/login (1).png",height: 250,)),
                  Text("Chat App", style: TextStyle(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .secondary,
                      fontSize: 40,
                      fontWeight: FontWeight.bold
                  ),),
                  SizedBox(height: 10,),
                  TextField(

                    controller: email,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black,),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme
                              .of(context)
                              .colorScheme
                              .secondary,),
                          borderRadius: BorderRadius.all(Radius.circular(25)),

                        ),
                        labelText: "Enter Email"

                    ),
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: pass,
                    obscureText: true,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black,),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme
                              .of(context)
                              .colorScheme
                              .secondary,),
                          borderRadius: BorderRadius.all(Radius.circular(25)),

                        ),
                        labelText: "Enter Password"

                    ),
                  ),
                  SizedBox(height: 20,),
                  CupertinoButton(
                      child: Text("Log In"),
                      color:  Color(0xFF08C2FF),
                      onPressed: () {
                        checkvalue();
                      }),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: Row(
                        children: [
                          Text("Don't have an account?", style: TextStyle(
                              fontSize: 16),),
                          CupertinoButton(
                              child:
                              Text("Sign Up",
                                  style: TextStyle(fontSize: 12)),
                              // color: Theme.of(context).colorScheme.secondary,
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const Signuppage()),);
                              })
                        ]),
                  )
                ],

              ),
            ),
          ),
        ),
      ),


    );
  }

}


