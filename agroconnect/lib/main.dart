import 'package:agroconnect/pages/main_navigation.dart';
import 'package:agroconnect/services/dummy_messages.data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:agroconnect/services//dummy_product_data.dart';

import 'logic/cart_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //initializeDummyData();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
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
      ),
    );
  }
}

//inicializar dummy data
Future<void> initializeDummyData() async {
  print('Initializing dummy data...');

  try {
    // Initialize and save product data
    //final dummyProducts = DummyProductData();
    //await dummyProducts.saveProductsToFirebase();
    //print('✅ Products saved successfully');

    //final dummyMessages = DummyMessagesData();
    //await dummyMessages.saveMessagesToFirebase();

    print('🎉 All dummy data initialized successfully!');
  } catch (e) {
    print('❌ Error initializing dummy data: $e');
  }
}