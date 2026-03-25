enum OrderStatus {
  paid('paid'),
  shipped('shipped'),
  completed('completed'),
  cancelled('cancelled');

  const OrderStatus(this.dbValue);

  final String dbValue;

  static OrderStatus fromDbValue(String value) {
    return values.firstWhere(
      (candidate) => candidate.dbValue == value,
      orElse: () => OrderStatus.paid,
    );
  }
}
