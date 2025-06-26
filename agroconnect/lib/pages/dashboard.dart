import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:agroconnect/pages/mensagens.dart';
import 'package:agroconnect/services/dummy_messages.data.dart';
import 'package:agroconnect/models/messages_model.dart';
import 'package:agroconnect/models/orders.dart';
import 'package:agroconnect/models/product_model.dart';
import 'package:agroconnect/pages/navigation_supplier.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedFilter = 'All time';
  int displayedProductsCount = 6;
  List<Order> recentOrders = [];
  bool isLoadingOrders = true;
  Map<String, ProductModel> productCache = {};
  List<ProductModel> userProducts = [];
  bool loadingProducts = false;
  double totalRevenue = 0.0;
  int totalSales = 0;
  List<Map<String, dynamic>> salesData = [];
  bool loadingMetrics = true;

  @override
  void initState() {
    super.initState();
    loadRecentOrders();
    loadUserProducts();
    loadMetrics();
  }

  Future<void> loadMetrics() async {
    setState(() => loadingMetrics = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final supplierProducts = await getSupplierProducts(user.uid);
        final supplierProductIds = supplierProducts.map((p) => p.productId).toSet();

        final ordersSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .get();

        double revenue = 0.0;
        int sales = 0;
        Map<int, double> monthlySales = {};

        for (var doc in ordersSnapshot.docs) {
          try {
            final order = Order.fromFirestore(doc);
            if (order.status.toLowerCase() != 'delivered') continue;
            final matchingItems = order.items.where((item) =>
                supplierProductIds.contains(item.productId)).toList();

            if (matchingItems.isNotEmpty) {
              final supplierRevenue = matchingItems.fold(0.0, (sum, item) => sum + item.totalPrice);
              final supplierQuantity = matchingItems.fold(0, (sum, item) => sum + item.quantity);

              revenue += supplierRevenue;
              sales += supplierQuantity;

              final month = order.createdAt.month;
              monthlySales[month] = (monthlySales[month] ?? 0) + supplierRevenue;
            }
          } catch (e) {
            debugPrint('Error processing order ${doc.id}: $e');
          }
        }

        final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
        final currentMonth = DateTime.now().month;

        List<Map<String, dynamic>> data = [];
        for (int i = 0; i < 6; i++) {
          int monthIndex = (currentMonth - 6 + i) % 12;
          if (monthIndex < 0) monthIndex += 12;

          data.add({
            'month': months[monthIndex],
            'sales': monthlySales[monthIndex + 1] ?? 0.0,
          });
        }

        setState(() {
          totalRevenue = revenue;
          totalSales = sales;
          salesData = data;
        });
      }
    } catch (e) {
      print('Error loading metrics: $e');
    } finally {
      setState(() => loadingMetrics = false);
    }
  }

  Future<void> loadUserProducts() async {
    setState(() => loadingProducts = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('products')
            .where('createdUserId', isEqualTo: user.uid)
            .get();

        final products = querySnapshot.docs.map((doc) {
          final data = doc.data();
          data['productId'] = doc.id;
          return ProductModel.fromJson(data);
        }).toList();

        products.sort((a, b) => b.rating.compareTo(a.rating));

        setState(() => userProducts = products);
      }
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      setState(() => loadingProducts = false);
    }
  }

  Future<void> loadRecentOrders() async {
    setState(() => isLoadingOrders = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final supplierProducts = await getSupplierProducts(user.uid);
      final supplierProductIds = supplierProducts.map((p) => p.productId).toSet();

      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();

      List<Order> orders = [];

      for (var doc in ordersSnapshot.docs) {
        try {
          final order = Order.fromFirestore(doc);
          final matchingItems = order.items.where((item) =>
              supplierProductIds.contains(item.productId)).toList();

          if (matchingItems.isNotEmpty) {
            final filteredOrder = order.copyWith(items: matchingItems);
            orders.add(filteredOrder);
          }
        } catch (e) {
          debugPrint('Error processing order ${doc.id}: $e');
        }
      }

      setState(() {
        recentOrders = orders;
      });
    } catch (e) {
      debugPrint('Error loading orders: $e');
    } finally {
      setState(() => isLoadingOrders = false);
    }
  }

  Future<List<ProductModel>> getSupplierProducts(String supplierId) async {
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

  void navigateToSales() {
    final navigationSupplier = context.findAncestorStateOfType<NavigationSupplierState>();
    navigationSupplier?.setCurrentIndex(2);
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(84, 157, 115, 1.0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.agriculture, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'HelloFarmer',
              style: GoogleFonts.kanit(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Mensagens(currentUserId: auth.currentUser!.uid, currentUserType: 'supplier')),
            ),
            icon: const Icon(Icons.message, color: Colors.black),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Mensagens(
          currentUserId: auth.currentUser!.uid,
          currentUserType: 'supplier',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: GoogleFonts.kanit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(84, 157, 115, 1.0),
              ),
            ),
            const SizedBox(height: 20),
            buildMetricsRow(),
            const SizedBox(height: 20),
            buildSalesChart(),
            buildProductsSection(),
            const SizedBox(height: 20),
            buildOrdersSection(),
          ],
        ),
      ),
    );
  }

  Widget buildMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: buildMetricCard(
            title: 'Receita Total',
            value: '€${totalRevenue.toStringAsFixed(2)}',
            subtitle: 'Receita acumulada',
            color: const Color.fromRGBO(84, 157, 115, 1.0),
            icon: Icons.euro,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: buildMetricCard(
            title: 'Vendas',
            value: '$totalSales',
            subtitle: 'Produtos vendidos',
            color: const Color.fromRGBO(52, 152, 219, 1.0),
            icon: Icons.shopping_cart,
          ),
        ),
      ],
    );
  }

  Widget buildSalesChart() {
    return SizedBox(
      height: 200,
      child: loadingMetrics
          ? const Center(child: CircularProgressIndicator())
          : salesData.isEmpty
          ? Center(
        child: Text(
          'Nenhum dado de vendas disponível',
          style: TextStyle(color: Colors.grey[600]),
        ),
      )
          : LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < salesData.length) {
                    return Text(
                      salesData[value.toInt()]['month'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: salesData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value['sales'].toDouble());
              }).toList(),
              isCurved: true,
              color: const Color.fromRGBO(84, 157, 115, 1.0),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: const Color.fromRGBO(84, 157, 115, 1.0),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color.fromRGBO(84, 157, 115, 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProductsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produtos Mais Populares',
            style: GoogleFonts.kanit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          loadingProducts
              ? const Center(child: CircularProgressIndicator())
              : userProducts.isEmpty
              ? Center(
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'Nenhum produto encontrado',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          )
              : Column(
            children: userProducts.take(displayedProductsCount).map((product) {
              return buildProductCard(product);
            }).toList(),
          ),
          if (userProducts.length > displayedProductsCount)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      displayedProductsCount = userProducts.length;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(84, 157, 115, 1.0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Ver mais ${userProducts.length - displayedProductsCount} produtos',
                    style: GoogleFonts.kanit(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildOrdersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Últimos Pedidos',
                style: GoogleFonts.kanit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              TextButton(
                onPressed: navigateToSales,
                child: Text(
                  'Ver todos',
                  style: TextStyle(
                    color: const Color.fromRGBO(84, 157, 115, 1.0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recentOrders.map((order) => buildOrderItem(order)).toList(),
        ],
      ),
    );
  }

  Widget buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.kanit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductCard(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(84, 157, 115, 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.agriculture,
              color: Color.fromRGBO(84, 157, 115, 1.0),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: GoogleFonts.kanit(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  product.origin,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text(
                '€${product.unitPrice.toStringAsFixed(2)}',
                style: GoogleFonts.kanit(
                  fontWeight: FontWeight.w600,
                  color: const Color.fromRGBO(84, 157, 115, 1.0),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOrderItem(Order order) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  order.userEmail,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  order.items.map((item) => item.productName).join(', '),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '€${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: getStatusColor(order.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  getStatusDisplayName(order.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'shipping':
        return Colors.cyan;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendente';
      case 'confirmed':
        return 'Confirmado';
      case 'preparing':
        return 'Preparando';
      case 'shipping':
        return 'Enviando';
      case 'delivered':
        return 'Entregue';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }
}

enum ProductCategory { fruits, vegetables }

extension ProductCategoryExtension on ProductCategory {
  Color get color {
    switch (this) {
      case ProductCategory.fruits:
        return Colors.orange;
      case ProductCategory.vegetables:
        return const Color.fromRGBO(84, 157, 115, 1.0);
    }
  }

  String get name {
    switch (this) {
      case ProductCategory.fruits:
        return 'Frutas';
      case ProductCategory.vegetables:
        return 'Vegetais';
    }
  }
}