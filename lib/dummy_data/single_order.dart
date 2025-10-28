class SingleOrder { 
  String code;
  String date;
  String payment_status;
  String payment_status_string;
  String delivery_status;
  String delivery_status_string;
  String? payment_methood;
  String payment_method_string;
  String? shipping_method;
  String shipping_method_string;
  String shipping_address;
  String subtotal;
  String tax;
  String shipping_cost;
  String discount;
  String total;
  List<OrderedProduct> orderedProducts;

  SingleOrder(
      {required this.code,
      required this.date,
      required this.payment_status,
      required this.payment_status_string,
      required this.delivery_status,
      required this.delivery_status_string,
      this.payment_methood,
      required this.payment_method_string,
      this.shipping_method,
      required this.shipping_method_string,
      required this.shipping_address,
      required this.subtotal,
      required this.tax,
      required this.shipping_cost,
      required this.discount,
      required this.total,
      required this.orderedProducts });
}

class OrderedProduct { 
  String name;
  bool has_variant;
  String variant_string;
  String amount;
  int quantity;

  OrderedProduct(
      {required this.name,
      required this.has_variant,
      required this.variant_string,
      required this.amount,
      required this.quantity });
}

List<OrderedProduct> orderedProducts = [
  OrderedProduct(
      name:
          "iPhone 12 pro Max Pacific Blue 256 gb (without charger), 16 gb ram, Gorilla glass 6",
      has_variant: true,
      variant_string: "Rose Gold",
      amount: "\$1250.00",
      quantity: 1),
  OrderedProduct(
      name: "Baby Pink Dress 6",
      has_variant: true,
      variant_string: "Pink-SM-16",
      amount: "\$16925140.00",
      quantity: 125),
  OrderedProduct(
      name: "Studds Tough Motorcycle Helmet",
      has_variant: false,
      variant_string: "",
      amount: "\$16925140.00",
      quantity: 125),
];

SingleOrder singleOrder = SingleOrder(
    code: "20201215-12034564",
    date: "14-12-2020",
    payment_status: "paid",
    payment_status_string: "Paid",
    delivery_status: "pending",
    delivery_status_string: "Order Placed",
    shipping_address: "13th Street. 47 W 13th St, New York, NY 10011",
    shipping_method_string: "Flat Shipping Rate",
    payment_method_string: "Wallet",
    subtotal: "\$35,000.00",
    tax: "\$150.00",
    shipping_cost: "\$0.00",
    discount: "\$1.50",
    total: "\$16925140.00",
    orderedProducts: orderedProducts);
