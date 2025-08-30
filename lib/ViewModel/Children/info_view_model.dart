import 'package:flutter/material.dart';
import 'package:youseuf_app/models/child.dart';

class InfoViewModel extends ChangeNotifier {
  Child? child;
  bool isLoading = false;

  void setChildData(Child newChild) {
    child = newChild;
    notifyListeners();
  }
}
