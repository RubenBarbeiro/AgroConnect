import 'package:flutter/material.dart';

class ProductSearchBar extends StatefulWidget { // Changed from StatelessWidget to StatefulWidget
  final List<String> products;
  final ValueChanged<String>? onProductSelected;
  const ProductSearchBar({Key? key, required this.products, this.onProductSelected}) : super(key: key);

  @override
  _ProductSearchBarState createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredProducts = []; // Added list to hold filtered products

  @override
  void initState() {
    // Initialize _filteredProducts with all products initially
    super.initState();
    _filteredProducts = widget.products;
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts); // Remove listener
    _searchController.dispose();
    super.dispose();
  }

  // Method to filter products based on the search query
  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = widget.products.where((product) {
        return product.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox( // Wrap with SizedBox to give it a defined height
        height: 250.0, // Adjust height as needed to accommodate text field and list

        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              // TextField for search input
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for products...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty) // Conditionally display the list
              SizedBox( // Wrap ListView with SizedBox to give it a defined height within the column
                height: 150.0, // Adjust height as needed for the list view portion
                child: ListView.builder(
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        widget.onProductSelected?.call(_filteredProducts[index]); // Call the callback on tap
                      },
                      title: Text(_filteredProducts[index]),
                    );
                  },
                ),
              ),

          ],
        ));
  }
}
