class BuySubscriptionRequest {
  String? type;
  String? receipt;
  String? planPrice;

  BuySubscriptionRequest({this.type, this.receipt, this.planPrice});

  BuySubscriptionRequest.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    receipt = json['receipt'];
    planPrice = json['plan_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['receipt'] = receipt;
    data['plan_price'] = planPrice;
    return data;
  }
}
