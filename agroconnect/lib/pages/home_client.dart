import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agroconnect/pages/mensagens.dart';
import 'package:agroconnect/pages/client_product.dart';
import 'package:agroconnect/models/product_model.dart';
import 'package:agroconnect/models/product_categories_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final Function(String)? onCategoryTap;

  const HomePage({super.key, this.onCategoryTap});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ProductModel> _products = [];
  bool _isLoading = true;

  static const primaryGreen = Color(0xFF549D73);
  static const backgroundGrey = Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('rating', descending: true)
          .limit(10)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(),
              const _FeaturedBanner(),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Categorias'),
              const SizedBox(height: 16),
              _CategoriesGrid(onCategoryTap: widget.onCategoryTap),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Produtos para si'),
              const SizedBox(height: 16),
              _ProductsList(products: _products, isLoading: _isLoading),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _WelcomeMessage()),
          const SizedBox(width: 12),
          _ChatButton(),
        ],
      ),
    );
  }
}

class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _HomePageState.primaryGreen,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(Icons.waving_hand, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Olá!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Bem-vindo de volta ao AgroConnect',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Mensagens(currentUserId: _auth.currentUser!.uid, currentUserType: 'client')),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _HomePageState.primaryGreen,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
      ),
    );
  }
}

class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.orange.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Produtos frescos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'direto do produtor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.agriculture, size: 50, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  final Function(String)? onCategoryTap;

  const _CategoriesGrid({this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: ProductCategoriesEnum.values.length,
        itemBuilder: (context, index) => _CategoryCard(
          category: ProductCategoriesEnum.values[index],
          onTap: onCategoryTap,
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ProductCategoriesEnum category;
  final Function(String)? onTap;

  const _CategoryCard({required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(category.displayName);
        }
      },
      child: Container(
        width: 85,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(category.icon, color: category.color, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              category.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsList extends StatelessWidget {
  const _ProductsList({required this.products, required this.isLoading});

  final List<ProductModel> products;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 280,
        child: Center(
          child: CircularProgressIndicator(color: _HomePageState.primaryGreen),
        ),
      );
    }

    if (products.isEmpty) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Nenhum produto encontrado',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 320,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.only(right: index < products.length - 1 ? 16 : 0),
          child: _ProductCard(product: products[index]),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
      ),
      child: Container(
        width: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImage(product: product),
            _ProductInfo(product: product),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: product.productCategory.color.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: _ProductImageFallback(product: product),
      ),
    );
  }
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: product.productCategory.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(product.productCategory.icon, size: 48, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            product.productName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.origin,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.productName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${product.unitPrice.toStringAsFixed(2)}€',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _HomePageState.primaryGreen,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 12, color: Colors.orange),
                    const SizedBox(width: 2),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}