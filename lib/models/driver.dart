
import 'package:cloud_firestore/cloud_firestore.dart';

class Driver{
  String? uid;
  String? name;
  String? email;
  String? phone;


  Driver({
    this.uid,
    this.name,
    this.email,
    this.phone
  });


  Driver.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    uid = snapshot.id; //data['id'];
    name = data['name'];
    email = data['email'];
    phone = data['phone'];
  }

  static Driver fromFirestore(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Driver(
        name: snapshot["name"],
        uid: snapshot["uid"],
        email: snapshot["email"],
        phone: snapshot["phone"]);
  }

  Map<String, dynamic> toJson() =>
      {'uid': uid, 'name': name, 'email': email, 'phone': phone};
}