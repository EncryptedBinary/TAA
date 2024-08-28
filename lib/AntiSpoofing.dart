import 'dart:io';
import 'package:tflite/tflite.dart';

class antiSpoofing{
  // late String path;
  // antiSpoofing(this.path);
  late File _image;
  late List _results;
  bool imageSelect=false;

  //@override
  // void initState()
  // {
  //   loadModel();
  // }
  Future loadModel()
  async {
    Tflite.close();
    String res;
    res=(await Tflite.loadModel(model: "image/model.tflite",
        labels: "image/labels.txt"))!;
    print("Models loading status: $res");
  }

  Future<bool> imageClassification(String path)
  async {
    loadModel();
    _image = File(path);
    final List? recognitions = await Tflite.runModelOnImage(
      path: _image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    // setState(() {
    _results=recognitions!;
    // _image=image;
    // imageSelect=true;
    //});
    print("Image Condition: "+ recognitions[0]['label']);
    if(recognitions[0]['label']=="0 Real"){
      print("True");
      return true;
    }
    return false;
  }
}