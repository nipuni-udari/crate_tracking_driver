import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String vehicleNumber = "";
  String subLocationId = "";
  String divisionsId = "";
  String divisionsName = "";
  String subLocationName = "";
  //String vehicleId = "";

  void setUser({
    required String vehicleNumber,
    required String subLocationId,
    required String divisionsId,
    required String divisionsName,
    required String subLocationName,
    // required String vehicleId,
  }) {
    this.vehicleNumber = vehicleNumber;
    this.subLocationId = subLocationId;
    this.divisionsId = divisionsId;
    this.divisionsName = divisionsName;
    this.subLocationName = subLocationName;
    // this.vehicleId = vehicleId;
    notifyListeners(); // Notify UI of changes
  }
}
