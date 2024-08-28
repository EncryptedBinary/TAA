import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

class FileEcryptionApi {

  static final key = Key.fromUtf8("1234567890987654");
  static final iv = IV.fromUtf8("0987654321234567");
  static Future<Uint8List?> encryptFile(data) async {
    final key = FileEcryptionApi.key;
    final iv = FileEcryptionApi.iv;
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    final encryptedFile = encrypter.encryptBytes(data, iv: iv);
    return encryptedFile.bytes;
  }
  static List<int> decryptFile(data) {
    print("dec");
    final key = FileEcryptionApi.key;
    final iv = FileEcryptionApi.iv;
    Encrypted en = Encrypted(data);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    return encrypter.decryptBytes(en, iv: iv);
  }
}