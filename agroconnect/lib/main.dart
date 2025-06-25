import 'package:agroconnect/pages/navigation_supplier.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Farmer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              centerTitle: true,
              titleTextStyle: GoogleFonts.kanit(
                  color: Color.fromRGBO(84, 157, 115, 1.0),
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              )
          )
      ),
      home: MainNavigation(),
    );
  }
}