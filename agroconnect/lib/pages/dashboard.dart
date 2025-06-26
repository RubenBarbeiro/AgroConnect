import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agroconnect/models/orders.dart';
import 'package:agroconnect/models/product_categories_enum.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedFilter = 'All time';
  bool isLoading = true;
  int displayedProductsCount = 6;
  List<Order> _orders = [];
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        currentUserId = user.uid;
        await _loadOrders();
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadOrders() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _orders = snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
      });
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }
  }

  // 1. Métodos para buscar e processar pedidos
  List<Order> _getAllOrders() {
    return _orders..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Order> _getRecentOrders([int count = 3]) {
    return _getAllOrders().take(count).toList();
  }

  // 2. Métodos para estatísticas
  double _getTotalRevenue() {
    return _getAllOrders().fold(0.0, (sum, order) => sum + order.total);
  }

  double _getMonthlyRevenue() {
    final firstDayOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    return _getAllOrders()
        .where((order) => order.createdAt.isAfter(firstDayOfMonth))
        .fold(0.0, (sum, order) => sum + order.total);
  }

  int _getTotalOrders() {
    return _getAllOrders().length;
  }

  int _getUniqueProductsCount() {
    final products = _getAllOrders()
        .expand((order) => order.items)
        .map((item) => item.productName)
        .toSet();
    return products.length;
  }

  // 3. Métodos para gráficos
  List<Map<String, dynamic>> _getMonthlyRevenueData() {
    final now = DateTime.now();
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];

    return List.generate(6, (index) {
      final monthIndex = (now.month - 1 - index) % 12;
      final year = now.year - ((now.month - 1 - index) ~/ 12).abs();

      final revenue = _getAllOrders()
          .where((order) => order.createdAt.month == monthIndex + 1 &&
          order.createdAt.year == year)
          .fold(0.0, (sum, order) => sum + order.total);

      return {
        'month': index.toDouble(),
        'monthName': months[monthIndex],
        'revenue': revenue,
      };
    }).reversed.toList(); // Ordem cronológica
  }

  Map<ProductCategoriesEnum, double> _getRevenueByCategory() {
    final result = <ProductCategoriesEnum, double>{};

    for (final order in _getAllOrders()) {
      for (final item in order.items) {
        try {
          final category = ProductCategoriesEnum.values.firstWhere(
                (e) => e.toString().split('.').last.toLowerCase() == item.category.toLowerCase(),
          );

          result.update(
            category,
                (value) => value + item.totalPrice,
            ifAbsent: () => item.totalPrice,
          );
        } catch (e) {
          // Categoria não encontrada no enum - podemos ignorar ou tratar de outra forma
          debugPrint('Categoria não encontrada: ${item.category}');
        }
      }
    }

    return result;
  }

  // 4. Métodos para produtos
  List<Map<String, dynamic>> _getTopSellingProducts() {
    final productStats = <String, Map<String, dynamic>>{};

    for (final order in _getAllOrders()) {
      for (final item in order.items) {
        productStats.update(
          item.productName,
              (existing) => {
            ...existing,
            'sales': existing['sales'] + item.quantity,
            'revenue': existing['revenue'] + item.totalPrice,
            'orders': existing['orders'] + 1,
          },
          ifAbsent: () => {
            'name': item.productName,
            'category': item.category,
            'sales': item.quantity,
            'revenue': item.totalPrice,
            'rating': 0, // Você pode adicionar ratings aos itens se necessário
            'views': item.quantity * 10,
            'orders': 1,
          },
        );
      }
    }

    return productStats.values.toList()
      ..sort((a, b) => (b['sales'] as num).compareTo(a['sales'] as num));
  }

  List<Map<String, dynamic>> _getFilteredProducts() {
    final allProducts = _getTopSellingProducts();
    if (selectedFilter == 'All time') return allProducts;

    final now = DateTime.now();
    DateTime startDate;

    switch (selectedFilter) {
      case 'This week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
      case 'This month':
        startDate = DateTime(now.year, now.month, 1);
      case 'This year':
        startDate = DateTime(now.year, 1, 1);
      default:
        return allProducts;
    }

    return allProducts.where((product) {
      return _getAllOrders().any((order) =>
      order.createdAt.isAfter(startDate) &&
          order.items.any((item) => item.productName == product['name']));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: CircularProgressIndicator(
            color: const Color.fromRGBO(84, 157, 115, 1.0),
          ),
        ),
      );
    }

    final monthlyData = _getMonthlyRevenueData();
    final maxRevenue = monthlyData.fold(0.0, (max, e) => e['revenue'] > max ? e['revenue'] : max);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.black),
        title: Text(
          'HelloFarmer',
          style: GoogleFonts.kanit(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(84, 157, 115, 1.0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.agriculture, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Text(
              'Dashboard',
              style: GoogleFonts.kanit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(84, 157, 115, 1.0),
              ),
            ),
            const SizedBox(height: 20),

            // Cards de métricas
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Receita Total',
                    value: '€${_getTotalRevenue().toStringAsFixed(2)}',
                    subtitle: 'Receita acumulada',
                    color: const Color.fromRGBO(84, 157, 115, 1.0),
                    icon: Icons.euro_symbol,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Receita Mensal',
                    value: '€${_getMonthlyRevenue().toStringAsFixed(2)}',
                    subtitle: '${DateTime.now().month}/${DateTime.now().year}',
                    color: Colors.blue,
                    icon: Icons.calendar_month,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Pedidos',
                    value: '${_getTotalOrders()}',
                    subtitle: 'Total de pedidos',
                    color: Colors.orange,
                    icon: Icons.shopping_cart,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Produtos',
                    value: '${_getUniqueProductsCount()}',
                    subtitle: 'Itens diferentes',
                    color: Colors.purple,
                    icon: Icons.inventory,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Gráfico de receita semestral
            Container(
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
                        'Receita Semestral',
                        style: GoogleFonts.kanit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(84, 157, 115, 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+12.5%',
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromRGBO(84, 157, 115, 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: monthlyData.isEmpty
                        ? const Center(child: Text('Sem dados disponíveis'))
                        : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: maxRevenue * 1.2,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300]!,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '€${value.toInt()}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < monthlyData.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      monthlyData[value.toInt()]['monthName'],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: monthlyData.map((data) => FlSpot(
                              data['month'].toDouble(),
                              data['revenue'],
                            )).toList(),
                            isCurved: true,
                            color: const Color.fromRGBO(84, 157, 115, 1.0),
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 5,
                                  color: const Color.fromRGBO(84, 157, 115, 1.0),
                                  strokeWidth: 3,
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Gráfico de receita por categoria
            Container(
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
                    'Receita por Categoria',
                    style: GoogleFonts.kanit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: _getRevenueByCategory().isEmpty
                        ? const Center(child: Text('Sem dados disponíveis'))
                        : PieChart(
                      PieChartData(
                        sections: _getRevenueByCategory().entries.map((entry) {
                          final percentage = (entry.value / _getTotalRevenue()) * 100;
                          return PieChartSectionData(
                            color: entry.key.color,
                            value: entry.value,
                            title: '${percentage.toStringAsFixed(1)}%',
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: _getRevenueByCategory().entries.map((entry) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: entry.key.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entry.key.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Seção de últimos pedidos
            Container(
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
                      Text(
                        '${_orders.length} total',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._getRecentOrders().map((order) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildOrderItem(order),
                  )).toList(),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Seção de produtos mais vendidos
            Text(
              'Produtos Mais Vendidos',
              style: GoogleFonts.kanit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(84, 157, 115, 1.0),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedFilter,
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                  style: GoogleFonts.kanit(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFilter = newValue!;
                      displayedProductsCount = 6;
                    });
                  },
                  items: <String>['All time', 'This week', 'This month', 'This year']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ..._getFilteredProducts().take(displayedProductsCount).map((product) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildProductCard(
                name: product['name'] as String,
                category: product['category'] as String,
                sales: product['sales'].toString(),
                revenue: (product['revenue'] as num).toStringAsFixed(2),
                rating: (product['rating'] as num).toStringAsFixed(1),
              ),
            )).toList(),
            if (displayedProductsCount < _getFilteredProducts().length)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        displayedProductsCount += 6;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(84, 157, 115, 1.0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Carregar Mais (${_getFilteredProducts().length - displayedProductsCount} restantes)',
                      style: GoogleFonts.kanit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(Order order) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pedido ${order.orderNumber}',
                style: GoogleFonts.kanit(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  OrderStatus.fromString(order.status).displayName,
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${order.items.length} itens • Total: €${order.total.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data: ${_formatDate(order.createdAt)}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Widgets auxiliares
  Widget _buildMetricCard({
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.trending_up, color: color, size: 16),
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
            style: GoogleFonts.kanit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
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

  Widget _buildProductCard({
    required String name,
    required String category,
    required String sales,
    required String revenue,
    required String rating,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.kanit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color.fromRGBO(84, 157, 115, 1.0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Ativo',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Vendas', sales, Icons.shopping_cart),
              ),
              Expanded(
                child: _buildStatItem('Receita', '€$revenue', Icons.euro),
              ),
              Expanded(
                child: _buildStatItem('Avaliação', '$rating ⭐', Icons.star),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.kanit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}