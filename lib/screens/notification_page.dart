import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alerts & Notifications"), backgroundColor: Colors.orange[700]),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: const [
          _NotifyItem(title: "Low Moisture", msg: "Soil moisture in Sector A is 20%", type: "alert"),
          _NotifyItem(title: "Market Update", msg: "Tomato prices increased by 10%", type: "info"),
          _NotifyItem(title: "Weather Warning", msg: "Heavy rain expected tomorrow", type: "warning"),
        ],
      ),
    );
  }
}

class _NotifyItem extends StatelessWidget {
  final String title, msg, type;
  const _NotifyItem({required this.title, required this.msg, required this.type});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: type == "alert" ? Colors.red[50] : Colors.white,
      child: ListTile(
        leading: Icon(
          type == "alert" ? Icons.warning : Icons.info,
          color: type == "alert" ? Colors.red : Colors.blue,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(msg),
        trailing: const Text("2m ago", style: TextStyle(fontSize: 10)),
      ),
    );
  }
}