import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String vehicleNumber = "";
  String subLocationId = "";
  String divisionsId = "";
  String divisionsName = "";
  String subLocationName = "";

  void setUser({
    required String vehicleNumber,
    required String subLocationId,
    required String divisionsId,
    required String divisionsName,
    required String subLocationName,
  }) {
    this.vehicleNumber = vehicleNumber;
    this.subLocationId = subLocationId;
    this.divisionsId = divisionsId;
    this.divisionsName = divisionsName;
    this.subLocationName = subLocationName;
    notifyListeners(); // Notify UI of changes
  }
}
