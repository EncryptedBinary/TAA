import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_file/open_file.dart';
import 'package:projecttaa/pdfviewer.dart';
import 'FaceApi.dart';
import 'FileEncryptionApi.dart';
import 'GoogleAuthClient.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'package:path/path.dart' as p;

import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart' ;

import 'ImageToPdfConverter.dart';
import 'login.dart';
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter_face_api/face_api.dart' as Regula;
import 'dart:typed_data';

class ViewFile extends StatefulWidget {
  final String dpPath;
  ViewFile({Key? key, required this.dpPath}) : super(key: key);
  @override
  ViewFileState createState() => ViewFileState();
}

const _folderType = "application/vnd.google-apps.folder";

class ViewFileState extends State<ViewFile> {

  final googleSignIn = GoogleSignIn.standard(scopes: [
    //drive.DriveApi.driveAppdataScope,
    drive.DriveApi.driveFileScope,
    // drive.DriveApi.driveReadonlyScope
  ]);

  //drive.FileList? file;
  bool isStart = false;
  dynamic file;
  String storedPath = "";

  String? localDpPath;
  String? pdfPath;
  bool isLoading=false;
  bool jpg = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
              "Select File to view      "),
        ),
        backgroundColor: Colors.redAccent,
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
      body: isStart ?
      ListView.builder(
        itemCount: file.length,
        itemBuilder: (context, index) {
          final isFolder = file[index].mimeType == _folderType;
          return ListTile(
            onTap: () {
              _downloadGoogleDriveFile(
                  file[index].name.toString(), file[index].id.toString());
              showDialog(
                  context: context,
                  builder: (context){
                    return Center(child: CircularProgressIndicator());

                  });
            },
            leading: Icon(isFolder
                ? Icons.folder
                : Icons.insert_drive_file_outlined),
            //subtitle: Text(file[index].fullFileExtension ?? ""),
            title: Text(file[index].name ?? ""),
          );
        },
      )
          : Center(child: Text("Please Wait....",style: TextStyle(color: Colors.redAccent, fontSize: 24),)),
    );
  }


  Future<drive.FileList> _filesInFolder(drive.DriveApi driveApi) async {
    final folderId = await _getFolderId(driveApi, "The Amazing App");
    return driveApi.files.list(
      spaces: 'drive',
      q: "'$folderId' in parents",
    );
  }


  Future<drive.DriveApi?> _getDriveApi() async {
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    print("User account $account");
    final authHeaders = await account?.authHeaders;

    var client = await GoogleAuthClient(authHeaders!);
    var driveApi = drive.DriveApi(client);
    return driveApi;
  }

  Future<String?> _getFolderId(drive.DriveApi driveApi,
      String folderName,) async {
    try {
      final found = await driveApi.files.list(
        q: "mimeType = '$_folderType' and name = '$folderName'",
        $fields: "files(id)",
      );
      final files = found.files;
      if (files == null) {
        return null;
      }

      if (files.isNotEmpty) {
        return files.first.id;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
  void initState() {
    setState(() {
      localDpPath = widget.dpPath;
    });
    starting(_filesInFolder);
    super.initState();
  }

  void starting(Function(drive.DriveApi driveApi) query) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) {
      return;
    }

    final fileList = await query(driveApi);
    final files = fileList.files;
    if (files == null) {
      return;
    }
    file = files;
    setState(() {
      isStart = true;
    });
  }

  Future<void> _downloadGoogleDriveFile(String fName, String gdID) async {
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    print("User account $account");
    final authHeaders = await account?.authHeaders;
    //final authHeaders = await googleSignInAccount?.authHeaders;
    var client = await GoogleAuthClient(authHeaders!);
    var driveApi = drive.DriveApi(client);
    drive.Media? file = await driveApi.files.get(
        gdID, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media?;
    // print(file.stream);

    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    final saveFile = File('${directory.path}/$fName');
    List<int> dataStore = [];
    file?.stream.listen((data) {
      print("DataReceived: ${data.length}");
      dataStore.insertAll(dataStore.length, data);
    }, onDone: () {
      Navigator.of(context).pop();
      print("Task Done");
      saveFile.writeAsBytes(dataStore);
      print("File saved at ${saveFile.path}");
      storedPath = saveFile.path;
      _decryptFile();
    }, onError: (error) {
      print("Some Error");
    });
  }

  Future<Uint8List> _readData(String path) async {
    print("reading");
    File f = File(path);
    return await f.readAsBytes();
  }

  Future<String> _writeData(data, path) async {
    print("writing");
    File f = File(path);
    print(f.path);
    await f.writeAsBytes(data);
    final extension = p.extension(path);
    String? convertedPath;
    if(extension != ".pdf"){
      print("yesnopdf");
      convertedPath = ImageToPdf().come(f.absolute.path).toString();
      print(convertedPath);
      jpg= true;
    }


    // showDialog(
    //     context: context,
    //     builder: (context){
    //       return Center(child: CircularProgressIndicator());
    //
    //     });

    //OpenFile.open(f.path);
    //CameraAppTest(f.absolute.path);
    setState(() async {
      if(jpg){
        pdfPath = convertedPath;
        setState(() {
          jpg = false;
        });
      }
      else{
        pdfPath = f.absolute.path;
      }

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
      //bool result = ((_similarity != null) || (_similarity != "nil") || (_similarity != "error")) ? true : false;


    });
    return f.absolute.toString();
  }

  void _decryptFile() async {
    Uint8List encData = await _readData(storedPath);
    var plainData = FileEcryptionApi.decryptFile(encData);
    var write = await _writeData(plainData, storedPath);


    print("Wrote: " + write);
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
          Navigator.push(context, MaterialPageRoute(
              builder: (context)=>CameraAppTest(pdfPath: pdfPath!,dpPath: widget.dpPath,)));
        }
      });
    });
  }
}