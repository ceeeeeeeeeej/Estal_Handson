import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class ProductService {
  static const String _key = 'products';
  
  // CREATE
  static Future<Product> create(String name, double price, int quantity) async {
    final products = await getAll();
    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name, price: price, quantity: quantity
    );
    products.add(product);
    await _save(products);
    return product;
  }
  
  // READ
  static Future<List<Product>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.map((json) => Product.fromJson(jsonDecode(json))).toList();
  }
  
  // UPDATE
  static Future<bool> update(Product product) async {
    final products = await getAll();
    final index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      products[index] = product;
      await _save(products);
      return true;
    }
    return false;
  }
  
  // DELETE
  static Future<bool> delete(String id) async {
    final products = await getAll();
    products.removeWhere((p) => p.id == id);
    await _save(products);
    return true;
  }
  
  static Future<void> _save(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = products.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }
}
