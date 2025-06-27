import 'package:flutter/material.dart';
import 'package:agroconnect/models/product_categories_enum.dart';
import 'package:agroconnect/models/product_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAdScreen extends StatefulWidget {
  const CreateAdScreen({Key? key}) : super(key: key);

  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _deliveryTimeController = TextEditingController();
  final TextEditingController _productRadiusController = TextEditingController();

  ProductCategoriesEnum? _selectedCategory;
  String? _selectedImagePath;
  bool _isLoading = false;

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _originController.dispose();
    _unitPriceController.dispose();
    _quantityController.dispose();
    _deliveryTimeController.dispose();
    _productRadiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Criar Produto',
          style: GoogleFonts.kanit(
            color: Color.fromRGBO(84, 157, 115, 1.0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color.fromRGBO(84, 157, 115, 1.0),),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  // TODO: Adicionar funcionalidade de seleção de imagem
                },
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _selectedImagePath != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      _selectedImagePath!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adicionar Foto do Produto',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildTextField(
                'Nome do Produto',
                'Ex: Tomates Frescos',
                _productNameController,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                'Descrição',
                'Descreva seu produto...',
                _descriptionController,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                'Origem',
                'Ex: Quinta da Serra, Minho',
                _originController,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      'Preço por Kg',
                      'Ex: 2.50',
                      _unitPriceController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField(
                      'Quantidade (Kg)',
                      'Ex: 50',
                      _quantityController,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      'Tempo de Entrega (dias)',
                      'Ex: 2',
                      _deliveryTimeController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField(
                      'Raio de Entrega (Km)',
                      'Ex: 15',
                      _productRadiusController,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categoria',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ProductCategoriesEnum>(
                        value: _selectedCategory,
                        hint: const Text('Selecione uma categoria'),
                        isExpanded: true,
                        items: ProductCategoriesEnum.values.map((category) {
                          return DropdownMenuItem<ProductCategoriesEnum>(
                            value: category,
                            child: Text(_getCategoryDisplayName(category)),
                          );
                        }).toList(),
                        onChanged: (ProductCategoriesEnum? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Criar Produto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  String _getCategoryDisplayName(ProductCategoriesEnum category) {
    switch (category) {
      case ProductCategoriesEnum.vegetais:
        return 'Vegetais';
      case ProductCategoriesEnum.frutas:
        return 'Frutas';
      case ProductCategoriesEnum.cereais:
        return 'Cereais';
      case ProductCategoriesEnum.cabazes:
        return 'Cabazes';
      case ProductCategoriesEnum.sazonais:
        return 'Produtos Sazonais';
    }
  }

  void _createProduct() async {
    if (_productNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira o nome do produto')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma categoria')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final double unitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;
      final int quantity = int.tryParse(_quantityController.text) ?? 0;
      final double totalPrice = unitPrice * quantity;
      final int deliveryTime = int.tryParse(_deliveryTimeController.text) ?? 1;
      final double productRadius = double.tryParse(_productRadiusController.text) ?? 10.0;

      final product = ProductModel(
        null,
        user.uid,
        _productNameController.text.trim(),
        _selectedImagePath ?? 'assets/product-images/default.jpg',
        _descriptionController.text.trim(),
        _originController.text.trim(),
        unitPrice,
        quantity,
        totalPrice,
        deliveryTime,
        0.0,
        productRadius,
        0,
        0.0,
        _selectedCategory!,
        DateTime.now().add(Duration(days: 30)),
      );

      final docRef = await FirebaseFirestore.instance
          .collection('products')
          .add(product.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto criado com sucesso!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar produto: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}