import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await ProductService.getAll();
    setState(() => _products = products);
  }

  Future<void> _addProduct() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ProductDialog(),
    );
    if (result != null) {
      await ProductService.create(result['name'], result['price'], result['quantity']);
      _loadProducts();
    }
  }

  Future<void> _editProduct(Product product) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ProductDialog(product: product),
    );
    if (result != null) {
      final updated = Product(
        id: product.id,
        name: result['name'],
        price: result['price'],
        quantity: result['quantity'],
      );
      await ProductService.update(updated);
      _loadProducts();
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ProductService.delete(product.id);
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product CRUD'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: _products.isEmpty
          ? const Center(child: Text('No products\nTap + to add', textAlign: TextAlign.center))
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text('Price: \$${product.price} | Qty: ${product.quantity}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _editProduct(product)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteProduct(product)),
                    ]),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(onPressed: _addProduct, child: const Icon(Icons.add)),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final Product? product;
  const _ProductDialog({this.product});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _quantityController.text = widget.product!.quantity.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
        TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
        TextField(controller: _quantityController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty && _quantityController.text.isNotEmpty) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'price': double.parse(_priceController.text),
                'quantity': int.parse(_quantityController.text),
              });
            }
          },
          child: Text(widget.product == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
