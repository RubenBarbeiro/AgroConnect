import 'package:flutter/material.dart';
import 'package:agroconnect/models/product_model.dart';
import 'package:agroconnect/models/product_categories_enum.dart';
import 'package:agroconnect/pages/client_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  final String? initialSearch;

  const SearchPage({super.key, this.initialSearch});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  static const primaryGreen = Color(0xFF549D73);
  static const backgroundGrey = Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();
    _loadAllProducts();

    if (widget.initialSearch != null) {
      _searchController.text = widget.initialSearch!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialSearch!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllProducts() async {
    setState(() => _isLoading = true);

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        _allProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void setSearchQuery(String query) {
    setState(() {
      _searchController.text = query;
    });
    _performSearch(query);
  }

  void _performSearch(String query) {
    setState(() {
      _hasSearched = true;
      if (query.isEmpty) {
        _filteredProducts = [];
      } else {
        _filteredProducts = _allProducts.where((product) {
          return product.productName.toLowerCase().contains(query.toLowerCase()) ||
              product.origin.toLowerCase().contains(query.toLowerCase()) ||
              product.productCategory.displayName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            _SearchHeader(),
            Expanded(child: _SearchContent()),
          ],
        ),
      ),
    );
  }

  Widget _SearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _performSearch,
          decoration: InputDecoration(
            hintText: 'Pesquisar produtos...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search, color: primaryGreen),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear, color: Colors.grey[500]),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _SearchContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: primaryGreen),
      );
    }

    if (!_hasSearched) {
      return _InitialSearchView();
    }

    if (_searchController.text.isEmpty) {
      return _InitialSearchView();
    }

    if (_filteredProducts.isEmpty) {
      return _NoResultsView();
    }

    return _SearchResultsView();
  }

  Widget _InitialSearchView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categorias',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _CategoriesGrid(),
          const SizedBox(height: 32),
          Text(
            'Pesquisas populares',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _PopularSearches(),
        ],
      ),
    );
  }

  Widget _CategoriesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: ProductCategoriesEnum.values.length,
      itemBuilder: (context, index) {
        final category = ProductCategoriesEnum.values[index];
        return GestureDetector(
          onTap: () {
            _searchController.text = category.displayName;
            _performSearch(category.displayName);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(category.icon, color: category.color, size: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  category.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _PopularSearches() {
    final popularSearches = ['Tomates', 'Maçãs', 'Alface', 'Cenouras', 'Morangos'];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: popularSearches.map((search) {
        return GestureDetector(
          onTap: () {
            _searchController.text = search;
            _performSearch(search);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryGreen.withOpacity(0.3)),
            ),
            child: Text(
              search,
              style: TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _NoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhum produto encontrado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente procurar por outro termo',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _SearchResultsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${_filteredProducts.length} produtos encontrados',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              return _ProductCard(product: _filteredProducts[index]);
            },
          ),
        ),
      ],
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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: product.productCategory.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                product.productCategory.icon,
                color: Colors.white,
                size: 40,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.origin,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${product.unitPrice.toStringAsFixed(2)}€',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: SearchPageState.primaryGreen,
                          ),
                        ),
                        const Spacer(),
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}