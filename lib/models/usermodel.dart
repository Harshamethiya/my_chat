class UserModel{
  String? uid;
  String? fullname;
  String? email;
  String? profilepic;

  //Constractor
  UserModel({this.uid, this.fullname, this.email, this.profilepic});

  //Map to Model
  UserModel.fromMap(Map<String,dynamic> map){
    uid=map["uid"];
    fullname=map["fullname"];
    email=map["email"];
    profilepic=map["profilepic"];
  }
//Create Map
  Map<String,dynamic> toMap(){
    return {
      "uid":uid,
      "fullname":fullname,
      "email":email,
      "profilepic":profilepic
    };
  }
}