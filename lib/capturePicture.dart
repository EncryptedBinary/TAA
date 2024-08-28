// import 'dart:async';
// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:projecttaa/homepage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:file_picker/file_picker.dart';
//
// class capturePictureWindow extends StatefulWidget {
//   capturePictureWindow({Key? key}) : super(key: key);
//
//   @override
//   _capturePictureWindowState createState() => _capturePictureWindowState();
// }
//
// class _capturePictureWindowState extends State<capturePictureWindow> {
//   File? imageFile;
//   String userEmail = "";
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Image Picker"),
//
//       ),
//       body: Container(
//         child: imageFile == null
//             ? Container(
//                 alignment: Alignment.center,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     Container(
//                       height: 40.0,
//                     ),
//                     TextButton(
//                       onPressed: ()  {
//                         _getFromCamera();
//                       },
//                       child: Text("PICK FROM CAMERA"),
//                     ),
//
//                   ],
//                 ),
//               )
//             : Container(
//                 child: Image.file(
//                   imageFile!,
//                   fit: BoxFit.cover,
//
//                 ),
//               ),
//       )
//
//
//     );
//     Navigator.push(context, MaterialPageRoute(
//         builder: (context)=>homepage()
//     ));
//   }
//
//   /// Get from Camera
//   _getFromCamera() async {
//     PickedFile? pickedFile = await ImagePicker().getImage(
//       source: ImageSource.camera,
//       maxWidth: 1800,
//       maxHeight: 1800,
//     );
//     if (pickedFile != null) {
//       setState(() {
//         imageFile = File(pickedFile.path);
//       });
//       uploadPic(imageFile!);
//     }
//   }
//
//   uploadPic(File _image1) async {
//     FirebaseStorage storage = FirebaseStorage.instance;
//     Reference ref = storage.ref().child("image1" + DateTime.now().toString());
//     UploadTask uploadTask = ref.putFile(_image1);
//     uploadTask.then((res) {
//       res.ref.getDownloadURL();
//     });
//
//           Navigator.push(context,MaterialPageRoute(
//               builder: (context)=>homepage()
//           ));
// }
//
//   // uploadImage(){
//   //   var randomo = Random(25);
//   //   FirebaseStorage storage = FirebaseStorage.instance;
//   //   final Reference firebaseStoreageRef  = storage.ref()
//   //       .child('profilepics/${randomo.nextInt(5000).toString()}.jpg');
//   //   UploadTask uploadTask = firebaseStoreageRef.putFile(newProfilePic);
//   //
//   //   uploadTask.then((value){
//   //     value.ref.getDownloadURL();
//   //   });
//   // }
//   // updateProfilePic(picUrl){
//   //   var userinfo = FirebaseAuth.instance.currentUser;
//   //   userinfo?.updatePhotoURL(picUrl);
//
// //   File? imageFile;
// //   @override
// //   Future Build(BuildContext context) async {
// //     return Scaffold(
// //       body: ListView(
// //         children: [
// //           SizedBox(height: 50),
// //           imageFile != null ?
// //           Container(
// //             child: Image.file(imageFile!),
// //           ) :
// //           Container(
// //             child: Icon(
// //               Icons.camera_enhance_rounded,
// //               color : Colors.green,
// //               size : MediaQuery.of(context).size.width * .6,
// //
// //             ),
// //           ),
// //           Padding(
// //             padding:const EdgeInsets.all(30.0),
// //             child: ElevatedButton(
// //               child: Text('Capture Image with Camera'),
// //               onPressed: (){
// //                String url = _getFromCamera() as String;
// //               },
// //               style: ButtonStyle(
// //                 backgroundColor: MaterialStateProperty.all(Colors.cyan),
// //                 padding: MaterialStateProperty.all(EdgeInsets.all(12)),
// //                 textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16)),
// //               ),
// //             ),
// //
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// }
