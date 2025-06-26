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
  Map<String, ProductModel> productCache = {};
  bool isLoading = true;
  Set<ProductCategoriesEnum> selectedCategories = {};
  String selectedOrderStatus = '';

  @override
  void initState() {
    super.initState();
    _loadSupplierOrders();
  }

  Future<void> _loadSupplierOrders() async {
    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final supplierProducts = await _getSupplierProducts(user.uid);
      final supplierProductIds = supplierProducts.map((p) => p.productId).toSet();

      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      List<Order> supplierOrders = [];

      for (var doc in ordersSnapshot.docs) {
        try {
          final order = Order.fromFirestore(doc);
          final matchingItems = order.items.where((item) =>
              supplierProductIds.contains(item.productId)).toList();

          if (matchingItems.isNotEmpty) {
            final filteredOrder = order.copyWith(items: matchingItems);
            supplierOrders.add(filteredOrder);
          }
        } catch (e) {
          debugPrint('Error processing order ${doc.id}: $e');
        }
      }

      setState(() {
        orders = supplierOrders;
        filteredOrders = List.from(orders);
      });
    } catch (e) {
      debugPrint('Error loading supplier orders: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<List<ProductModel>> _getSupplierProducts(String supplierId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('createdUserId', isEqualTo: supplierId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['productId'] = doc.id;
        final product = ProductModel.fromJson(data);
        productCache[product.productId] = product;
        return product;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<ProductModel?> _fetchProductById(String productId) async {
    if (productCache.containsKey(productId)) {
      return productCache[productId];
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        data['productId'] = doc.id;
        final product = ProductModel.fromJson(data);
        productCache[productId] = product;
        return product;
      }
      return null;
    } catch (e) {
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
      return null;
    }
  }

  void _applyFilters() {
    setState(() {
      filteredOrders = orders.where((order) {
        if (selectedCategories.isNotEmpty) {
          final hasSelectedCategory = order.items.any((item) {
            final category = _tryGetCategory(item.category);
            return category != null && selectedCategories.contains(category);
          });
          if (!hasSelectedCategory) return false;
        }

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
            (e) => e.toString().split('.').last.toLowerCase() == categoryName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Minhas Vendas',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onPressed: _showFiltersPage,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadSupplierOrders,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color.fromRGBO(84, 157, 115, 1.0),
        ),
      )
          : filteredOrders.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadSupplierOrders,
        color: const Color.fromRGBO(84, 157, 115, 1.0),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return _buildOrderCard(order);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhuma venda realizada',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Suas vendas aparecerão aqui quando clientes comprarem seus produtos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final formattedDate = _formatDate(order.createdAt);
    final statusText = OrderStatus.fromString(order.status).displayName;
    final productNames = order.items.map((item) => item.productName).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    OrderStatus.fromString(order.status).displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  order.userEmail.split('@').first,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (order.deliveryAddress.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.deliveryAddress,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            ...order.items.map((item) => _buildItemRow(item)).toList(),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total dos meus produtos (${order.items.length} ${order.items.length == 1 ? 'item' : 'itens'})',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '€${order.items.fold(0.0, (sum, item) => sum + item.totalPrice).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(84, 157, 115, 1.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildOrderActions(order),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${item.quantity}x ${item.productName}',
              style: const TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '€${item.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderActions(Order order) {
    if (order.status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateOrderStatus(order.id, OrderStatus.confirmed),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color.fromRGBO(84, 157, 115, 1.0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Confirmar',
                style: TextStyle(color: Color.fromRGBO(84, 157, 115, 1.0)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateOrderStatus(order.id, OrderStatus.cancelled),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Recusar',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
          ),
        ],
      );
    } else if (order.status == 'confirmed') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateOrderStatus(order.id, OrderStatus.preparing),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(84, 157, 115, 1.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Iniciar Preparação', style: TextStyle(color: Colors.white)),
        ),
      );
    } else if (order.status == 'preparing') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateOrderStatus(order.id, OrderStatus.shipping),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(84, 157, 115, 1.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Marcar como Enviado', style: TextStyle(color: Colors.white)),
        ),
      );
    } else if (order.status == 'shipping') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _updateOrderStatus(order.id, OrderStatus.delivered),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(84, 157, 115, 1.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Marcar como Entregue', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status atualizado para ${newStatus.displayName}'),
          backgroundColor: const Color.fromRGBO(84, 157, 115, 1.0),
        ),
      );

      _loadSupplierOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao atualizar status do pedido'),
          backgroundColor: Colors.red,
        ),
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
    'Pendente', 'Confirmado', 'A Preparar',
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategories.clear();
                _selectedOrderStatus = '';
              });
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Status do Pedido',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...orderStatuses.map((status) => CheckboxListTile(
                  title: Text(status),
                  value: _selectedOrderStatus == status,
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedOrderStatus = value == true ? status : '';
                    });
                  },
                  activeColor: const Color.fromRGBO(84, 157, 115, 1.0),
                )),
                const SizedBox(height: 24),
                const Text(
                  'Categorias',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...ProductCategoriesEnum.values.map((category) => CheckboxListTile(
                  title: Text(_getCategoryDisplayName(category)),
                  value: _selectedCategories.contains(category),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                  activeColor: const Color.fromRGBO(84, 157, 115, 1.0),
                )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onFiltersApplied(_selectedCategories, _selectedOrderStatus);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(84, 157, 115, 1.0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Aplicar Filtros',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(ProductCategoriesEnum category) {
    switch (category) {
      case ProductCategoriesEnum.vegetais: return 'Vegetais';
      case ProductCategoriesEnum.frutas: return 'Frutas';
      case ProductCategoriesEnum.cereais: return 'Cereais';
      case ProductCategoriesEnum.cabazes: return 'Cabazes';
      case ProductCategoriesEnum.sazonais: return 'Sazonais';
      default: return category.toString().split('.').last;
    }
  }
}