import 'dart:io';
import 'package:flutter/material.dart';
import 'package:agroconnect/models/product_categories_enum.dart';
import 'package:agroconnect/logic/minha_banca_service.dart';
import 'package:agroconnect/models/product_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool _isCreating = false;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  void _createProduct() async {
    // Validação básica
    if (_productNameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _originController.text.isEmpty ||
        _unitPriceController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _deliveryTimeController.text.isEmpty ||
        _productRadiusController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria')),
      );
      return;
    }

    // Conversão de valores
    double unitPrice;
    int quantity;
    int deliveryTime;
    double productRadius;

    try {
      unitPrice = double.parse(_unitPriceController.text);
      quantity = int.parse(_quantityController.text);
      deliveryTime = int.parse(_deliveryTimeController.text);
      productRadius = double.parse(_productRadiusController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valores numéricos inválidos')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      double totalPrice = unitPrice * quantity;

      final newProduct = ProductModel(
        null, // ID será gerado automaticamente
        user.uid,
        _productNameController.text,
        _selectedImagePath ?? '', // Usar caminho da imagem ou string vazia
        _descriptionController.text,
        _originController.text,
        unitPrice,
        quantity,
        totalPrice,
        deliveryTime,
        0.0, // Rating inicial
        productRadius,
        0, // Review count inicial
        0.0, // Total rating inicial
        _selectedCategory!,
        null, // Expiration date será gerado automaticamente
      );

      // Adicionar produto via serviço
      final minhaBancaService = Provider.of<MinhaBancaService>(
        context,
        listen: false,
      );

      final success = await minhaBancaService.addProduct(newProduct);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto criado com sucesso!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao criar produto')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
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
      body: _isCreating
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container da imagem do produto
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
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
                  child: _selectedImagePath != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_selectedImagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
                  )
                      : Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Clique para adicionar imagem',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Campo de nome do produto
              _buildTextField(
                'Digite o nome do produto',
                'Nome do produto',
                _productNameController,
              ),

              const SizedBox(height: 16),

              // Campo Descrição
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Descrição',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.help_outline,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Barra de ferramentas de formatação
                    Row(
                      children: [
                        _buildFormatButton('B', true),
                        const SizedBox(width: 8),
                        _buildFormatButton('I', false),
                        const SizedBox(width: 8),
                        _buildFormatButton('U', false),
                        const SizedBox(width: 8),
                        _buildFormatButton('S', false),
                        const SizedBox(width: 16),
                        Icon(Icons.link, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 12),
                        Icon(Icons.format_align_left, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Icon(Icons.format_align_center, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Icon(Icons.format_align_right, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 12),
                        Icon(Icons.format_list_bulleted, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Icon(Icons.more_horiz, size: 20, color: Colors.grey[600]),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Campo de texto
                    Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'Digite a descrição do produto...',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Campo Origem
              _buildTextField(
                'Digite a origem do produto',
                'Origem',
                _originController,
              ),

              const SizedBox(height: 16),

              // Campo Preço Unitário
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _unitPriceController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0,00',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          labelText: 'Preço Unitário',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Campo Quantidade
              _buildNumberField(
                'Quantidade',
                'Ex: 10',
                _quantityController,
                Icons.inventory_2_outlined,
              ),

              const SizedBox(height: 16),

              // Campo Tempo de Entrega
              _buildNumberField(
                'Tempo de Entrega (dias)',
                'Ex: 3',
                _deliveryTimeController,
                Icons.schedule,
              ),

              const SizedBox(height: 16),

              // Campo Raio do Produto
              _buildNumberField(
                'Raio de Entrega (KM)',
                'Ex: 15',
                _productRadiusController,
                Icons.location_on_outlined,
              ),

              const SizedBox(height: 16),

              // Dropdown Categoria do Produto
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                child: Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ProductCategoriesEnum>(
                          value: _selectedCategory,
                          hint: const Text(
                            'Selecione a categoria',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          isExpanded: true,
                          items: ProductCategoriesEnum.values.map((category) {
                            return DropdownMenuItem<ProductCategoriesEnum>(
                              value: category,
                              child: Text(
                                _getCategoryDisplayName(category),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
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
              ),

              const SizedBox(height: 40),

              // Botão Criar Produto
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _createProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
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

  Widget _buildNumberField(String label, String hint, TextEditingController controller, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                labelText: label,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatButton(String text, bool isActive) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isActive ? Colors.grey[300] : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  String _getCategoryDisplayName(ProductCategoriesEnum category) {
    switch (category) {
      case ProductCategoriesEnum.frutas:
        return 'Frutas';
      case ProductCategoriesEnum.vegetais:
        return 'Vegetais';
      case ProductCategoriesEnum.cereais:
        return 'Cereais';
      case ProductCategoriesEnum.cabazes:
        return 'Cabazes';
      case ProductCategoriesEnum.sazonais:
        return 'Sazonais';
      default:
        return category.toString().split('.').last;
    }
  }
}