class Product {
  final String id;
  final String name;
  final double price;
  final int quantity;

  Product({required this.id, required this.name, required this.price, required this.quantity});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price, 'quantity': quantity};
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'], name: json['name'], price: json['price'], quantity: json['quantity']
  );
}
