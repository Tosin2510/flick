import 'package:flutter/material.dart';

class IconBut extends StatelessWidget {
  final String title;
  final IconData icon;
  final double sizeOfContainer;
  final VoidCallback onPressed;

   const IconBut({
    super.key,
    required this.title,
    required this.icon,
    required this.sizeOfContainer,
    required this.onPressed,
  });

  @override

  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(48),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(48),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.03),
              width: 1.0,       
            )
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: sizeOfContainer * 0.15,),
              SizedBox(height: sizeOfContainer * 0.05),

              Text(
                title,
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: sizeOfContainer * 0.07,
                  fontWeight: FontWeight.w400,
                )
              )
            ]
          )
        )
      )
    );
  }
}