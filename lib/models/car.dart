
import 'package:cloud_firestore/cloud_firestore.dart';

class Car{
  String? id;
  String? car_color;
  String? car_number;
  String? car_model;
  String? type;


  Car({
    this.id,
    this.car_color,
    this.car_number,
    this.car_model,
    this.type
  });


  Car.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    id = snapshot.id; //data['id'];
    car_color = data['car_color'];
    car_number = data['car_number'];
    car_model = data['car_model'];
    type = data['type'];
  }

  static Car fromFirestore(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Car(
        car_color : snapshot['car_color'],
        car_number : snapshot['car_number'],
        car_model : snapshot['car_model'],
        type : snapshot['type']);
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'car_color': car_color, 'car_number': car_number, 'car_model': car_model, 'type': type};
}