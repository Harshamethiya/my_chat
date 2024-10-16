import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/models/UIhelper.dart';
import 'package:my_chat/models/usermodel.dart';
import 'package:my_chat/pages/CompleteProfile.dart';
    class Signuppage extends StatefulWidget {
      const Signuppage({super.key});

      @override
      State<Signuppage> createState() => _SignuppageState();
    }

    class _SignuppageState extends State<Signuppage> {
      TextEditingController emailcon = TextEditingController();
      TextEditingController passcon = TextEditingController();
      TextEditingController cpasscon = TextEditingController();
      void checkvalue (){
        String email= emailcon.text.trim();
        String pass= passcon.text.trim();
        String cpass= cpasscon.text.trim();
        if(email=="" || pass==""|| cpass=="")
          {
            UIhelper.showAlertDialog(context,"Incomplate Data", 'Please Fill All The  Fields');
          }else if(pass!=cpass){
          UIhelper.showAlertDialog(context,"Incomplate Data", 'Password Missmatch');
        }
        else{
          signup(email, pass);
        }

    }
    void signup(String email,String pass)async{
        UserCredential? usercredential;
        UIhelper.showloaddingDialog(context, "Creating New User");
        try{
          usercredential= await FirebaseAuth.instance.createUserWithEmailAndPassword
            (email: email, password: pass);
        }on FirebaseAuthException catch(e){

         Navigator.pop(context);
         UIhelper.showAlertDialog(context,"An Error Occur",e.message.toString());
        }
        if(usercredential != null)
          {
            String uid=usercredential.user!.uid;
            UserModel usermodel=UserModel(uid:uid,
                fullname:"",
                email:email,
                profilepic:"");
            await FirebaseFirestore.instance.collection("users").doc(uid).set(usermodel.toMap()).then((value) => print("New User Created"),);
            Navigator.popUntil(context, (route) => route.isFirst,);
            Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Completeprofile(usermodel: usermodel, firebaseUser: usercredential!.user!),)
            );


          }

    }
      @override
      Widget build(BuildContext context) {
        return Scaffold(
          body:SafeArea(
            child:  Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 30
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset("assets/images/log-in.png"),
                      const Text("Chat App",style: TextStyle(

                          fontSize: 40,
                          fontWeight: FontWeight.bold
                      ),),
                      const SizedBox(height: 10,),
                      TextField(
                        controller: emailcon,

                        decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black,),
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color:Colors.black),
                              borderRadius: BorderRadius.all(Radius.circular(25)),

                            ),
                            labelText: "Enter Email"

                        ),
                      ),
                      const SizedBox(height: 10,),
                      TextField(
                        controller:passcon,
                        obscureText: true,
                        decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black,),
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.all(Radius.circular(25)),

                            ),
                            labelText: "Enter Password"

                        ),
                      ),
                      const SizedBox(height: 10,),
                      TextField(
                        controller: cpasscon,
                        obscureText: true,
                        decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black,),
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.all(Radius.circular(25)),

                            ),
                            labelText: "Conform Password"

                        ),
                      ),
                      const SizedBox(height: 20,),
                      CupertinoButton(
                          child: const Text("Sign In"),
                          color: Color(0xFF08C2FF),
                          onPressed: (){
                            checkvalue();
                           // Navigator.push(context, MaterialPageRoute(builder: (context){return Completeprofile();}));
                          }),
                      const SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.only(left: 60),
                        child: Row(
                            children: [
                              const Text("Already have an account?",style: TextStyle(fontSize: 16),),
                              CupertinoButton(
                                  child: const Text("Login",style: TextStyle(fontSize: 15)),
                                  // color: Theme.of(context).colorScheme.secondary,
                                  onPressed: (){

                                    Navigator.pop(context);
                                  })]),
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
