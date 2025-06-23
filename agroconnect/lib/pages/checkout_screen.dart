import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget { // This class name is already CheckoutScreen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  _buildCheckoutSection('ENTREGAS', 'Adicionar morada'),
                  _buildDivider(),
                  _buildCheckoutSection('ENVIO', 'Grátis\nStandard | 3-4 dias'),
                  _buildDivider(),
                  _buildCheckoutSection('MÉTODO DE PAGAMENTO', 'Visa *1234'),
                  _buildDivider(),
                  _buildCheckoutSection('CÓDIGO PROMOCIONAL', 'Utilizar código'),
                  const SizedBox(height: 24.0),
                  Text(
                    'ITEMS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  _buildItemRow(
                    Image.asset("assets/beneficios-da-melancia_21634.webp", width: 80, height: 80, fit: BoxFit.cover),
                    'Quinta do Tio Manel\nMelâncias\nFresquinhas\nQuantidade: 01',
                    '€10.99',
                  ),
                  _buildItemRow(
                    Image.asset("assets/250px-Pears.jpg",width: 80, height: 80, fit: BoxFit.cover),
                    'Alfredo Pereiras\nPêras reais\nSaborosas\nQuantidade: 01',
                    '€8.99',
                  ),
                  const SizedBox(height: 24.0),
                  _buildSummaryRow('Subtotal (2)', '€19.98'),
                  _buildSummaryRow('Custos de entrega', 'Grátis'),
                  _buildSummaryRow('Taxas', '€2.00'),
                  const SizedBox(height: 8.0),
                  _buildSummaryRow('Total', '€21.98', isTotal: true),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
          _buildFinalizePurchaseButton(context),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          Row(
            children: [
              Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
              const SizedBox(width: 4.0),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[300]);
  }

  Widget _buildItemRow(Widget imageWidget, String description, String price) { // Changed parameter type to Widget
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: imageWidget, // Use the passed in imageWidget directly
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.black : Colors.grey[700],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? Colors.black : Colors.grey[800],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalizePurchaseButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement finalize purchase logic
          // For now, let's just navigate to the evaluation screen
          Navigator.pushNamed(context, '/evaluation'); // Add this line
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Colors.green,
        ),
        child: const Text(
          'Finalizar Compra',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}