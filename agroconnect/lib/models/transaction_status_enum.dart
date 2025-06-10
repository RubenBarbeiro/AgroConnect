enum TransactionStatusEnum {
  pending,     // Order placed, waiting for supplier confirmation
  confirmed,   // Supplier confirmed the order
  preparing,   // Supplier is preparing the order
  ready,       // Order ready for pickup/delivery
  delivered,   // Order delivered to client
  completed,   // Transaction completed successfully
  cancelled,   // Transaction cancelled
}