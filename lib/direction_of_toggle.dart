import 'package:flick/send_or_receive_toggle_direction.dart';
import 'package:flutter/material.dart';

class DirectionOfToggle extends StatelessWidget {
  final SendOrReceiveToggleDirection active;
  final ValueChanged<SendOrReceiveToggleDirection> onChanged;
  const DirectionOfToggle({super.key, required this.active, required this.onChanged });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const  EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          // To be done.
        ]
      )
    );
  }

  Widget sendAndReceiveTab(String value, SendOrReceiveToggleDirection direction) {
    final bool isActive = active == direction;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          onChanged(direction);
        },

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF258CFA) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),

          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            )
          )
        )
      )
    );
  }
}