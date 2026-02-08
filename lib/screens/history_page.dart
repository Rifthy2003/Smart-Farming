import 'package:flutter/material.dart';
import 'database_helper.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SCAN HISTORY"), backgroundColor: Colors.greenAccent[400]),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().getHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final history = snapshot.data!;
          
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.green),
                title: Text(history[index]['name']),
                subtitle: Text("${history[index]['details']}\n${history[index]['date']}"),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}