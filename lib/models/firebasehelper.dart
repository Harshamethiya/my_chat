import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_chat/models/usermodel.dart';

class firebasehelper {

  static Future<UserModel?> getusermodel(String uid)async{
    UserModel? userModel;
    DocumentSnapshot docsnap=await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if(docsnap.data()!=null)
      {
        userModel = UserModel.fromMap(docsnap.data() as Map<String,dynamic>);
      }
    return userModel;
  }
}