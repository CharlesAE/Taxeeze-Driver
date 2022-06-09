import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/car.dart';
import '../models/driver.dart';
import '../util/global.dart';
//import '../models/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  get uid => null;

  // get user details

  Future<Driver?> getUserDetails() async {

    if(_auth.currentUser  != null) {
      currentFirebaseUser = _auth.currentUser!;

      //get document snapshot from firebase
      DocumentSnapshot documentSnapshot =
      await _firestore.collection('drivers').doc(currentFirebaseUser!.uid).get();
      //covert to user model
      //print(currentUser);
      return Driver.fromFirestore(documentSnapshot);
    }
    return null;

  }

  Future<String?> saveCarInfo({
    required String car_color,
    required String car_number,
    required String car_model,
    required String type
}) async {
    String res = "Some error Occurred";
    try {
      if (fAuth.currentUser != null) {

        Car _car = Car(car_color: car_color, car_number: car_number, car_model: car_model, type: type);

        // adding user in our database
        await _firestore
            .collection("vehicles")
            .doc(fAuth.currentUser!.uid)
            .set(_car.toJson());
        res = "success";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> signUpUser({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          name.isNotEmpty ||
          phone.isNotEmpty) {
        // registering user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );


        currentFirebaseUser = cred.user;
        Driver _driver = Driver(name: name, uid: cred.user!.uid, email: email, phone: phone);

        // adding user in our database
        await _firestore
            .collection("drivers")
            .doc(cred.user!.uid)
            .set(_driver.toJson());

        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "An error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        final User? firebaseUser = (await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).user;
        if(firebaseUser != null) {
          res = "success";
          currentFirebaseUser = firebaseUser;
        }

      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }






}
