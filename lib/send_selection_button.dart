import 'package:flutter/material.dart';

class SendSelectionButton extends StatelessWidget {

  final String buttonTitle;
  final IconData buttonIcon;
  final double sizeOfContainer;
  final bool isSelected;
  final VoidCallback onPressed;
  final Color activeButtonColor;
  final Color inactiveButtonColor;
  final Color inactiveTextColor;

  const SendSelectionButton({
    super.key,
    required this.buttonTitle,
    required this.buttonIcon,
    required this.sizeOfContainer,
    required this.isSelected,
    required this.onPressed,
    required this.activeButtonColor,
    required this.inactiveButtonColor,
    required this.inactiveTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Column(
          children: [
            Container(
               width: sizeOfContainer * 0.35,
              height: sizeOfContainer * 0.35,
              decoration: BoxDecoration(
                color: isSelected ? activeButtonColor : inactiveButtonColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black),
              ),

              child: Center(
                child: Icon(
                  buttonIcon,
                  color: Colors.white.withValues(alpha: isSelected? 1.0 : 0.6),
                  size: sizeOfContainer * 0.14,
                )
              )
            ),

            const SizedBox(height: 8,),
            Text(
              buttonTitle,
              style: TextStyle(
                color: isSelected ? activeButtonColor : inactiveButtonColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12
              )
            )
            ]
          )
        )
      );
  }
}