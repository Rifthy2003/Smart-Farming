import 'package:flutter/material.dart';

class CustomPillButton extends StatelessWidget {
  final String text;
  final Color? color;
  final VoidCallback? onTap; // Added so you can use it as a real button

  const CustomPillButton({
    super.key, 
    required this.text, 
    this.color, 
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        decoration: BoxDecoration(
          color: color ?? const Color.fromRGBO(129, 199, 132, 1), // Default green from your design
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 5.0,
            )
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 18,
            color: Colors.black,
            fontFamily: 'Serif', // Match your branding font
          ),
        ),
      ),
    );
  }
}