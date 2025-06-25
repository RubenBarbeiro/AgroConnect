import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../logic/order_service.dart';
import '../models/orders.dart';

class ComprasPage extends StatefulWidget {
  @override
  _ComprasPageState createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserOrders();
  }

  Future<void> _loadUserOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await _orderService.getUserOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar pedidos: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshOrders() async {
    await _loadUserOrders();
  }

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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black87),
            onPressed: _refreshOrders,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Color.fromRGBO(84, 157, 115, 1.0),
        ),
      )
          : _orders.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _refreshOrders,
        color: Color.fromRGBO(84, 157, 115, 1.0),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _orders.length,
          itemBuilder: (context, index) {
            final order = _orders[index];
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
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            'Nenhuma compra realizada',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Seus pedidos aparecerão aqui após a compra',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(84, 157, 115, 1.0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              'Explorar Produtos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    String formattedDate = '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}';

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
                    color: Color(int.parse(order.statusColor.replaceFirst('#', '0xFF'))),
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
            if (order.paymentMethod.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.payment, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    order.paymentMethod,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            ...order.items.take(3).map((item) => _buildItemRow(item)).toList(),
            if (order.items.length > 3) ...[
              const SizedBox(height: 8),
              Text(
                '+ ${order.items.length - 3} mais ${order.items.length - 3 == 1 ? 'item' : 'itens'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total (${order.totalItems} ${order.totalItems == 1 ? 'item' : 'itens'})',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '€${order.total.toStringAsFixed(2)}',
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

  Widget _buildOrderActions(Order order) {
    if (order.status == 'pending') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => _cancelOrder(order.id),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.red[300]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Cancelar',
            style: TextStyle(color: Colors.red[600]),
          ),
        ),
      );
    } else if (order.status == 'delivered' || order.status == 'completed') {
      if (order.isRated) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                color: Colors.amber[600],
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Avaliado (${order.rating!.rating.toStringAsFixed(1)})',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      } else {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _rateOrder(order.id),
            icon: Icon(Icons.star_outline, size: 18),
            label: Text('Avaliar'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.orange[400]!),
              foregroundColor: Colors.orange[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildItemRow(OrderItem item) {
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
                  item.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (item.origin.isNotEmpty)
                  Text(
                    item.origin,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromRGBO(84, 157, 115, 1.0),
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
            item.formattedTotalPrice,
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

  Future<void> _cancelOrder(String orderId) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancelar Pedido'),
        content: Text('Tem certeza que deseja cancelar este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Sim, Cancelar'),
          ),
        ],
      ),
    );

    if (shouldCancel == true) {
      final success = await _orderService.cancelOrder(orderId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pedido cancelado com sucesso'),
            backgroundColor: Color.fromRGBO(84, 157, 115, 1.0),
          ),
        );
        _refreshOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cancelar pedido ou pedido não pode ser cancelado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rateOrder(String orderId) async {
    final result = await Navigator.pushNamed(
      context,
      '/client_rate.dart',
      arguments: {'orderId': orderId},
    );

    if (result == true) {
      _refreshOrders();
    }
  }
}