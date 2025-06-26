import 'package:agroconnect/pages/main_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:google_sign_in/google_sign_in.dart';

import '../pages/home_client.dart';
import '../pages/login.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> isUserSupplier(String userId) async {
    try {
      DocumentSnapshot supplierDoc = await _firestore
          .collection('suppliers')
          .doc(userId)
          .get();

      if (supplierDoc.exists) return true;

      DocumentSnapshot clientDoc = await _firestore
          .collection('clients')
          .doc(userId)
          .get();

      if (clientDoc.exists) {
        Map<String, dynamic>? data = clientDoc.data() as Map<String, dynamic>?;
        return data?['isSupplier'] ?? false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  Future<UserCredential?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Erro ao fazer logout: $e';
    }
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este email já está em uso.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      case 'invalid-email':
        return 'Email inválido.';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: authService.isUserSupplier(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (roleSnapshot.hasError) {
                return const MainNavigation();
              } else {
                bool isSupplier = roleSnapshot.data ?? false;
                return isSupplier ? const MainNavigation() : const MainNavigation();
              }
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}