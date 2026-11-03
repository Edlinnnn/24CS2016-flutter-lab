import 'package:flutter/material.dart';

void main() {
  runApp(const ProductSearchApp());
}

class ProductSearchApp extends StatelessWidget {
  const ProductSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const ProductSearchPage(),
    );
  }
}

// Model class for a product
class Product {
  final String name;
  final String category;
  final double price;
  final IconData icon;

  const Product(this.name, this.category, this.price, this.icon);
}

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  // Predefined list of products
  final List<Product> _products = const [
    Product('Laptop', 'Electronics', 55000, Icons.laptop),
    Product('Smartphone', 'Electronics', 18000, Icons.smartphone),
    Product('Headphones', 'Electronics', 2500, Icons.headphones),
    Product('Smart Watch', 'Electronics', 4999, Icons.watch),
    Product('Notebook', 'Stationery', 60, Icons.menu_book),
    Product('Ball Pen', 'Stationery', 20, Icons.edit),
    Product('Calculator', 'Stationery', 750, Icons.calculate),
    Product('Backpack', 'Accessories', 1200, Icons.backpack),
    Product('Water Bottle', 'Accessories', 350, Icons.local_drink),
    Product('Sunglasses', 'Accessories', 999, Icons.wb_sunny),
    Product('T-Shirt', 'Clothing', 499, Icons.checkroom),
    Product('Sneakers', 'Clothing', 2999, Icons.directions_run),
  ];

  final List<String> _categories = const [
    'All',
    'Electronics',
    'Stationery',
    'Accessories',
    'Clothing',
  ];

  String _searchText = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // Listen to every change in the search field
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter products by search text and selected category
    final List<Product> filteredProducts = _products.where((product) {
      final matchesText = product.name.toLowerCase().contains(_searchText);
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      return matchesText && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Search',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Products',
                hintText: 'Enter product name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Category filter chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                return ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            Text(
              '${filteredProducts.length} product(s) found',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),

            // Product list or empty message
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey.shade500),
                          const SizedBox(height: 12),
                          const Text(
                            'No products found',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple.shade50,
                              child: Icon(product.icon, color: Colors.deepPurple),
                            ),
                            title: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(product.category),
                            trailing: Text(
                              '₹${product.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple,
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