import 'package:flutter/material.dart';
import '../logic/auth_service.dart';
import '../models/client_model.dart';
import '../models/supplier_model.dart';
import 'navigation_client.dart';
import 'navigation_supplier.dart';

enum AccountType { client, supplier }

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  AccountType _selectedAccountType = AccountType.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Criar conta com Firebase Auth
      final userCredential = await _authService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (userCredential?.user != null) {
        final userId = userCredential?.user!.uid;
        final userName = _nameController.text.trim();
        final userEmail = _emailController.text.trim();

        // Criar documento baseado no tipo de conta selecionado
        if (_selectedAccountType == AccountType.client) {
          await _createClientAccount(userId!, userName, userEmail);
          if (mounted) {
            // Navegar para a navegação do cliente
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NavigationClient()),
            );
          }
        } else {
          await _createSupplierAccount(userId!, userName, userEmail);
          if (mounted) {
            // Navegar para a navegação do fornecedor
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NavigationSupplier()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createClientAccount(String userId, String userName, String userEmail) async {
    final client = ClientModel(
      userId: userId,
      name: userName,
      email: userEmail,
      imagePath: '',
      city: '',
      parish: '',
      postalCode: '',
      primaryDeliveryAddress: '',
      createdAt: DateTime.now(),
    );

    await client.createClientDoc(
      userId,
      userName,
      '',
      0.0,
      userEmail,
      null,
      '',
      '',
      '',
      '',
      DateTime.now(),
    );
  }

  Future<void> _createSupplierAccount(String userId, String userName, String userEmail) async {
    final supplier = SupplierModel(
      userId: userId,
      name: userName,
      email: userEmail,
      imagePath: '',
      city: '',
      parish: '',
      postalCode: '',
      primaryDeliveryAddress: '',
      createdAt: DateTime.now(),
    );

    await supplier.createSupplierDoc(
      userId,
      userName,
      '',
      0.0,
      userEmail,
      '',
      '',
      '',
      '',
      '',
      DateTime.now(),
    );
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // Implementar login com Google
      // await _authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Logo/Title
                  const Center(
                    child: Text(
                      'HelloFarmer',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Create account text
                  const Center(
                    child: Text(
                      'Criar uma conta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      'Preencha os dados para se registar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Account Type Selection
                  const Text(
                    'Tipo de Conta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Account type cards
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedAccountType = AccountType.client),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedAccountType == AccountType.client
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: _selectedAccountType == AccountType.client
                                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  size: 40,
                                  color: _selectedAccountType == AccountType.client
                                      ? const Color(0xFF4CAF50)
                                      : Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Cliente',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedAccountType == AccountType.client
                                        ? const Color(0xFF4CAF50)
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Comprar produtos',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _selectedAccountType == AccountType.client
                                        ? const Color(0xFF4CAF50)
                                        : Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedAccountType = AccountType.supplier),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedAccountType == AccountType.supplier
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: _selectedAccountType == AccountType.supplier
                                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.store,
                                  size: 40,
                                  color: _selectedAccountType == AccountType.supplier
                                      ? const Color(0xFF4CAF50)
                                      : Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Fornecedor',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedAccountType == AccountType.supplier
                                        ? const Color(0xFF4CAF50)
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Vender produtos',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _selectedAccountType == AccountType.supplier
                                        ? const Color(0xFF4CAF50)
                                        : Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Nome completo',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o seu nome';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Endereço de email',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o seu email';
                      }
                      if (!value.contains('@')) {
                        return 'Por favor, insira um email válido';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira uma password';
                      }
                      if (value.length < 6) {
                        return 'A password deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Continue button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUpWithEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Criar Conta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Center(
                    child: Text(
                      'ou',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Google sign up button
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signUpWithGoogle,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Image.asset(
                      'assets/icons/google_logo.png',
                      height: 20,
                      width: 20,
                    ),
                    label: const Text(
                      'Continuar com Google',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Apple sign up button
                  OutlinedButton.icon(
                    onPressed: () {
                      // Implementar login com Apple
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(
                      Icons.apple,
                      size: 20,
                      color: Colors.black,
                    ),
                    label: const Text(
                      'Continuar com Apple',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Terms and Privacy
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        const Text(
                          'Ao continuar, concorda com os nossos ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Handle terms tap
                          },
                          child: const Text(
                            'Termos de Serviço',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const Text(
                          ' - ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Handle privacy policy tap
                          },
                          child: const Text(
                            'Política de Privacidade',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}