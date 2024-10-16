import 'package:flutter/material.dart';

class UIhelper{
 static void showloaddingDialog(BuildContext context,String tittle){
   AlertDialog loaddingDialog =AlertDialog(
     content: Container(

       child: Padding(
         padding: const EdgeInsets.all(8.0),
         child: Column(mainAxisSize: MainAxisSize.min,

           children: [
             CircularProgressIndicator(),
             Text(tittle),
           ],
         ),
       ),
     ),
   );
   showDialog(
     //barrierDismissible for when user tap outter loadding it cant closed
     barrierDismissible: false,
     context: context,
     builder: (context) =>
     loaddingDialog,);
 }
 static void showAlertDialog(BuildContext contaxt, String tittle,String content){
   AlertDialog alertDialog= AlertDialog(
     title: Text(tittle),
     content: Text(content),
     actions: [
       TextButton(onPressed: (){

         Navigator.pop(contaxt);
       }, child:Text("Ok"))
     ],
   );
   showDialog(context: contaxt, builder: (context) => alertDialog,);
 }
}
