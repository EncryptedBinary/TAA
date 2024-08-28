import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  //late String uid;
  late String fullName;
  late String email;
  late var image_url;

  UserModel({
    //required this.uid,
    required this.fullName,
    required this.email,
    required this.image_url,

  });
  factory UserModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return UserModel(
      // uid: data?['uid'],
      fullName: data?['name'],
      email: data?['email'],
      image_url: data?['image_url'],
      // population: data?['population'],
      // regions:
      // data?['regions'] is Iterable ? List.from(data?['regions']) : null,
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      //"uid": uid,
      "name": fullName,
      "email": email,
      "image_url": image_url,
    };
  }
// static UserModel fromMap(Map<String, dynamic> map) {
//   return UserModel(
//     uid: map['uid'],
//     fullName: map['fullName'],
//     email: map['email'],
//     profileImage: map['profileImage'],
//   );
// }
}