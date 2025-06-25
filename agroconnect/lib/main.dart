import 'package:agroconnect/pages/avaliacoes_fornecedor.dart';
import 'package:agroconnect/pages/checkout.dart';
import 'package:agroconnect/pages/confir_venda_fornecedor.dart';
import 'package:agroconnect/pages/main_navigation.dart';
import 'package:agroconnect/pages/minha_banca.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:agroconnect/services//dummy_product_data.dart';

import 'logic/cart_state.dart';
import 'logic/counter_minha_banca_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //initializeDummyData();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => CounterMinhaBancaModel()),
      ],

      child: MaterialApp(
        title: 'Hello Farmer',
        initialRoute: '/',
        routes: {
          '/checkout.dart': (context) => CheckoutScreen(),
          //'/avaliacoes_fornecedor': (context) => AvaliacoesFornecedor(),
        },
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
        home: ConfirmacaoVendaFornecedor(),
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