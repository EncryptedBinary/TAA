
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_face_api/face_api.dart';
import 'package:projecttaa/FaceApi.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projecttaa/login.dart';
import 'package:projecttaa/main.dart';
import 'package:projecttaa/view_file.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'add_file.dart';
import 'dart:convert';
import 'package:image/image.dart';
import 'dart:io' as io;
import 'package:flutter_face_api/face_api.dart' as Regula;
import 'dart:typed_data';

class homepage extends StatefulWidget {
  final String dpPath;
  homepage({Key? key, required this.dpPath}) : super(key: key);

  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  bool? isAddFileTapped;
  bool? isViewFileTapped;
  String? localDppath;

  bool? result;
  bool isLoading= false;
  //String userEmail = "";

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      localDppath = widget.dpPath;
      result = false;
      isAddFileTapped = false;
      isViewFileTapped = false;
    });
  }

  bool _canPop = false;

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(

        onWillPop: () async {
          if (_canPop) {
            return true;
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Alert"),
                content: Text("Are you sure you want to exit?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("No"),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _canPop = true;
                      });
                      io.exit(0);
                    },
                    child: Text("Yes"),
                  ),
                ],
              ),
            );
            return false;
          }
        },
        child:  Scaffold(
        body:  Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('image/homepage.jpg'),
            fit: BoxFit.fill
          ),
        ),
        child: Scaffold(
         backgroundColor: Colors.transparent,
          floatingActionButton: Column(

            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(padding: const EdgeInsets.only(top:20),),
              FloatingActionButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  await GoogleSignIn().signOut();
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context)=>loginWithGoogle()
                  ));
                  // Add your onPressed code here!
                },
                backgroundColor: Colors.transparent,
                child: const Icon(Icons.logout),shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.only(left: 40, right: 40, top: 60, bottom: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(120),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 10,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child:
                          CircleAvatar(
                            radius: 120,
                            backgroundImage: FileImage(io.File(localDppath!))
                          ),


                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(child: Text("USER",style: TextStyle(color: Colors.redAccent, fontSize: 25,fontWeight: FontWeight.bold), ),),

                        // const Text(
                        //  'Why you are here noob:) ',
                        //   style: TextStyle(
                        //       fontSize: 24,
                        //      fontWeight: FontWeight.bold,
                        //      color: Colors.white),
                        // ),
                        Spacer(),
                        // SizedBox(height: 80,),
                        ElevatedButton.icon(
                           style: ElevatedButton.styleFrom(
                              primary: Colors.purpleAccent,
                              onPrimary: Colors.white,
                              minimumSize: Size(double.infinity, 50),
                            ),
                            icon:
                            FaIcon(FontAwesomeIcons.add, color: Colors.white),
                            label: Text('Add File'),
                            onPressed: ()  async {
                              setState((){
                                isAddFileTapped = true;
                              });
                              // final imagePathforverification = await Navigator.push(context, MaterialPageRoute(
                              //     builder: (context)=>faceApi()));
                              // //check spoof
                              //match image

                              //match image
                              //matchFaces(localDppath!, imagePathforverification);
                              if(isAddFileTapped==true) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    });
                              }

                              //if matches result = true
                             // result = ((_similarity != null) || (_similarity != "nil") || (_similarity != "error")) ? true : false;

                              //if matches result = true
                              print("tapped");
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context)=>AddFile(dpPath: widget.dpPath,)
                            )
                          );
                          }),
                        SizedBox(
                         height: 20,
                        ),
                        ElevatedButton.icon(
                           style: ElevatedButton.styleFrom(
                             primary: Colors.redAccent,
                             onPrimary: Colors.white,
                              minimumSize: Size(double.infinity, 50),
                           ),
                           icon: FaIcon(FontAwesomeIcons.usersViewfinder,
                               color: Colors.white),
                           label: Text('View File'),
                           onPressed: ()  async {
                             setState((){
                               isViewFileTapped = true;
                             });
                             final imagePathforverification2 = await Navigator.push(context, MaterialPageRoute(
                                 builder: (context)=>faceApi()));
                             //check spoof
                             //match image
                             matchFaces(localDppath!, imagePathforverification2);
                             if(isLoading) {
                               showDialog(
                                   context: context,
                                   builder: (context){
                                     return Center(child: Row(
                                       mainAxisAlignment: MainAxisAlignment.center,
                                       children: const [
                                         CircularProgressIndicator(color: Colors.white,),
                                         //const SizedBox(width: 15,),
                                         Text("  Verifying Image....", style: TextStyle(fontSize: 18, color: Colors.white,
                                             decoration: TextDecoration.none),),

                                       ],
                                     ));

                                   });
                             }
                             //
                             // //if matches result = true
                             // result = ((_similarity != null) || (_similarity != "nil") || (_similarity != "error")) ? true : false;
                             //
                             // setState(() async{
                             // });
                             //if matches result = true
                             print("tapped");
                            // if(result == true){
                            //  Navigator.push(context, MaterialPageRoute(
                            //       builder: (context)=>ViewFile(dpPath: widget.dpPath,)
                            //  ),);
                           //}

                            }),
                        Spacer(),
                       //  Container(
                       //   alignment: Alignment.bottomLeft,
                       //      child: ElevatedButton(onPressed:() async {
                       //        await FirebaseAuth.instance.signOut();
                       //
                       //        await GoogleSignIn().signOut();
                       //        Navigator.push(context, MaterialPageRoute(
                       //            builder: (context)=>loginWithGoogle()
                       //        ));
                       //    }, child: Text('Logout')),
                       // )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),);

  }

  var image1 = new Regula.MatchFacesImage();
  var image2 = new Regula.MatchFacesImage();
  String _similarity = "nil";

  setImage(bool first, Uint8List? imageFile, int type) {
    if (imageFile == null) return;

    if (first) {
      print("Come22");
      image1.bitmap = base64Encode(imageFile);
      image1.imageType = type;
    } else {
      print("Come23");
      image2.bitmap = base64Encode(imageFile);
      image2.imageType = type;

    }
  }
  matchFaces(String imagePath1, String imagePath2)  {
    setState(() {
      isLoading = true;
    });
    print("come");
    setImage(
        true,
        io.File(imagePath1).readAsBytesSync(),
        Regula.ImageType.PRINTED);
    setImage(
        false,
        io.File(imagePath2).readAsBytesSync(),
        Regula.ImageType.PRINTED);

    if (image1.bitmap == null ||
        image1.bitmap == "" ||
        image2.bitmap == null ||
        image2.bitmap == "") return;
    setState(() => _similarity = "Processing...");
    var request = new Regula.MatchFacesRequest();
    request.images = [image1, image2];
    Regula.FaceSDK.matchFaces(jsonEncode(request)).then((value) {
      var response = Regula.MatchFacesResponse.fromJson(json.decode(value));
      Regula.FaceSDK.matchFacesSimilarityThresholdSplit(
          jsonEncode(response!.results), 0.75)
          .then((str) {
        var split = Regula.MatchFacesSimilarityThresholdSplit.fromJson(
            json.decode(str));
        setState(() => _similarity = split!.matchedFaces.length > 0
            ? ((split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2) +
            "%")
            : "error");
        print("Face match: " + _similarity);
        if(_similarity=="error"){
          Navigator.of(context).pop();
        }
        else if(_similarity.endsWith("%") && isAddFileTapped==true){
          Navigator.push(context, MaterialPageRoute(
              builder: (context)=>AddFile(dpPath: widget.dpPath,)
          )
          );
          setState(() {
            isAddFileTapped = false;
          });
        }
        else if(_similarity.endsWith("%") && isViewFileTapped==true){
          setState(() {
            isLoading = false;
            isViewFileTapped = false;
            Navigator.of(context).pop();
          });
          Navigator.push(context, MaterialPageRoute(
              builder: (context)=>ViewFile(dpPath: widget.dpPath,)
          ),);

        }
      });
    });
  }
}



