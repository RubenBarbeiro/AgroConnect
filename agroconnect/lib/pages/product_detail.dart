import 'package:flutter/material.dart';
import 'package:agroconnect/models/product_model.dart';
import 'package:agroconnect/models/product_categories_enum.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Voltar',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 250,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getProductImageColor(),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.product.productCategory.icon,
                  size: 80,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.product.productName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            SizedBox(height: 8),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.product.origin,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            SizedBox(height: 24),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações do Produto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow('Preço', '${widget.product.unitPrice.toStringAsFixed(2)}€/Kg'),
                  _buildInfoRow('Quantidade Disponível', '${widget.product.quantity} kg'),
                  _buildInfoRow('Tempo de Entrega', '${widget.product.deliveryTime} dias'),
                  _buildInfoRow('Avaliação', '${widget.product.rating}/5.0 ⭐'),
                ],
              ),
            ),

            if (widget.product.description.isNotEmpty) ...[
              SizedBox(height: 24),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descrição',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      widget.product.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProductImageColor() {
    switch (widget.product.productCategory) {
      case ProductCategoriesEnum.vegetais:
        return Colors.green.shade300;
      case ProductCategoriesEnum.frutas:
        return Colors.orange.shade300;
      case ProductCategoriesEnum.cereais:
        return Colors.amber.shade300;
      case ProductCategoriesEnum.cabazes:
        return Colors.brown.shade300;
      case ProductCategoriesEnum.sazonais:
        return Colors.deepOrange.shade300;
      default:
        return Colors.grey.shade300;
    }
  }
}