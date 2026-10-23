import 'package:flick/direction_of_toggle.dart';
import 'package:flick/send_or_receive_toggle_direction.dart';
import 'package:flutter/material.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  static bool isVisible = false;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends  State<ProgressScreen> {
   SendOrReceiveToggleDirection activeTab = SendOrReceiveToggleDirection.received;

  @override
  void initState() {
    super.initState();

    ProgressScreen.isVisible = true;
  }

  @override
  void dispose() {
    ProgressScreen.isVisible = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
         child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,

            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.maybePop(context);
                    },

                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                  ),

                  const SizedBox(width: 8),

                  const Text(
                    'Transferring',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ]
              ),

              const SizedBox(height: 16,),

              DirectionOfToggle(
                active: activeTab,
                onChanged: (direction) => setState(() =>  activeTab = direction),
              ),

              const SizedBox(height: 16),

              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(10),
               child: Stack(
                children: [
                  Container(
                    height: 32,
                    color: const Color(0xFF1F1F1F)
                  ),

                  FractionallySizedBox(
                    widthFactor: 0.5, // To be replaced.
                    child: Container(
                      height: 32,
                      color: const Color(0xFF258CFA)
                    )
                  ),

                  Positioned.fill(
                    child: Padding(
                      padding:  const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),

                          Text(
                            '', // To be replaced.
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )
                          )
                        ]
                      )
                    )
                  )
                ]
               )
              ),

              const SizedBox(height: 16,),
            ]
          )
         ),

      )
    );
  }
}