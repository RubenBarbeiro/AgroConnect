import 'package:flutter/material.dart';

class ComprasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Minhas Compras',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _samplePurchases.length,
        itemBuilder: (context, index) {
          final purchase = _samplePurchases[index];
          return _buildPurchaseCard(purchase);
        },
      ),
    );
  }

  Widget _buildPurchaseCard(Purchase purchase) {
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
                  purchase.vendorName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(purchase.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    purchase.status,
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
              purchase.date,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            ...purchase.items.map((item) => _buildItemRow(item)).toList(),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total (${purchase.items.length} ${purchase.items.length == 1 ? 'item' : 'itens'})',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '€${purchase.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(84, 157, 115, 1.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(PurchaseItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_basket,
              color: Color.fromRGBO(84, 157, 115, 1.0),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Quantidade: ${item.quantity}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '€${item.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'entregue':
        return const Color.fromRGBO(84, 157, 115, 1.0);
      case 'pendente':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class Purchase {
  final String vendorName;
  final String date;
  final String status;
  final List<PurchaseItem> items;
  final double total;

  Purchase({
    required this.vendorName,
    required this.date,
    required this.status,
    required this.items,
    required this.total,
  });
}

class PurchaseItem {
  final String name;
  final int quantity;
  final double price;

  PurchaseItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}

final List<Purchase> _samplePurchases = [
  Purchase(
    vendorName: 'Mercado Verde',
    date: '12 Jun 2025',
    status: 'Entregue',
    items: [
      PurchaseItem(name: 'Cenouras de alta qualidade', quantity: 2, price: 8.99),
      PurchaseItem(name: 'Pêras mais saborosas', quantity: 1, price: 6.99),
    ],
    total: 15.98,
  ),
  Purchase(
    vendorName: 'Quinta Fresco',
    date: '10 Jun 2025',
    status: 'Pendente',
    items: [
      PurchaseItem(name: 'Batatas', quantity: 3, price: 12.50),
      PurchaseItem(name: 'Cebola de Tri Movel', quantity: 1, price: 4.25),
    ],
    total: 16.75,
  ),
  Purchase(
    vendorName: 'Feira na Porta',
    date: '8 Jun 2025',
    status: 'Entregue',
    items: [
      PurchaseItem(name: 'Melancias', quantity: 1, price: 13.99),
    ],
    total: 13.99,
  ),
  Purchase(
    vendorName: 'Pomar das Maçãs Douradas',
    date: '5 Jun 2025',
    status: 'Entregue',
    items: [
      PurchaseItem(name: 'Maçãs Douradas', quantity: 2, price: 7.50),
      PurchaseItem(name: 'Pêras', quantity: 1, price: 5.99),
      PurchaseItem(name: 'Cerejas', quantity: 1, price: 9.25),
    ],
    total: 22.74,
  ),
];