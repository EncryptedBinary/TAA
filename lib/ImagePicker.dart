import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'FaceApi.dart';
import 'login.dart';
import 'userModel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider_android/path_provider_android.dart';
import 'package:path_provider/path_provider.dart';

class  ImagePickerApp extends StatefulWidget{

  //UserModel? userModel;

  ImagePickerApp ({Key? key}) : super (key : key);
  // getImage() {
  //   // TODO: implement getImage
  //   _ImagePickerAppState().getImage();
  // }
  @override
  _ImagePickerAppState createState() => _ImagePickerAppState();

}

class _ImagePickerAppState extends State<ImagePickerApp>{
  UserModel? userModel;
  var url;
  //_ImagePickerAppState(this.userModel);
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // File? _image;
  // Future<String?> getImage() async{
  //   try {
  //     final image = await ImagePicker().pickImage(source: ImageSource.camera);
  //     if (image == null) return null;
  //
  //     final imageTempo = File(image.path);
  //
  //     setState(() {
  //       this._image = imageTempo;
  //     });
  //     return _image?.path;
  //   } on PlatformException catch (e){
  //     print('Failed to pick image: $e');
  //   }
  //
  // }
  User? user;
  //UserModel? userModel;
  //DatabaseReference? userRef;

  File? _image;
  bool showLocalFile = false;


  // _getUserDetails() async {
  //   DataSnapshot snapshot = await userRef!.get();
  //
  //   userModel = UserModel.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
  //
  //
  //   setState(() {});
  // }

  _pickImageFromCamera() async {

    final path = await Navigator.push(context, MaterialPageRoute(
        builder: (context)=>faceApi()));
    print("file in image: "+ path);
    print(path);
    //  XFile? xFile = await ImagePicker().pickImage(source: ImageSource.camera);

    //if( xFile == null ) return;
    if(path== null || path =="") return;
    File f = File(path);
    final tempImage = f;
    print("store path: ${tempImage.path}");

    _image = tempImage;

    // XFile? xFile = await ImagePicker().pickImage(source: ImageSource.camera);
    //
    // if( xFile == null ) return;
    //
    // final tempImage = File(xFile.path);
    // print("store path: ${tempImage.path}");
    // String pass = tempImage.path;

    _image = tempImage;
    //showLocalFile = true;
    setState(() {

    });
    showDialog(
        context: context,
        builder: (context){
          return Center(child: CircularProgressIndicator());

        });

    // upload to firebase storage


    // ProgressDialog progressDialog = ProgressDialog(
    //   context,
    //   title: const Text('Uploading !!!'),
    //   message: const Text('Please wait'),
    // );
    // progressDialog.show();
    try{
      // var fileName = userModel!.email + '.jpg';
      //
      // Reference ref = _firestore.ref().child("image1" + DateTime.now().toString());
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child("image1${DateTime.now()}");
      UploadTask uploadTask = ref.putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask;
      url = await taskSnapshot.ref.getDownloadURL();
      // // var url;
      //  uploadTask.then((res) {
      //    url= res.ref.getDownloadURL();
      //
      //  });
      if (kDebugMode) {
        print ("url in pick: $url");
        Navigator.of(context).pop();
      }
      //userModel?.image_url = url;





      // Reference ref = _firestore.
      //UploadTask uploadTask =
      //FirebaseStorage.instance.ref().child('profile_images').child(fileName).putFile(_image!);


      //TaskSnapshot snapshot = await uploadTask;

      //String profileImageUrl = await snapshot.ref.getDownloadURL();

      // print(profileImageUrl);
      // return profileImageUrl;

      // final ref = _firestore.collection('users').doc(user?.uid).withConverter(
      //   fromFirestore: UserModel.fromFirestore,
      //   toFirestore: (UserModel model, _) => model.toFirestore(),
      // );
      // final docSnap = await ref.get();
      // final model = docSnap.data();

      //progressDialog.dismiss();

    } catch( e ){
      // progressDialog.dismiss();

      print(e.toString());
    }


  }

  // _pickImageFromCamera() async {
  //   XFile? xFile = await ImagePicker().pickImage(source: ImageSource.camera);
  //
  //   if( xFile == null ) return;
  //
  //   final tempImage = File(xFile.path);
  //
  //   _image = tempImage;
  //   showLocalFile = true;
  //   setState(() {
  //
  //   });
  // }

  @override
  void initState() {
    super.initState();

    // user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   userRef =
    //       FirebaseDatabase.instance.reference().child('users').child(user!.uid);
    // }

    build(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick an image'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40,),
            if (_image!=null) Image.file(
              _image!,width:250,
              height: 250,
              fit: BoxFit.cover,
            )  else Image.network('https://png.pngtree.com/png-vector/20190223/ourmid/pngtree-profile-glyph-black-icon-png-image_691589.jpg'),
            const SizedBox(height: 20,),
            if(_image== null) CustomButton(
                title: 'Pick from camera',
                icon: Icons.camera,
                onClick: () => _pickImageFromCamera())
            else CustomButton(title: 'Proceed',icon: Icons.enhance_photo_translate,
                onClick: () => Navigator.of(context).pop(url)),
          ],
        ),
      ),
    );
  }
}
// _uploadImages() async {
//   for (var image in _images) {
//     var _ref = _stoarge.ref().child("images/" + basename(image.path));
//     await _ref.putFile(image);
//     String url = await _ref.getDownloadURL();
//
//     print(url);
//     urls.add(url);
//     print(url);
//   }
//   print("uploading:" + urls.asMap().toString());
//   await FirebaseFirestore.instance
//       .collection("users")
//       .doc(auth.currentUser.uid)
//       .update({"images": urls});
//   //  .doc(auth.currentUser.uid).update({"images": FieldValue.arrayUnion(urls) });
// }


Widget CustomButton({
  required String title,
  required IconData icon,
  required VoidCallback onClick,
}){
  return Container(
    child: ElevatedButton(onPressed: onClick,
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 20,),
          Text(title),
        ],
      ),),
  );
}