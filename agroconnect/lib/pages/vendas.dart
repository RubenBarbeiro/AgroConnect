import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:agroconnect/models/orders.dart';
import 'package:agroconnect/models/product_model.dart';
import 'package:agroconnect/models/client_model.dart';
import 'package:agroconnect/models/product_categories_enum.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Order> orders = [];
  List<Order> filteredOrders = [];
  bool isLoading = true;
  Set<ProductCategoriesEnum> selectedCategories = {};
  String selectedOrderStatus = '';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .get();

        setState(() {
          orders = snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
          filteredOrders = List.from(orders);
        });
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<ProductModel?> _fetchProductById(String productId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (doc.exists) {
        return ProductModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product: $e');
      return null;
    }
  }

  Future<ClientModel?> _fetchClientById(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('clients')
          .doc(userId)
          .get();

      if (doc.exists) {
        return ClientModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching client: $e');
      return null;
    }
  }

  void _applyFilters() {
    setState(() {
      filteredOrders = orders.where((order) {
        // Category filter
        if (selectedCategories.isNotEmpty) {
          final hasSelectedCategory = order.items.any((item) {
            final category = _tryGetCategory(item.category);
            return category != null && selectedCategories.contains(category);
          });
          if (!hasSelectedCategory) return false;
        }

        // Status filter
        if (selectedOrderStatus.isNotEmpty) {
          final status = OrderStatus.fromString(order.status).displayName;
          if (status != selectedOrderStatus) return false;
        }

        return true;
      }).toList();
    });
  }

  ProductCategoriesEnum? _tryGetCategory(String categoryName) {
    try {
      return ProductCategoriesEnum.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() ==
            categoryName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Vendas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFiltersPage,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildOrdersList(),
    );
  }

  Widget _buildOrdersList() {
    if (filteredOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhuma venda encontrada'),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text('Histórico de vendas', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(filteredOrders[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _getStatusColor(order.status);
    final statusText = OrderStatus.fromString(order.status).displayName;
    final productNames = order.items.map((item) => item.productName).join(', ');
    final formattedDate = _formatDate(order.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetails(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 60,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productNames.length > 35 ? '${productNames.substring(0, 35)}...' : productNames,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(statusText, style: TextStyle(color: Colors.grey[600])),
                    Text(formattedDate, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('€${order.total.toStringAsFixed(2)}'),
                  Text('${order.items.length} itens',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(Order order) async {
    if (order.items.isEmpty) return;

    final firstItem = order.items.first;

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Fetch product and client data
      final product = await _fetchProductById(firstItem.productId);
      final client = await _fetchClientById(order.userId);

      // Close loading dialog
      Navigator.of(context).pop();

      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produto não encontrado')));
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SaleDetailsScreen(
            product: product,
            quantity: firstItem.quantity,
            client: client ?? ClientModel(
              userId: order.userId,
              name: order.userEmail.split('@').first,
              email: order.userEmail,
              primaryDeliveryAddress: order.deliveryAddress,
              imagePath: '',
              city: '',
              parish: '',
              postalCode: '',
              createdAt: null,
            ),
            deliveryAddress: order.deliveryAddress,
          ),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog on error
      debugPrint('Erro ao navegar para detalhes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar detalhes do pedido')),
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFFFFC107);
      case 'confirmed': return const Color(0xFF2196F3);
      case 'preparing': return const Color(0xFFFF9800);
      case 'shipping': return const Color(0xFF9C27B0);
      case 'delivered': return const Color(0xFF4CAF50);
      case 'cancelled': return const Color(0xFFF44336);
      default: return Colors.grey;
    }
  }

  void _showFiltersPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FiltersPage(
          selectedCategories: selectedCategories,
          selectedOrderStatus: selectedOrderStatus,
          onFiltersApplied: (categories, status) {
            setState(() {
              selectedCategories = categories;
              selectedOrderStatus = status;
            });
            _applyFilters();
          },
        ),
      ),
    );
  }
}

class _FiltersPage extends StatefulWidget {
  final Set<ProductCategoriesEnum> selectedCategories;
  final String selectedOrderStatus;
  final Function(Set<ProductCategoriesEnum>, String) onFiltersApplied;

  const _FiltersPage({
    required this.selectedCategories,
    required this.selectedOrderStatus,
    required this.onFiltersApplied,
  });

  @override
  State<_FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<_FiltersPage> {
  late Set<ProductCategoriesEnum> _selectedCategories;
  late String _selectedOrderStatus;

  final List<String> orderStatuses = [
    'Pendente', 'Confirmado', 'Em Preparação',
    'A Enviar', 'Entregue', 'Cancelado'
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategories = Set.from(widget.selectedCategories);
    _selectedOrderStatus = widget.selectedOrderStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros de Vendas'),
        actions: [
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text('Limpar', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFilterSection('Categorias', Icons.category, _buildCategoriesFilter()),
            const SizedBox(height: 20),
            _buildFilterSection('Status', Icons.assignment, _buildStatusFilter()),
            const SizedBox(height: 40),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, IconData icon, Widget content) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: Colors.green),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          content,
        ],
      ),
    );
  }

  Widget _buildCategoriesFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: ProductCategoriesEnum.values.map((category) {
          return CheckboxListTile(
            title: Text(category.displayName),
            value: _selectedCategories.contains(category),
            onChanged: (value) {
              setState(() {
                value == true
                    ? _selectedCategories.add(category)
                    : _selectedCategories.remove(category);
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: orderStatuses.map((status) {
          return RadioListTile<String>(
            title: Text(status),
            value: status,
            groupValue: _selectedOrderStatus,
            onChanged: (value) => setState(() => _selectedOrderStatus = value ?? ''),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          widget.onFiltersApplied(_selectedCategories, _selectedOrderStatus);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Aplicar Filtros'),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedOrderStatus = '';
    });
  }
}

class SaleDetailsScreen extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final ClientModel? client;
  final String deliveryAddress;

  const SaleDetailsScreen({
    Key? key,
    required this.product,
    this.quantity = 1,
    this.client,
    this.deliveryAddress = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtotal = product.unitPrice * quantity;
    final deliveryCost = 8.00;
    final tax = subtotal * 0.06;
    final total = subtotal + deliveryCost + tax;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.receipt, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              'Detalhe da venda',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Client Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cliente',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[100],
                            child: const Icon(Icons.person, color: Colors.green),
                          ),
                          title: Text(
                            client?.name ?? 'Cliente não identificado',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(client?.email ?? ''),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Delivery Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Entrega',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.location_on, color: Colors.green),
                          title: const Text(
                            'Endereço de entrega',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(deliveryAddress.isNotEmpty
                              ? deliveryAddress
                              : 'Endereço não especificado'),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.timer, color: Colors.green),
                          title: const Text(
                            'Tempo estimado',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${product.deliveryTime} dias úteis'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Product Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Produto',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                              image: product.productImage.isNotEmpty
                                  ? DecorationImage(
                                image: NetworkImage(product.productImage),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: product.productImage.isEmpty
                                ? Icon(Icons.shopping_bag, color: Colors.green)
                                : null,
                          ),
                          title: Text(
                            product.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Quantidade: $quantity'),
                          trailing: Text(
                            '€${product.unitPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Order Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumo do Pedido',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildOrderSummaryRow('Subtotal', subtotal),
                        _buildOrderSummaryRow('Entrega', deliveryCost),
                        _buildOrderSummaryRow('Taxas', tax),
                        const Divider(height: 24),
                        _buildOrderSummaryRow(
                          'Total',
                          total,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '€${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}