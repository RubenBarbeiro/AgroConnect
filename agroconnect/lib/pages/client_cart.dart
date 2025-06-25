import 'package:agroconnect/models/product_categories_enum.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agroconnect/logic/cart_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _navigateToCheckout() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.cartItems.isNotEmpty) {
      Navigator.pushNamed(
        context,
        '/checkout.dart',
        arguments: {
          'cartItems': cart.cartItems,
          'subtotal': cart.subtotal,
          'deliveryFee': cart.deliveryFee,
          'total': cart.total,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.isEmpty) return SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  cart.clear();
                },
                child: Text(
                  'Limpar',
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return cart.isEmpty ? _buildEmptyCart() : _buildCartContent(cart);
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) return SizedBox.shrink();
          return _buildCheckoutSection(cart);
        },
      ),
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

  Widget _buildCartContent(CartProvider cart) {
    return Column(
      children: [
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
                  cart.subtotal >= 10.0
                      ? 'Entrega grátis! Pedido acima de 10€'
                      : 'Faltam ${(10.0 - cart.subtotal).toStringAsFixed(2)}€ para entrega grátis',
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
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cart.cartItems.length,
            itemBuilder: (context, index) {
              final item = cart.cartItems[index];
              return _buildCartItem(item, cart);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cart) {
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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: item.product.productCategory.color?.withOpacity(0.1) ??
                      Color.fromRGBO(84, 157, 115, 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    item.product.productCategory.icon,
                    size: 32,
                    color: item.product.productCategory.color ??
                        Color.fromRGBO(84, 157, 115, 1.0),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.productName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      item.product.origin,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromRGBO(84, 157, 115, 1.0),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${item.product.unitPrice.toStringAsFixed(2)}€/kg',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => cart.updateQuantity(item.id, item.quantity - 1),
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
                        onTap: () => cart.updateQuantity(item.id, item.quantity + 1),
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
                    '${item.totalPrice.toStringAsFixed(2)}€',
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

  Widget _buildCheckoutSection(CartProvider cart) {
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
                      '${cart.subtotal.toStringAsFixed(2)}€',
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
                      cart.deliveryFee == 0.0 ? 'Grátis' : '${cart.deliveryFee.toStringAsFixed(2)}€',
                      style: TextStyle(
                        fontSize: 14,
                        color: cart.deliveryFee == 0.0 ? Color.fromRGBO(84, 157, 115, 1.0) : Colors.grey[600],
                        fontWeight: cart.deliveryFee == 0.0 ? FontWeight.w600 : FontWeight.normal,
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
                      '${cart.total.toStringAsFixed(2)}€',
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToCheckout,
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
                      'Ir para Checkout',
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