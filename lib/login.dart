import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projecttaa/add_file.dart';
import 'package:projecttaa/homepage.dart';
import 'package:projecttaa/userModel.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'FaceApi.dart';
import 'ImagePicker.dart';
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter_face_api/face_api.dart' as Regula;
import 'dart:typed_data';
import 'capturePicture.dart';
import 'capturePicture.dart';

class loginWithGoogle extends StatefulWidget {
  loginWithGoogle ({Key? key}) : super(key: key);

  @override
  _loginWithGoogleState createState() => _loginWithGoogleState();
}

class _loginWithGoogleState extends State<loginWithGoogle> {
  String? imagePath;




  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool? result;

  String userEmail = "";
  final RoundedLoadingButtonController googleController = RoundedLoadingButtonController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  void _success() async{
    Timer(Duration(milliseconds: 10), () async {
      await signInWithGoogle();
      // if(result==true){
      //   Navigator.push(context,MaterialPageRoute(
      //       builder: (context)=>homepage(dpPath: imagePath!,)
      //   ));
      // }
      //else{
        // await FirebaseAuth.instance.signOut();
        //
        // await GoogleSignIn().signOut();
        // Navigator.push(context, MaterialPageRoute(
        //     builder: (context)=>loginWithGoogle()
        // ));
      //}
    });
  }
  //String userEmail = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('image/image_background.jpg'),
          fit: BoxFit.fill,

          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 40, right: 40, top: 60, bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20,),
                        const Text(
                          'Welcome to FaceMe',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  Column(
                   crossAxisAlignment: CrossAxisAlignment.center,
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                      RoundedLoadingButton(
                        onPressed: _success,
                        controller: googleController,
                        successColor: Colors.red,
                        width: MediaQuery.of(context).size.width*0.8,
                        elevation: 0,
                        borderRadius: 25,

                        child: Wrap(
                          children: const [
                           Icon(
                                FontAwesomeIcons.google,
                                size: 20,
                                color: Colors.white,

                              ),
                            SizedBox(width: 15,),
                            Text("Sign in with Google",style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
                          ],
                        ),
                        color: Colors.blue,
                      ),
                    ],
                 )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  signInWithGoogle() async {
    // await FirebaseAuth.instance.signOut();
    //
    // await GoogleSignIn().signOut();
    // exit(0);
    bool result = false;
    // Trigger the authentication flow
    try{
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if(user!= null) {

        // final docRef = _firestore.collection('users').doc(user.uid);
        // final docSnap = await docRef.get();
        // final model = docSnap.data();
        final ref = _firestore.collection('users').doc(user.uid).withConverter(
          fromFirestore: UserModel.fromFirestore,
          toFirestore: (UserModel model, _) => model.toFirestore(),
        );
        final docSnap = await ref.get();
        final model = docSnap.data();
        print("Model image: ${model?.image_url}");
        print(user.photoURL);

        if (userCredential.additionalUserInfo!.isNewUser || model?.image_url==null) {
          final url = await Navigator.push(context, MaterialPageRoute(
              builder: (context)=>ImagePickerApp()));
          showDialog(
              context: context,
              builder: (context){
                return Center(child: CircularProgressIndicator());

              });

          //print("Print url in log in: "+ url!);
          print("Model image: ${model?.image_url}");
          if(url!= null) {
            model?.image_url = url;

            print("Model image: ${model?.image_url}");
            print('Url: ' + url);
            // add firebase
            await _firestore.collection("users").doc(user.uid).set({
              'email': user.email,
              'name': user.displayName,
              'image_url': url,
            });
            result =true;
            String? dp =  await _download(url);
            File image = File(dp!);
            setState(() {
              imagePath = image.absolute.path;
            });
            if(result==true){
              Navigator.of(context).pop();
              Navigator.push(context,MaterialPageRoute(
                  builder: (context)=>homepage(dpPath: imagePath!,)
              ));
            }
          }
          else {
            alertBox("Error", "No profile image picked. Retry");
            print("close app");
            //return false;
          }
        }
        else{
          String? dp = await _download(model!.image_url);
          print("Dp path: "+ dp.toString());
          File image = File(dp!);
          setState(() {
            imagePath = image.absolute.path;
          });
          final imageStringPath = await Navigator.push(context, MaterialPageRoute(
              builder: (context)=>faceApi()));
          File verifyImage = File (imageStringPath);
          final imagePathforverification = verifyImage.absolute.path;
          //match image

          matchFaces(imagePath!, imagePathforverification);
          // showDialog(
          //     context: context,
          //     builder: (context){
          //       return Center(child: CircularProgressIndicator());
          //     });

          //result = ((_similarity != null) || (_similarity != "nil") || (_similarity != "error")) ? true : false;


          //if matches result = true
          // setState(() async{
          //   result = ((_similarity != null) || (_similarity != "nil") || (_similarity != "error")) ? true : false;
          // });
        }
        // result = true;
        // else if(user.photoURL == null){
        //   final url = await Navigator.push(context, MaterialPageRoute(
        //       builder: (context)=>ImagePickerApp()));
        //   print(url);
        //   //model.image_url = url;
        //
        //   // add firebase
        //   await _firestore.collection("users").doc(user.uid).set({
        //     'email' : user.email,
        //     'name': user.displayName,
        //     'image_url' : url,
        //   });
        // }
        print("File add");

      }
      else{
        exit(0);
      }

    }on Exception{
      alertBox("Alert!!", "Please check your internet connection.");


    }

    //Navigator.of(context).pop;
    //return result;
  }
  alertBox(String Title, String Content){
    return showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          title: Text(Title),
          content: Text(Content),
          actions: <Widget>[
            TextButton(
              onPressed: () => exit(0),
              child: const Text('Exit'),

            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context)=>loginWithGoogle()
              )),
              child: const Text('Retry'),
            ),
          ],
        )
    );
  }
  // File? imageFile;
  // Future<String> _getFromCamera() async {
  //   XFile? pickedFile = await ImagePicker().pickImage(
  //     source: ImageSource.camera,
  //     maxHeight: 1080,
  //     maxWidth: 1080,
  //   );
  //
  //   String url = "";
  //   Reference ref = FirebaseStorage.instance.ref().child("profilepic.jpg");
  //   await ref.putFile(File(pickedFile!.path));
  //   ref.getDownloadURL().then((value) {
  //     print(value);
  //     setState(() {
  //       url = value;
  //     });
  //   });
  //   return url;
  // }

  Future<String?> _download(String url) async {
    final response = await http.get(Uri.parse(url));

    // Get the image name
    final imageName = path.basename(url);
    // Get the document directory path
    final appDir = await path_provider.getApplicationDocumentsDirectory();

    // This is the saved image path
    // You can use it to display the saved image later
    final localPath = path.join(appDir.path, imageName);

    // Downloading
    final imageFile = File(localPath);
    await imageFile.writeAsBytes(response.bodyBytes);
    return imageFile.absolute.path;
  }
  var image1 = new Regula.MatchFacesImage();
  var image2 = new Regula.MatchFacesImage();
  String _similarity = "nil";

  setImage(bool first, Uint8List? imageFile, int type) {
    print("imageFile: "+imageFile.toString());
    if (imageFile == null) return;

    if (first) {
      print("Come22");
      image1.bitmap = base64Encode(imageFile);
      print(image1.bitmap);
      image1.imageType = type;
    } else {
      print("Come23");
      image2.bitmap = base64Encode(imageFile);
      image2.imageType = type;

    }
    print(image1.bitmap);
    print(image2.bitmap);
  }
matchFaces(String imagePath1, String imagePath2)  {
    print("imagepath1: "+ imagePath1);
    print("imagepath2: "+ imagePath2);
  //var image1 = new Regula.MatchFacesImage();
  //var image2 = new Regula.MatchFacesImage();
    print("come");
    setImage(
        true,
        io.File(imagePath1).readAsBytesSync(),
        Regula.ImageType.PRINTED);
    setImage(
        false,
        io.File(imagePath2).readAsBytesSync(),
        Regula.ImageType.PRINTED);
        print("helloww");
        print(image1.bitmap);
        print(image2.bitmap);
    if (image1.bitmap == null ||
        image1.bitmap == "" ||
        image2.bitmap == null ||
        image2.bitmap == "") return;
    print("Hiiii");
    setState(() => _similarity = "Processing...");
    var request = new Regula.MatchFacesRequest();
    request.images = [image1, image2];
    Regula.FaceSDK.matchFaces(jsonEncode(request)).then((value) {
      var response = Regula.MatchFacesResponse.fromJson(json.decode(value));
      Regula.FaceSDK.matchFacesSimilarityThresholdSplit(
          jsonEncode(response!.results), 0.75)
          .then((str) async {
        var split = Regula.MatchFacesSimilarityThresholdSplit.fromJson(
            json.decode(str));
        setState(() => _similarity = split!.matchedFaces.length > 0
            ? ((split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2) +
            "%")
            : "error");
        print("Face match: " + _similarity);
        if(_similarity=="error"){
          await FirebaseAuth.instance.signOut();

          await GoogleSignIn().signOut();
          Navigator.push(context, MaterialPageRoute(
              builder: (context)=>loginWithGoogle()
          ));
        }
        if(_similarity.endsWith("%")){
          setState(() {
            Navigator.push(context,MaterialPageRoute(
                builder: (context)=>homepage(dpPath: imagePath!,)
            ));
          });
        }
      });
    });
  }
}