import 'package:flutter/material.dart';
import 'database_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Fetch products from SQLite
  Future<void> _loadProducts() async {
    final db = await DatabaseHelper.instance.database;
    final products = await db.query('products');
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  // Toggle product availability (Vendor feature)
  Future<void> _toggleAvailability(int id, int currentStatus) async {
    int newStatus = currentStatus == 1 ? 0 : 1;
    await DatabaseHelper.instance.updateProductAvailability(id, newStatus == 1);
    _loadProducts(); // Refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin / Vendor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Canteen Menu & Merchandise Inventory',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        bool isAvailable = product['is_available'] == 1;

                        return Card(
                          child: ListTile(
                            title: Text(product['name']),
                            subtitle: Text(
                                '${product['category']} - ₱${product['price']} | Stock: ${product['stock']}'),
                            trailing: Switch(
                              value: isAvailable,
                              onChanged: (val) => _toggleAvailability(
                                product['id'],
                                product['is_available'],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}