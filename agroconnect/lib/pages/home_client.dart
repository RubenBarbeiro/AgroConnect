import 'package:flutter/material.dart';
import 'package:agroconnect/pages/mensagens.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  static const primaryGreen = Color(0xFF549D73);
  static const backgroundGrey = Color(0xFFFAFAFA);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              _Header(searchController: _searchController),
              const _FeaturedBanner(),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Categorias'),
              const SizedBox(height: 16),
              const _CategoriesGrid(),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Produtos para si'),
              const SizedBox(height: 16),
              const _ProductsList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _SearchField(controller: searchController),
          ),
          const SizedBox(width: 12),
          _ChatButton(),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _HomePageState.primaryGreen,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Pesquisar Produto',
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.search, color: Colors.white),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Mensagens()),
      ),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: _HomePageState.primaryGreen,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Icon(
          Icons.chat_bubble_outline,
          color: Colors.white,
          size: 24,
        ),
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
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Cenouras de',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'alta qualidade',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.agriculture,
                size: 50,
                color: Colors.white70,
              ),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) => _CategoryCard(category: _categories[index]),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Icon(
              category.icon,
              color: _HomePageState.primaryGreen,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: const TextStyle(
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
    );
  }
}

class _ProductsList extends StatelessWidget {
  const _ProductsList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _ProductCard(product: _products[0]),
          const SizedBox(width: 16),
          _ProductCard(product: _products[1]),
          const SizedBox(width: 16),
          _ProductCard(product: _products[2]),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
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
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: product.color.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          product.imageUrl,
          width: double.infinity,
          height: 160,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _ProductImageFallback(product: product),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return _ProductImageLoading(color: product.color);
          },
        ),
      ),
    );
  }
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: product.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            product.icon,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImageLoading extends StatelessWidget {
  const _ProductImageLoading({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.farmName,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            product.price,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Data models
class Category {
  final String name;
  final IconData icon;

  const Category(this.name, this.icon);
}

class Product {
  final String name;
  final String farmName;
  final String price;
  final String imageUrl;
  final Color color;
  final IconData icon;

  const Product({
    required this.name,
    required this.farmName,
    required this.price,
    required this.imageUrl,
    required this.color,
    required this.icon,
  });
}

// Sample data
const _categories = [
  Category('Pêras', Icons.apple),
  Category('Melancias', Icons.circle),
  Category('Cabazes', Icons.shopping_basket),
  Category('Batata', Icons.circle_outlined),
];

const _products = [
  Product(
    name: 'Bananas',
    farmName: 'Quinta do Tio Manel',
    price: '€10',
    imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=300&fit=crop',
    color: Color(0xFFFFEB3B),
    icon: Icons.breakfast_dining,
  ),
  Product(
    name: 'Batatas',
    farmName: 'BioFarm',
    price: '€5.99',
    imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&h=300&fit=crop',
    color: Color(0xFF8D6E63),
    icon: Icons.circle,
  ),
  Product(
    name: 'Cebolas',
    farmName: 'BioFruit',
    price: '€10.5',
    imageUrl: 'https://images.unsplash.com/photo-1508313880080-c4bec5d99c40?w=400&h=300&fit=crop',
    color: Color(0xFF9C27B0),
    icon: Icons.circle_outlined,
  ),
];