import 'package:flutter/material.dart';

class CropPage extends StatelessWidget {
  const CropPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Crops"), backgroundColor: Colors.green[600]),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildCropCard(context, "Rice", "Stage: Harvesting", "assets/rice.png"),
          _buildCropCard(context, "Wheat", "Stage: Growing", "assets/wheat.png"),
          _buildCropCard(context, "Chili", "Stage: Seedling", "assets/chili.png"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCropCard(BuildContext context, String name, String stage, String img) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco, size: 50, color: Colors.green),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(stage, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}