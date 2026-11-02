import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ListViewDemo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text(
            'Custom List View',
            style: TextStyle(letterSpacing: 10, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: const [
            MyListItem(
              fruitname: 'Apple',
              description: 'Fresh red apples from Kashmir',
              price: 180,
              unit: 'kg',
              rating: 4.5,
              image: 'assets/images/apple.jpg',
            ),
            MyListItem(
              fruitname: 'Banana',
              description: 'Ripe yellow bananas, rich in potassium',
              price: 60,
              unit: 'dozen',
              rating: 4.2,
              image: 'assets/images/banana.jpg',
            ),
            MyListItem(
              fruitname: 'Mango',
              description: 'Sweet Alphonso mangoes',
              price: 150,
              unit: 'kg',
              rating: 4.8,
              image: 'assets/images/mango.jpg',
            ),
            MyListItem(
              fruitname: 'Orange',
              description: 'Juicy Nagpur oranges, full of Vitamin C',
              price: 120,
              unit: 'kg',
              rating: 4.3,
              image: 'assets/images/orange.jpg',
            ),
            MyListItem(
              fruitname: 'Grapes',
              description: 'Seedless green grapes',
              price: 90,
              unit: 'kg',
              rating: 4.0,
              image: 'assets/images/grapes.jpg',
            ),
            MyListItem(
              fruitname: 'Strawberry',
              description: 'Farm-fresh Mahabaleshwar strawberries',
              price: 250,
              unit: 'box',
              rating: 4.6,
              image: 'assets/images/strawberry.jpg',
            ),
          ],
        ),
      ),
    );
  }
}

class MyListItem extends StatelessWidget {
  final String fruitname;
  final String description;
  final double price;
  final String unit;
  final double rating;
  final String image;

  const MyListItem({
    super.key,
    required this.fruitname,
    required this.description,
    required this.price,
    required this.unit,
    required this.rating,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final priceText = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(price);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$fruitname selected – $priceText / $unit')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Fruit image from assets
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  image,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.green.shade100,
                    child: const Icon(Icons.image_not_supported, color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Fruit details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fruitname,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(rating.toStringAsFixed(1)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$priceText / $unit',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // Add-to-cart button
              IconButton(
                icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$fruitname added to cart')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}