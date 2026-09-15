enum OrderStatusEnum {
  pending('pending'),
  shipped('shipped'),
  accepted('accepted'),
  completed('completed'),
  cancelled('cancelled'),
  declined('declined');

  final String value;

  const OrderStatusEnum(this.value);
}
