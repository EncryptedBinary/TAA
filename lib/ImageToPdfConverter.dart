import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageToPdf{
  // ignore: unused_element
  Future<String> _convertImageToPDF(String path) async {

    //Create the PDF document
    PdfDocument document = PdfDocument();

    //Add the page
    PdfPage page = document.pages.add();

    //Load the image
    final PdfImage image =
    PdfBitmap(await _readImageData(path));

    //draw image to the first page
    page.graphics.drawImage(
        image, Rect.fromLTWH(0, 0, page.size.width, page.size.height));

    //Save the document
    List<int> bytes = await document.save();

    // Dispose the document
    document.dispose();

    //Save the file and launch/download
    final storedin = saveAndLaunchFile(bytes, 'output.pdf');
    final extension = p.extension(path);
    print(extension);
    return storedin;
  }

  Future<List<int>> _readImageData(String name) async {
    final ByteData data = await File(name).readAsBytesSync().buffer.asByteData();
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
  Future<String> saveAndLaunchFile(
      List<int> bytes, String fileName) async {
    //Get external storage directory
    Directory directory = await getApplicationSupportDirectory();
    //Get directory path
    String path = directory.path;
    //Create an empty file to write PDF data
    File file = File('$path/${DateTime.now()}$fileName');
    //Write PDF data
    File f = await file.writeAsBytes(bytes, flush: true);

    return f.absolute.path;
    //Open the PDF document in mobile
    //OpenFile.open('$path/$fileName');
  }
  Future<String> come(String path) async {
    return await _convertImageToPDF(path);
  }
}