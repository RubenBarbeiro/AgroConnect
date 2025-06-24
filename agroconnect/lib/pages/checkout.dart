import 'package:agroconnect/models/product_categories_enum.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agroconnect/logic/cart_state.dart';
import '../logic/order_service.dart';
import '../models/orders.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderService _orderService = OrderService();
  String _deliveryAddress = '';
  String _paymentMethod = 'Visa *1234';
  String _promoCode = '';
  bool _isProcessing = false;

  // Controllers for form fields
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Adicionar Morada'),
        content: TextField(
          controller: _addressController,
          decoration: InputDecoration(
            hintText: 'Digite sua morada completa',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              if (_addressController.text.trim().isNotEmpty) {
                setState(() {
                  _deliveryAddress = _addressController.text.trim();
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(84, 157, 115, 1.0),
              foregroundColor: Colors.white, // Fixed: Added white text color
            ),
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Método de Pagamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPaymentOption(Icons.credit_card, 'Visa *1234'),
            _buildPaymentOption(Icons.credit_card, 'Mastercard *5678'),
            _buildPaymentOption(Icons.account_balance_wallet, 'PayPal'),
            _buildPaymentOption(Icons.money, 'Multibanco'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(IconData icon, String method) {
    return ListTile(
      leading: Icon(icon, color: Color.fromRGBO(84, 157, 115, 1.0)),
      title: Text(method),
      trailing: _paymentMethod == method
          ? Icon(Icons.check_circle, color: Color.fromRGBO(84, 157, 115, 1.0))
          : null,
      onTap: () {
        setState(() {
          _paymentMethod = method;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showPromoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Código Promocional'),
        content: TextField(
          controller: _promoController,
          decoration: InputDecoration(
            hintText: 'Digite o código promocional',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _promoCode = _promoController.text.trim();
              });
              Navigator.pop(context);
              if (_promoCode.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Código promocional aplicado!'),
                    backgroundColor: Color.fromRGBO(84, 157, 115, 1.0),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(84, 157, 115, 1.0),
              foregroundColor: Colors.white, // Fixed: Added white text color
            ),
            child: Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizePurchase() async {
    final cart = Provider.of<CartProvider>(context, listen: false);

    // Validation
    if (_deliveryAddress.isEmpty) {
      _showErrorDialog('Por favor, adicione uma morada de entrega.');
      return;
    }

    if (cart.cartItems.isEmpty) {
      _showErrorDialog('Seu carrinho está vazio.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final finalTotal = cart.total;

      final orderId = await _orderService.createOrder(
        cartItems: cart.cartItems,
        subtotal: cart.subtotal,
        deliveryFee: cart.deliveryFee,
        total: finalTotal,
        deliveryAddress: _deliveryAddress,
        paymentMethod: _paymentMethod,
        promoCode: _promoCode.isNotEmpty ? _promoCode : null,
      );

      if (orderId != null) {
        cart.clear();

        _showSuccessDialog(orderId);
      } else {
        _showErrorDialog('Erro ao processar pedido. Tente novamente.');
      }
    } catch (e) {
      _showErrorDialog('Erro ao processar pedido: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Color.fromRGBO(84, 157, 115, 1.0),
              size: 28,
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Pedido Confirmado!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('O seu pedido foi processado com sucesso!'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color.fromRGBO(84, 157, 115, 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt, color: Color.fromRGBO(84, 157, 115, 1.0)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pedido #${orderId.substring(0, 8).toUpperCase()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(84, 157, 115, 1.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Pode consultar o seu pedido na sua página de compras.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Fixed: Better navigation to avoid black screen
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).popUntil((route) => route.isFirst); // Go to root (home)
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(84, 157, 115, 1.0),
              foregroundColor: Colors.white, // Fixed: Added white text color
            ),
            child: Text('Voltar'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600]),
            SizedBox(width: 8),
            Text('Erro'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white, // Fixed: Added white text color for consistency
            ),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final cartItems = arguments?['cartItems'] as List<CartItem>? ?? [];
    final subtotal = arguments?['subtotal'] as double? ?? 0.0;
    final deliveryFee = arguments?['deliveryFee'] as double? ?? 0.0;
    final total = arguments?['total'] as double? ?? 0.0;
    final finalTotal = total;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard([
                    _buildCheckoutSection(
                      'ENTREGA',
                      _deliveryAddress.isEmpty ? 'Adicionar morada' : _deliveryAddress,
                      Icons.location_on,
                      onTap: _showAddressDialog,
                      isEmpty: _deliveryAddress.isEmpty,
                    ),
                  ]),
                  SizedBox(height: 16),
                  _buildSectionCard([
                    _buildCheckoutSection(
                      'MÉTODO DE ENVIO',
                      deliveryFee == 0.0
                          ? 'Entrega Grátis\nStandard | 3-4 dias'
                          : 'Entrega Paga\nStandard | 3-4 dias\n€${deliveryFee.toStringAsFixed(2)}',
                      Icons.local_shipping,
                    ),
                  ]),
                  SizedBox(height: 16),
                  _buildSectionCard([
                    _buildCheckoutSection(
                      'PAGAMENTO',
                      _paymentMethod,
                      Icons.payment,
                      onTap: _showPaymentDialog,
                    ),
                  ]),
                  SizedBox(height: 16),
                  _buildSectionCard([
                    _buildCheckoutSection(
                      'CÓDIGO PROMOCIONAL',
                      _promoCode.isEmpty ? 'Utilizar código' : _promoCode,
                      Icons.local_offer,
                      onTap: _showPromoDialog,
                      isEmpty: _promoCode.isEmpty,
                    ),
                  ]),
                  SizedBox(height: 24),
                  _buildItemsSection(cartItems),
                  SizedBox(height: 24),
                  _buildOrderSummary(cartItems.length, subtotal, deliveryFee, finalTotal),
                ],
              ),
            ),
          ),
          _buildFinalizePurchaseButton(finalTotal),
        ],
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildCheckoutSection(
      String title,
      String value,
      IconData icon, {
        VoidCallback? onTap,
        bool isEmpty = false,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Color.fromRGBO(84, 157, 115, 1.0), size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: isEmpty ? Colors.grey[500] : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(List<CartItem> cartItems) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_basket, color: Color.fromRGBO(84, 157, 115, 1.0), size: 20),
                SizedBox(width: 8),
                Text(
                  'ITEMS (${cartItems.length})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...cartItems.map((item) => _buildItemRow(
              item.product.productCategory.icon,
              item.product.productCategory.color ?? Color.fromRGBO(84, 157, 115, 1.0),
              item.product.productName,
              item.product.origin,
              item.quantity,
              item.totalPrice,
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(
      IconData icon,
      Color color,
      String productName,
      String origin,
      int quantity,
      double totalPrice,
      ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '$origin • Qty: $quantity',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '€${totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(84, 157, 115, 1.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(int itemCount, double subtotal, double deliveryFee, double finalTotal) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: Color.fromRGBO(84, 157, 115, 1.0), size: 20),
                SizedBox(width: 8),
                Text(
                  'RESUMO DO PEDIDO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildSummaryRow('Subtotal ($itemCount items)', '€${subtotal.toStringAsFixed(2)}'),
            _buildSummaryRow('Entrega', deliveryFee == 0.0 ? 'Grátis' : '€${deliveryFee.toStringAsFixed(2)}'),
            Divider(height: 24, color: Colors.grey[300]),
            _buildSummaryRow('Total', '€${finalTotal.toStringAsFixed(2)}', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.black87 : Colors.grey[700],
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Color.fromRGBO(84, 157, 115, 1.0) : Colors.black87,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalizePurchaseButton(double finalTotal) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
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
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _finalizePurchase,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Color.fromRGBO(84, 157, 115, 1.0),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: _isProcessing
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'A processar...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.credit_card, size: 20),
              SizedBox(width: 8),
              Text(
                'Pagar €${finalTotal.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}