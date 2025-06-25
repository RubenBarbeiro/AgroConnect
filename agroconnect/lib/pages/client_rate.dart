import 'package:flutter/material.dart';
import 'package:agroconnect/logic/order_service.dart';
import 'package:agroconnect/models/orders.dart';

class EvaluationScreen extends StatefulWidget {
  @override
  _EvaluationScreenState createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  int _productRating = 0;
  int _serviceRating = 0;
  int _deliveryRating = 0;
  final TextEditingController _commentsController = TextEditingController();
  bool _isSubmitting = false;
  String? _orderId;
  Order? _order;

  final OrderService _orderService = OrderService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _orderId = args?['orderId'];
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    if (_orderId != null) {
      try {
        final order = await _orderService.getOrderById(_orderId!);
        setState(() {
          _order = order;
        });
      } catch (e) {
        print('Error loading order details: $e');
      }
    }
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Widget _buildStarRating(String title, String subtitle, int rating, Function(int) onRated) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onRated(index + 1),
                child: Container(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: index < rating ? Colors.amber[600] : Colors.grey[400],
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 8),
          Center(
            child: Text(
              _getRatingText(rating),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Muito Insatisfeito';
      case 2:
        return 'Insatisfeito';
      case 3:
        return 'Neutro';
      case 4:
        return 'Satisfeito';
      case 5:
        return 'Muito Satisfeito';
      default:
        return 'Toque nas estrelas para avaliar';
    }
  }

  bool _isFormValid() {
    return _productRating > 0 && _serviceRating > 0 && _deliveryRating > 0;
  }

  Future<void> _submitEvaluation() async {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, avalie todos os aspectos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ID do pedido não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final averageRating = (_productRating + _serviceRating + _deliveryRating) / 3.0;

      final success = await _orderService.addOrderRating(
        _orderId!,
        averageRating,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Avaliação enviada com sucesso!'),
            backgroundColor: Color.fromRGBO(84, 157, 115, 1.0),
          ),
        );

        // Navigate back to the previous screen
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar avaliação. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar avaliação: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildOrderInfo() {
    if (_order == null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(84, 157, 115, 1.0)),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag,
                color: Color.fromRGBO(84, 157, 115, 1.0),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Pedido ${_order!.orderNumber}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Total: €${_order!.total.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            '${_order!.totalItems} item${_order!.totalItems != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Avaliar Pedido',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review,
                    size: 48,
                    color: Color.fromRGBO(84, 157, 115, 1.0),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Como foi sua experiência?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sua opinião é muito importante para nós',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Order information
            _buildOrderInfo(),

            _buildStarRating(
              'Qualidade dos Produtos',
              'Frescura, sabor e variedade',
              _productRating,
                  (rated) {
                setState(() {
                  _productRating = rated;
                });
              },
            ),
            _buildStarRating(
              'Atendimento',
              'Cordialidade e suporte ao cliente',
              _serviceRating,
                  (rated) {
                setState(() {
                  _serviceRating = rated;
                });
              },
            ),
            _buildStarRating(
              'Entrega',
              'Pontualidade e cuidado no transporte',
              _deliveryRating,
                  (rated) {
                setState(() {
                  _deliveryRating = rated;
                });
              },
            ),
            Container(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitEvaluation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid()
                      ? Color.fromRGBO(84, 157, 115, 1.0)
                      : Colors.grey[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting
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
                      'Enviando...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Enviar Avaliação',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}