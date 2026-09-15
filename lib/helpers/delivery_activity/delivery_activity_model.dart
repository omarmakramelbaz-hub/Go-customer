class DeliveryActivityModel {
  final String? orderStatus;
  final String? orderId;

  const DeliveryActivityModel({this.orderStatus, this.orderId});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (orderStatus != null) {
      map['order_status'] = orderStatus;
      map['orderStatus'] = orderStatus;
    }
    if (orderId != null && orderId!.trim().isNotEmpty) {
      map['order_id'] = orderId;
      map['orderId'] = orderId;
    }

    return map;
  }

  DeliveryActivityModel copyWith({String? orderStatus, String? orderId}) {
    return DeliveryActivityModel(
      orderStatus: orderStatus ?? this.orderStatus,
      orderId: orderId ?? this.orderId,
    );
  }
}
