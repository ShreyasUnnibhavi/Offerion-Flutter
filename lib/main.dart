import 'package:flutter/material.dart';
import 'package:offerion/pages/bottom_nav/bottom_nav.dart';
import 'package:offerion/services/api_service.dart';

final ApiService apiService = ApiService();


void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Rubik',
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.white,
          // showDragHandle: true
        ),
        primaryColor: Color.fromRGBO(220, 53, 69, 1),
        // primaryColor: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: BottomNav(),
    );
  }
}
