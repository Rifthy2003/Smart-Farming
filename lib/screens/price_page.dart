import 'package:flutter/material.dart';

class PricePage extends StatelessWidget {
  const PricePage({super.key});

  final List<Map<String, dynamic>> marketData = const [
    {"crop": "Rice", "price": "145.00", "trend": "up", "unit": "kg"},
    {"crop": "Corn", "price": "98.50", "trend": "down", "unit": "kg"},
    {"crop": "Tomato", "price": "210.00", "trend": "up", "unit": "kg"},
    {"crop": "Potato", "price": "120.00", "trend": "stable", "unit": "kg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Current Market Prices"),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: marketData.length,
        itemBuilder: (context, index) {
          final item = marketData[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.shopping_basket, color: Colors.white)),
              title: Text(item['crop'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Per ${item['unit']}"),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Rs. ${item['price']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Icon(
                    item['trend'] == 'up' ? Icons.trending_up : Icons.trending_down,
                    color: item['trend'] == 'up' ? Colors.red : Colors.green,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}