enum SellerManagedTruffleStatus {
  publishing('publishing'),
  active('active'),
  reserved('reserved'),
  sold('sold'),
  expired('expired');

  const SellerManagedTruffleStatus(this.dbValue);

  final String dbValue;

  bool get isInteractive => this == SellerManagedTruffleStatus.active;

  static SellerManagedTruffleStatus fromDbValue(String value) {
    final normalized = value.trim().toLowerCase();

    return SellerManagedTruffleStatus.values.firstWhere(
      (status) => status.dbValue == normalized,
      orElse: () {
        throw FormatException(
          'Unsupported seller managed truffle status: $value',
        );
      },
    );
  }
}
