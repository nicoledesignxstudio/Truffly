enum SellerManagedTruffleStatus {
  active('active'),
  sold('sold'),
  expired('expired');

  const SellerManagedTruffleStatus(this.dbValue);

  final String dbValue;

  static SellerManagedTruffleStatus fromDbValue(String value) {
    return SellerManagedTruffleStatus.values.firstWhere(
      (status) => status.dbValue == value.trim().toLowerCase(),
      orElse: () => SellerManagedTruffleStatus.active,
    );
  }
}
