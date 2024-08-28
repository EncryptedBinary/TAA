import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_face_api/face_api.dart' as Regula;
import 'package:projecttaa/FaceApi.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class faceApi extends StatefulWidget {
  @override
  _faceApiState createState() => _faceApiState();
}

class _faceApiState extends State<faceApi> {

  var image1 = new Regula.MatchFacesImage();
  var image2 = new Regula.MatchFacesImage();

  String? imagePath;
  var img1 = Image.asset('assets/images/portrait.png');
  var img2 = Image.asset('assets/images/portrait.png');
  File? file;
  String _similarity = "nil";
  String _liveness = "nil";
  bool yes = false;
  setImage(bool first, Uint8List? imageFile, int type) async {
    if (imageFile == null) return;
    //setState(() => _similarity = "nil");
    // if (first) {
    //   image1.bitmap = base64Encode(imageFile);
    //   image1.imageType = type;
    //   // setState(() {
    //   //   img1 = Image.memory(imageFile);
    //   //   _liveness = "nil";
    //   // });
    // } else {
    //   image2.bitmap = base64Encode(imageFile);
    //   image2.imageType = type;
    //  // setState(() => img2 = Image.memory(imageFile));
    // }

    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    File file = await File('${directory.path}/profile.jpg').create();
    print("file in face: ${file.path}");
    file.writeAsBytesSync(imageFile);
    imagePath = file.absolute.path.toString();
    setState(() {
      if(yes) {
        Navigator.of(context).pop(file.absolute.path);
      }
    });
    // if(yes) {
    //   return imagePath;
    // }

    // imagePath = file.path;
    // print("imagePath: "+ file.path);
  }

  // clearResults() {
  //   setState(() {
  //     img1 = Image.asset('assets/images/portrait.png');
  //     img2 = Image.asset('assets/images/portrait.png');
  //     _similarity = "nil";
  //     _liveness = "nil";
  //   });
  //   image1 = new Regula.MatchFacesImage();
  //   image2 = new Regula.MatchFacesImage();
  // }

  matchFaces() {
    if (image1.bitmap == null ||
        image1.bitmap == "" ||
        image2.bitmap == null ||
        image2.bitmap == "") return;
    //setState(() => _similarity = "Processing...");
    var request = new Regula.MatchFacesRequest();
    request.images = [image1, image2];
    Regula.FaceSDK.matchFaces(jsonEncode(request)).then((value) {
      var response = Regula.MatchFacesResponse.fromJson(json.decode(value));
      Regula.FaceSDK.matchFacesSimilarityThresholdSplit(
          jsonEncode(response!.results), 0.75)
          .then((str) {
        var split = Regula.MatchFacesSimilarityThresholdSplit.fromJson(
            json.decode(str));
        // setState(() => _similarity = split!.matchedFaces.length > 0
        //     ? ((split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2) +
        //     "%")
        //     : "error");
      });
    });
  }

  liveness() => Regula.FaceSDK.startLiveness().then((value) {
    var result = Regula.LivenessResponse.fromJson(json.decode(value));
    setImage(true, base64Decode(result!.bitmap!.replaceAll("\n", "")),
        Regula.ImageType.LIVE);
    // if(result.liveness == 0)
    //   {
    //     print("Objectpath");
    //     yes = true;
    //   }
    // else {
    //   yes = false;
    // }

    setState(() => yes = result.liveness == 0 ? true : false);
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Attention'),
      content: const Text('Image verification:\n'
          '1. If you are new take image to create account\n'
          '2. If you already have account then :\n'
          '--> * Take image before adding file\n '
          '--> * Take image before view file\n '),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => liveness(),
          child: const Text('Ok'),
        ),
      ],
    );
  }
//
// Future<String?> function() async{
//   liveness();
//   print(yes);
//   if(yes) {
//     print(yes);
//     return imagePath;
//   }
//   else {
//     return null;
//   }
// }
}
