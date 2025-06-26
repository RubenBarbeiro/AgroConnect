import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agroconnect/pages/mensagens.dart';
import 'package:agroconnect/services/dummy_messages.data.dart';
import 'package:agroconnect/models/messages_model.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedFilter = 'All time';
  int displayedProductsCount = 6;

  final List<Map<String, dynamic>> _salesData = [
    {'month': 'Jan', 'sales': 1200},
    {'month': 'Fev', 'sales': 1600},
    {'month': 'Mar', 'sales': 1800},
    {'month': 'Abr', 'sales': 2100},
    {'month': 'Mai', 'sales': 1900},
    {'month': 'Jun', 'sales': 2300},
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Tomates Cherry',
      'category': 'Vegetais',
      'sales': 145,
      'revenue': 289.50,
      'rating': 4.8,
    },
    {
      'name': 'Alface Romana',
      'category': 'Vegetais',
      'sales': 98,
      'revenue': 147.60,
      'rating': 4.6,
    },
    {
      'name': 'Cenouras Bio',
      'category': 'Vegetais',
      'sales': 76,
      'revenue': 228.90,
      'rating': 4.9,
    },
    {
      'name': 'Morangos',
      'category': 'Frutas',
      'sales': 67,
      'revenue': 402.30,
      'rating': 4.7,
    },
    {
      'name': 'Batatas',
      'category': 'Vegetais',
      'sales': 89,
      'revenue': 178.45,
      'rating': 4.5,
    },
    {
      'name': 'Maçãs',
      'category': 'Frutas',
      'sales': 54,
      'revenue': 162.80,
      'rating': 4.4,
    },
  ];

  final List<Order> _orders = [
    Order(
      id: 'PED001',
      customerName: 'Maria Silva',
      products: ['Tomates Cherry', 'Alface'],
      total: 23.50,
      status: 'Entregue',
      date: DateTime.now().subtract(Duration(hours: 2)),
    ),
    Order(
      id: 'PED002',
      customerName: 'João Santos',
      products: ['Cenouras Bio'],
      total: 15.80,
      status: 'Pendente',
      date: DateTime.now().subtract(Duration(hours: 5)),
    ),
    Order(
      id: 'PED003',
      customerName: 'Ana Costa',
      products: ['Morangos', 'Maçãs'],
      total: 34.70,
      status: 'Preparando',
      date: DateTime.now().subtract(Duration(hours: 8)),
    ),
  ];

  double _getTotalRevenue() {
    return _products.fold(0.0, (sum, product) => sum + (product['revenue'] as num).toDouble());
  }

  int _getTotalSales() {
    return _products.fold(0, (sum, product) => sum + (product['sales'] as int));
  }

  List<Map<String, dynamic>> _getFilteredProducts() {
    return _products;
  }

  Map<ProductCategory, double> _getRevenueByCategory() {
    Map<ProductCategory, double> categoryRevenue = {};

    for (var product in _products) {
      ProductCategory category = product['category'] == 'Frutas'
          ? ProductCategory.fruits
          : ProductCategory.vegetables;

      categoryRevenue[category] = (categoryRevenue[category] ?? 0) +
          (product['revenue'] as num).toDouble();
    }

    return categoryRevenue;
  }



  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    num maxRevenue = _products.isEmpty ? 0 : _products.map((e) => e['revenue'] as num).reduce((curr, max) => curr > max ? curr : max);

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
              MaterialPageRoute(builder: (_) => Mensagens(currentUserId: _auth.currentUser!.uid, currentUserType: 'supplier')),
            ),
            icon: const Icon(Icons.message, color: Colors.black),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Mensagens(
          currentUserId: _auth.currentUser!.uid,
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

            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Receita Total',
                    value: '€${_getTotalRevenue().toStringAsFixed(2)}',
                    subtitle: 'Receita acumulada',
                    color: const Color.fromRGBO(84, 157, 115, 1.0),
                    icon: Icons.euro,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Vendas',
                    value: '${_getTotalSales()}',
                    subtitle: 'Produtos vendidos',
                    color: const Color.fromRGBO(52, 152, 219, 1.0),
                    icon: Icons.shopping_cart,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

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
                    'Vendas dos Últimos 6 Meses',
                    style: GoogleFonts.kanit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  _salesData[value.toInt()]['month'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                );
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
                            spots: _salesData.asMap().entries.map((entry) {
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
                        ? Center(
                      child: Text(
                        'Nenhum dado disponível',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    )
                        : PieChart(
                      PieChartData(
                        sections: _getRevenueByCategory().entries.map((entry) {
                          return PieChartSectionData(
                            color: entry.key.color,
                            value: entry.value,
                            title: '€${entry.value.toStringAsFixed(0)}',
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            radius: 50,
                          );
                        }).toList(),
                        centerSpaceRadius: 60,
                        sectionsSpace: 2,
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
                      TextButton(
                        onPressed: () {},
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
                  ..._orders.map((order) => _buildOrderItem(order)).toList(),
                ],
              ),
            ),
            const SizedBox(height: 20),

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
                        'Produtos Mais Vendidos',
                        style: GoogleFonts.kanit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
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
                    ],
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
          ],
        ),
      ),
    );
  }

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

  Widget _buildOrderItem(Order order) {
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
                  order.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  order.customerName,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  order.products.join(', '),
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
                  color: _getStatusColor(order.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status,
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

  Widget _buildProductCard({
    required String name,
    required String category,
    required String sales,
    required String revenue,
    required String rating,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  category,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '€$revenue',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color.fromRGBO(84, 157, 115, 1.0),
                ),
              ),
              Text(
                '$sales vendas',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Entregue':
        return Colors.green;
      case 'Pendente':
        return Colors.orange;
      case 'Preparando':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

enum ProductCategory {
  fruits,
  vegetables,
}

extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.fruits:
        return 'Frutas';
      case ProductCategory.vegetables:
        return 'Vegetais';
    }
  }

  Color get color {
    switch (this) {
      case ProductCategory.fruits:
        return const Color.fromRGBO(255, 99, 132, 1.0);
      case ProductCategory.vegetables:
        return const Color.fromRGBO(54, 162, 235, 1.0);
    }
  }
}

class Order {
  final String id;
  final String customerName;
  final List<String> products;
  final double total;
  final String status;
  final DateTime date;

  Order({
    required this.id,
    required this.customerName,
    required this.products,
    required this.total,
    required this.status,
    required this.date,
  });
}