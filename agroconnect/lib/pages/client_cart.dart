import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Sample cart items
  List<CartItem> cartItems = [
    CartItem(
      id: '1',
      name: 'Tomates Frescos',
      seller: 'Mercado Verde',
      price: 3.50,
      quantity: 2,
      unit: 'kg',
      image: '🍅',
    ),
    CartItem(
      id: '2',
      name: 'Cenouras Orgânicas',
      seller: 'Horta Encantada',
      price: 2.80,
      quantity: 1,
      unit: 'kg',
      image: '🥕',
    ),
    CartItem(
      id: '3',
      name: 'Alface Americana',
      seller: 'Quintal Fresco',
      price: 1.50,
      quantity: 3,
      unit: 'unidade',
      image: '🥬',
    ),
    CartItem(
      id: '4',
      name: 'Maçãs Douradas',
      seller: 'Pomar das Maçãs',
      price: 4.20,
      quantity: 1,
      unit: 'kg',
      image: '🍎',
    ),
  ];

  double get subtotal {
    return cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get deliveryFee => subtotal >= 10.0 ? 0.0 : 2.5;
  double get total => subtotal + deliveryFee;

  void _updateQuantity(String itemId, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        cartItems.removeWhere((item) => item.id == itemId);
      } else {
        final itemIndex = cartItems.indexWhere((item) => item.id == itemId);
        if (itemIndex != -1) {
          cartItems[itemIndex].quantity = newQuantity;
        }
      }
    });
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Color.fromRGBO(84, 157, 115, 1.0),
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Pedido Confirmado!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Seu pedido foi enviado para os produtores. Você receberá uma confirmação em breve.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  cartItems.clear();
                });
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Color.fromRGBO(84, 157, 115, 1.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color.fromRGBO(84, 157, 115, 1.0),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart,
              color: Color.fromRGBO(84, 157, 115, 1.0),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "Carrinho",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  cartItems.clear();
                });
              },
              child: Text(
                'Limpar',
                style: TextStyle(
                  color: Colors.red[400],
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      bottomNavigationBar: cartItems.isEmpty ? null : _buildCheckoutSection(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            'Seu carrinho está vazio',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Adicione produtos frescos dos nossos produtores locais',
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

  Widget _buildCartContent() {
    return Column(
      children: [
        // Delivery info banner
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.fromRGBO(84, 157, 115, 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color.fromRGBO(84, 157, 115, 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.local_shipping,
                color: Color.fromRGBO(84, 157, 115, 1.0),
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  subtotal >= 10.0
                      ? 'Entrega grátis! Pedido acima de 10€'
                      : 'Faltam ${(10.0 - subtotal).toStringAsFixed(2)}€ para entrega grátis',
                  style: TextStyle(
                    color: Color.fromRGBO(84, 157, 115, 1.0),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Cart items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _buildCartItem(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product image/emoji
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(84, 157, 115, 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    item.image,
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      item.seller,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromRGBO(84, 157, 115, 1.0),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${item.price.toStringAsFixed(2)}€/${item.unit}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              // Quantity controls
              Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _updateQuantity(item.id, item.quantity - 1),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 32,
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _updateQuantity(item.id, item.quantity + 1),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(84, 157, 115, 1.0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${(item.price * item.quantity).toStringAsFixed(2)}€',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(84, 157, 115, 1.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Price breakdown
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${subtotal.toStringAsFixed(2)}€',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Entrega',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      deliveryFee == 0.0 ? 'Grátis' : '${deliveryFee.toStringAsFixed(2)}€',
                      style: TextStyle(
                        fontSize: 14,
                        color: deliveryFee == 0.0 ? Color.fromRGBO(84, 157, 115, 1.0) : Colors.grey[600],
                        fontWeight: deliveryFee == 0.0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                Divider(height: 24, color: Colors.grey[300]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${total.toStringAsFixed(2)}€',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(84, 157, 115, 1.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            // Checkout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showCheckoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(84, 157, 115, 1.0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Finalizar Pedido',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItem {
  final String id;
  final String name;
  final String seller;
  final double price;
  int quantity;
  final String unit;
  final String image;

  CartItem({
    required this.id,
    required this.name,
    required this.seller,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.image,
  });
}