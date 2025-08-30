
import 'package:flutter/material.dart';
import 'package:youseuf_app/View/widget/Specialist/bottom_navigation_bar.dart';

class MainScreen extends StatelessWidget {
  final String type; // children | children_and_reports

  const MainScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: 
      
      BottomNavigationWidget(type: type),
    );
  }
}
