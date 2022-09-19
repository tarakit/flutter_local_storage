import 'package:local_storage/utils/DatabaseHelper.dart';

class Car {
  int? id;
  String? name;
  int? miles;

  Car({this.id, this.name, this.miles});
 // Named Constructor
  Car.fromMap(Map<String, dynamic> map){
    id = map['id'];
    name = map['name'];
    miles = map['miles'];
  }

  Map<String, dynamic> toMap(){
    return {
      DataBaseHelper.columnId : id,
      DataBaseHelper.columnName : name,
      DataBaseHelper.columnMiles : miles
    };
  }
}