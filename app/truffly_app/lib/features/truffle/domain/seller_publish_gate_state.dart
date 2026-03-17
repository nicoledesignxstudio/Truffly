enum SellerPublishGateStatus {
  loading,
  error,
  allowed,
  notAllowed,
}

final class SellerPublishGateState {
  const SellerPublishGateState._({
    required this.status,
    this.region,
  });

  const SellerPublishGateState.loading()
    : this._(status: SellerPublishGateStatus.loading);

  const SellerPublishGateState.error()
    : this._(status: SellerPublishGateStatus.error);

  const SellerPublishGateState.allowed({String? region})
    : this._(
        status: SellerPublishGateStatus.allowed,
        region: region,
      );

  const SellerPublishGateState.notAllowed()
    : this._(status: SellerPublishGateStatus.notAllowed);

  final SellerPublishGateStatus status;
  final String? region;

  bool get isLoading => status == SellerPublishGateStatus.loading;
  bool get isError => status == SellerPublishGateStatus.error;
  bool get isAllowed => status == SellerPublishGateStatus.allowed;
  bool get isNotAllowed => status == SellerPublishGateStatus.notAllowed;
}
