import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class Notificationservice {
  FirebaseMessaging messaging =FirebaseMessaging.instance;
  void reqestNotificationPermision()async{
  final  permision = Permission.camera;
  if(await permision.isDenied)
    {
      await permision.request();
    }
  //   // it request user for permision
  //    NotificationSettings setting =await messaging.requestPermission(
  //   //alert for soving user permision
  //     alert: true,
  //     //it is for someone dont read notification
  //     announcement: true,
  //     //for ex whatapp icon and 123 indicator like that
  //     badge: true,
  //     carPlay: true,
  //     criticalAlert: true,
  //     //turnoff or turrnon permission
  //     provisional: true,
  //     sound: true
  //
  //   );
  //   if(setting.authorizationStatus==AuthorizationStatus.authorized){
  //     print("user granted permision");
  //   }else if(setting.authorizationStatus==AuthorizationStatus.provisional){
  //     print("user granted provisional permision");
  //   }else{
  //     print("user denied permision");
  //   }


   }
   Future<bool> checkpermision ()async{
    final permision =Permission.notification;
    return await permision.status.isGranted;
   }
}