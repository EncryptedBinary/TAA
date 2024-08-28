import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projecttaa/AntiSpoofing.dart';

import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter_face_api/face_api.dart' as Regula;
import 'dart:typed_data';

import 'login.dart';


//camera
List<CameraDescription>? cameras;

class CameraAppTest extends StatelessWidget {
  final String pdfPath;
  final String dpPath;

  const CameraAppTest({required this.pdfPath, required this.dpPath});
  static const routeName = '/videoRecordScreen';
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.0,
      height: 150.0,
      child: new Stack(children: <Widget>[
        new Container(
          alignment: Alignment.center,
          color: Colors.redAccent,
          child: PdfViewerPage(pdfPath: pdfPath,),
        ),
        new Align(alignment: Alignment.bottomRight,
          child: Demo(dpPath: dpPath,),
        )
      ],
      ),
    );
  }
}

class Square extends StatefulWidget {
  final String? dpPath;
  final color;
  final size;

  const Square({this.color, this.size, required this.dpPath});

  @override
  _SquareState createState() => _SquareState();
}

class _SquareState extends State<Square> {
  late CameraController controller;
  String? localDpPath;
  //List<CameraDescription>? cameras; //list out the camera available
  //CameraController? controller; //controller for camera
  XFile? image; //for captured image
  bool yes = false;
  int t = 10;
  bool? done;
  Timer? timer;
  bool? res;
  @override
  void initState() {
    super.initState();

    controller = CameraController(cameras![1], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        localDpPath = widget.dpPath;
        res = true;
      });
      final timer = Timer(
          const Duration(seconds: 3),
              () {
            start();
            start2();
          });
    });

    //l//oadCamera();
    //timer = Timer.periodic(const Duration(seconds: 100), (Timer t,) =>

    //start();

  }
  // loadCamera() async {
  //   cameras = await availableCameras();
  //   if(cameras != null){
  //     controller = CameraController(cameras![1], ResolutionPreset.max);
  //     //cameras[0] = first camera, change to 1 to another camera
  //
  //     controller.initialize().then((_) async {
  //       if (!mounted) {
  //         return;
  //       }
//       //start();
  //       setState(() {
  //         // while(a==false) {
  //         //  start();
  //         // }
  //       });
  //       // bool res = await start();
  //       // if(res==true){
  //       //   bool res = await start();
  //       //
  //       // }
  //     });
  //
  //   }else{
  //     print("NO any camera found");
  //   }
  // }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller));
  }

  start() async{

    //
//after 3 seconds this will be called,
//once this is called take picture or whatever function you need to do
    image = await controller.takePicture();
    print(image!.path);
    print("HOga");

    bool detect = await antiSpoofing().imageClassification(image!.path);
    print(detect);
    detect == true ? print("Detect") : print("not");

    try{
      if(detect==true){

        //String localDpPath = "assets/316698392_883976849269816_1135447483350734514_n.jpg";
        matchFaces(localDpPath!, image!.path);
        // while(_similarity=="nil"){
        //   //print("x");
        // }
        // print(_similarity);
        // if(_similarity!="error"){
        //   print("errorr");
        //   yes = false;
        // }
        // else{
        //   print("Correct");
        // }
        // if(yes == false){
        //   timer?.cancel();
        //   Navigator.of(context).pop();
        // }

        //bool result = ((_similarity != "nil") && (_similarity != "error")) ? true : false;
        // if (res!){
        //   print("matched");
        // }
        // else{
        //   print("unmatched");
        //   timer?.cancel();
        //   Navigator.of(context).pop();
        //
        // }
      }
      else{
        print("no entry!");
        timer?.cancel();
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Text("Error"),
                content: Text("User mismatched!\nTry Again"),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>loginWithGoogle()
                      )),
                      child: Text("Retry"))
                ],
              ),
        );
        // await FirebaseAuth.instance.signOut();
        //
        // await GoogleSignIn().signOut();
        // Navigator.push(context, MaterialPageRoute(
        //     builder: (context)=>loginWithGoogle()
        // ));

      }
    }on Exception{
      timer?.cancel();
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("Error"),
              content: Text("User mismatched!\nTry Again"),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (context)=>loginWithGoogle()
                    )),
                    child: Text("Retry"))
              ],
            ),
      );
    }
  }
  start2() async{

    print("start2");

    //
//after 3 seconds this will be called,
//once this is called take picture or whatever function you need to do
    image = await controller.takePicture();
    print(image!.path);
    print("HOga");

    bool detect = await antiSpoofing().imageClassification(image!.path);
    print(detect);
    detect == true ? print("Detect") : print("not");

    try{
      if(detect==true){
        start2();

        //String localDpPath = "assets/316698392_883976849269816_1135447483350734514_n.jpg";
        //matchFaces(localDpPath!, image!.path);
        // while(_similarity=="nil"){
        //   //print("x");
        // }
        // print(_similarity);
        // if(_similarity!="error"){
        //   print("errorr");
        //   yes = false;
        // }
        // else{
        //   print("Correct");
        // }
        // if(yes == false){
        //   timer?.cancel();
        //   Navigator.of(context).pop();
        // }

        //bool result = ((_similarity != "nil") && (_similarity != "error")) ? true : false;
        // if (res!){
        //   print("matched");
        // }
        // else{
        //   print("unmatched");
        //   timer?.cancel();
        //   Navigator.of(context).pop();
        //
        // }
      }
      else{
        print("no entry!");
        timer?.cancel();
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Text("Error"),
                content: Text("User mismatched!\nTry Again"),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>loginWithGoogle()
                      )),
                      child: Text("Retry"))
                ],
              ),
        );
        // await FirebaseAuth.instance.signOut();
        //
        // await GoogleSignIn().signOut();
        // Navigator.push(context, MaterialPageRoute(
        //     builder: (context)=>loginWithGoogle()
        // ));

      }
    }on Exception{
      timer?.cancel();
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("Error"),
              content: Text("User mismatched!\nTry Again"),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (context)=>loginWithGoogle()
                    )),
                    child: Text("Retry"))
              ],
            ),
      );
    }
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
    image1 = new Regula.MatchFacesImage();
    image2 = new Regula.MatchFacesImage();
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
    print("inside- yes");
    setState(() => _similarity = "nil");
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
            : "error"

        );
        print("Face match: " + _similarity);
        if(_similarity=="error"){
          timer?.cancel();
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
                  title: Text("Error"),
                  content: Text("User mismatched!\nTry Again"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(
                            builder: (context)=>loginWithGoogle()
                        )),
                        child: Text("Retry"))
                  ],
                ),
          );
        }
        if(_similarity.endsWith("%")){
          start();
        }
        //clearResults();
      });
    });
    print("exitss");
  }
  void fun(){
    print("come");
    timer?.cancel();
    Navigator.of(context).pop();
  }
  clearResults() {
    // setState(() {
    //   _similarity = "nil";
    // });

  }


}

class Demo extends StatelessWidget {
  final String dpPath;
  const Demo({required this.dpPath});
  build(context) {
    return Container(
      margin: EdgeInsets.only(bottom: 0, right: 0),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Container(
                width: 110,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black),
                ),
                // margin: EdgeInsets.only(bottom: 30),
                child: Square(dpPath: dpPath,),
              ),
            ),
          ),
          // Square(),
        ],
      ),
    );
  }
}











// pdf viewer
class PdfViewerPage extends StatefulWidget {
  final String pdfPath;
  //const PdfViewerPage(this.pdfPath, {super.key});
  PdfViewerPage({Key? key, required this.pdfPath} ) : super(key: key);

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  // final String? pdfPath;
  // _PdfViewerPageState(this.pdfPath);
  String? localPath;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // localPath = pdfPath;
    //
    // //ApiServiceProvider.loadPDF().then((value) {
    //   setState(() {
    //     localPath = value;
    //   });
    // });
    setState(() {
      localPath = widget.pdfPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Viewer",style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: localPath != null
          ? PDFView(
        filePath: localPath,
      )
          : Center(child: CircularProgressIndicator()),
    );
  }

}