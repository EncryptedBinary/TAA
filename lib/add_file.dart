import 'package:file_saver/file_saver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:http/io_client.dart';
import 'package:projecttaa/homepage.dart';

import 'FaceApi.dart';
import 'FileEncryptionApi.dart';
import 'GoogleAuthClient.dart';
import 'login.dart';
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter_face_api/face_api.dart' as Regula;
import 'dart:typed_data';


class AddFile extends StatefulWidget {
  final String dpPath;
  AddFile({Key? key, required this.dpPath}) : super(key: key);

  @override
  _AddFileState createState() => _AddFileState();
}

class _AddFileState extends State<AddFile> {
  bool? isAddFileTapped;
  bool? isViewFileTapped;
  String? localDpPath;
  bool? res;
  bool isEncrypting = false;
  FilePickerResult? result;
  String? _fileName;
  PlatformFile? pickedfile;
  bool isLoading = false;
  File? doc;
  File? newFile;
  bool encrypted = false;


  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    setState(() {
      localDpPath = widget.dpPath;
      isAddFileTapped = false;
      isViewFileTapped = false;
      res = false;
    });
  }

  void pickFile() async{
    try{
      setState(() {
        isLoading=true;
      });
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if(result!=null){
        _fileName= result!.files.first.name;
        pickedfile=result!.files.first;
        doc =File(pickedfile!.path.toString());

        print('File Name $_fileName');
      }
      setState(() {
        isLoading=false;
      });
    }catch(e){
      print(e);
    }
  }
  Future<String> get _directoryPath async {
    Directory? directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<File> get _file async {
    final path = await _directoryPath;
    return File('$path/${_fileName!}.aes');
  }
  //String userEmail = "";
  @override
  Widget build(BuildContext context) {
    //   return Scaffold(
    //       backgroundColor: Colors.white,
    //       appBar: AppBar(
    //         title: Center(
    //           child: Text(
    //               "Select to view decrypted file          "),
    //         ),
    //         backgroundColor: Colors.redAccent,
    //       ),
    //       body: Container(
    //         child: TextButton(
    //           onPressed: (){
    //             pickFile();
    //             if(doc!=null)
    //            // var file = FilePicker.platform.pickFiles();
    //               _incrementCounter(doc);
    //           }, child: Text('Go to google Drive'),
    //         ),
    //       )
    //   );
    // }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
              "Add file to encrypt and store      "),
        ),
        backgroundColor: Colors.purpleAccent,
        elevation: 35,
        actions: <Widget>[
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                await GoogleSignIn().signOut();
                Navigator.push(context, MaterialPageRoute(
                    builder: (context)=>loginWithGoogle()
                ));
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Center(
          //   child: isLoading
          //       ?CircularProgressIndicator()
          //       : TextButton(onPressed: (){
          //     pickFile();
          //   }, child: Text('Pick File') ,
          //   ),
          // ),
          Spacer(),
          if(pickedfile!=null)
            SizedBox(
              height: 300,width: 400,
              child:encrypted==false
                  ?Text("Picked File: "+ _fileName!+"\nThe Extension of the file is: " +
                  pickedfile!.extension.toString(),style: TextStyle(color: Colors.black,
                  fontSize: 24, fontWeight: FontWeight.bold),)
                  : Text("Your file has been Encrypted \nand saved in google drive",
                style: TextStyle(color: Colors.green,
                    fontSize: 30, fontWeight: FontWeight.bold),),
            ),
          //if(pickedfile == null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: encrypted == false ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.purpleAccent,
                textStyle: TextStyle(fontSize: 24),
                minimumSize: Size.fromHeight(54),
                shape: StadiumBorder(),
              ),
              onPressed: () async {


                final imagePathforverification = await Navigator.push(context, MaterialPageRoute(
                    builder: (context)=>faceApi()));
                //check spoof
                //match image
                matchFaces(localDpPath!, imagePathforverification);
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
                // ScaffoldMessenger.of(context).showSnackBar(
                //      SnackBar(
                //         content:
                //              isLoading == true  ? Text(
                //             "Please wait Verifying Image...."
                //         ) : Text(
                //                  "Image Verified!")
                //     )
                // );



                //if matches result = true
                //res = ((_similarity != null) || (_similarity != "nil") || (_similarity != "error")) ? true : false;

                // setState(() {
                // });
                // if(res==true) {
                //   pickFile();
                // }
                // else{
                //
                // }
              }, child:  Text("Pick File"),)
                :ElevatedButton(
                      style: ElevatedButton.styleFrom(
                      primary: Colors.purpleAccent,
                      textStyle: TextStyle(fontSize: 24),
                      minimumSize: Size.fromHeight(54),
                      shape: StadiumBorder(),
                      ), onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context)=>homepage(dpPath: widget.dpPath,)));
            }, child: Text("Go back!"),)
          ),

          SizedBox(height: 5,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:pickedfile!=null && encrypted ==false
                ?ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.purpleAccent,
                  textStyle: TextStyle(fontSize: 24),
                  minimumSize: Size.fromHeight(54),
                  shape: StadiumBorder(),
                ),
                onPressed: () async{
                  // final imagePathforverification = await Navigator.push(context, MaterialPageRoute(
                  //     builder: (context)=>faceApi()));
                  // //check spoof
                  // //match image
                  // matchFaces(localDpPath!, imagePathforverification);
                  //
                  // //if matches result = true
                  // res = ((_similarity != null) || (_similarity != "nil") || (_similarity != "error")) ? true : false;


                  setState(() {
                    isEncrypting = true;
                  });
                  final result = await FileEcryptionApi.encryptFile(
                      doc!.readAsBytesSync());
                  File f =  File('${await _directoryPath}/$_fileName');
                  f.writeAsBytesSync(result!);
                  _incrementCounter(f);

                  //_incrementCounter();
                  // await FileSaver.instance.saveAs(
                  //     _fileName!,
                  //     result!, "jpg",
                  //     MimeType.OTHER).whenComplete(() {
                  //   isEncrypting = false;
                  //   newFile = doc;
                  //
                  //   print("encrypted: "+ newFile!.path);
                  // }
                  // );
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              "Successfilly encrypted!"
                          )
                      )
                  );
                }, child: isEncrypting
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                const SizedBox(width: 20,),
                Text("Please wait...."),
              ],
            )
                : Text("Encrypt file")
              // ? const Text("Encrypting...")
              // : const Text("Encrypt Doc")
            )
            : pickedfile == null ? Text("No file has been selected!")
                : Text("Encrypted file stored!"),
          ),
          // TextButton(
          //     onPressed: (){
          //       // print("file_path: "+);
          //       //print("file_name: "+ _fileName!);
          //      // deleteFile();
          //     }, child: Text("DeleteFile"))
          SizedBox(height: 70,)
        ],

      ),
    );
  }
  Future<String?> _getFolderId(ga.DriveApi driveApi) async {
    const mimeType = "application/vnd.google-apps.folder";
    String folderName = "The Amazing App";

    try {
      final found = await driveApi.files.list(
        q: "mimeType = '$mimeType' and name = '$folderName'",
        $fields: "files(id, name)",
      );
      final files = found.files;
      if (files == null) {
        print("Sign-in first Error");
        return null;
      }

      // The folder already exists
      if (files.isNotEmpty) {
        print("exits");
        return files.first.id;
      }

      // Create a folder
      //if(files.isEmpty)
      ga.File folder = ga.File();
      folder.name = folderName;
      folder.mimeType = mimeType;
      final folderCreation = await driveApi.files.create(folder);
      if (kDebugMode) {
        print("Folder ID: ${folderCreation.id}");
      }

      return folderCreation.id;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> _incrementCounter(File? file) async {


    final googleSignIn = GoogleSignIn.standard(scopes: [ga.DriveApi.driveFileScope]);
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    print("User account $account");

    final authHeaders = await account?.authHeaders;
    // final authenticateClient = GoogleAuthClient(authHeaders!);
    // final driveApi = ga.DriveApi(authenticateClient);

    //  final Stream<List<int>> mediaStream = Future.value([104, 105]).asStream();
    //  var media = new Media(mediaStream, 2);
    // // var driveFile = new File();
    // // driveFile.name = "hello_world.txt";
    // // final result = await driveApi.files.create(driveFile, uploadMedia: media);
    // // print("Upload result: $result");
    // File fileToUpload = new File();
    // var file = await FilePicker.platform.pickFiles();
    // fileToUpload.parents = ["appDataFolder"];
    // fileToUpload.name = path.basename(file!.names[0].toString());
    // var response = await driveApi.files.create(
    // fileToUpload,
    // uploadMedia: media,
    // );
    // print(response);

    var client = await GoogleAuthClient(authHeaders!);
    var drive = ga.DriveApi(client);
    String? folderId =  await _getFolderId(drive);
    if(folderId == null){
      print("Sign-in first Error");
    }else {
      ga.File fileToUpload = ga.File();
      fileToUpload.parents = [folderId];
      fileToUpload.name = p.basename(file!.absolute.path);
      var response = await drive.files.create(
        fileToUpload,
        uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
      );
      print(response);
      setState(() {
        isEncrypting = false;
        encrypted = true;
        deleteFile(file);

      });
    }

  }



  // uploadFileToGoogleDrive(File file) async {
  //
  //
  //
  // }

// _uploadFileToGoogleDrive() async {
  //   var client = GoogleAuthClient(await googleSignInAccount.authHeaders);
  //   var drive = DriveApi(client);
  //   File fileToUpload = File();
  //   var file = await .getFile();
  //   fileToUpload.parents = ["appDataFolder"];
  //   fileToUpload.name = path.basename(file.absolute.path);
  //   var response = await drive.files.create(
  //     fileToUpload,
  //     uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
  //   );
  //   print(response);
  //   _listGoogleDriveFiles();
  // }
  //
  // Future<void> _listGoogleDriveFiles() async {
  //   var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
  //   var drive = ga.DriveApi(client);
  //   drive.files.list(spaces: 'appDataFolder').then((value) {
  //     setState(() {
  //       list = value;
  //     });
  //     for (var i = 0; i < list.files.length; i++) {
  //       print("Id: ${list.files[i].id} File Name:${list.files[i].name}");
  //     }
  //   });
  // }
  Future<void> deleteFile(File file) async {
    // File file = await _file;
    // print(file.absolute.path);
    if (await file.exists()) {
      print("deleted");
      await file.delete();

    }
    else print("no files");
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
          setState(() {
            isLoading = false;
          });
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
          setState(() {
            Navigator.of(context).pop();
            isLoading = false;
          });
          pickFile();
        }
      });
    });
  }
}