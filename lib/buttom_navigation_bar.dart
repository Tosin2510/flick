import 'package:flick/history_screen.dart';
import 'package:flick/receive_screen.dart';
import 'package:flick/send_screen.dart';
import 'package:flick/settings_screen.dart';
import 'package:flutter/material.dart';

class ButtomNavBar extends StatefulWidget {
  final int initialIndex;

  const ButtomNavBar({super.key, this.initialIndex = 0});

  @override
  State<ButtomNavBar> createState() => _ButtomNavBarState();
}

class _ButtomNavBarState extends State<ButtomNavBar> {
  late int currentlySelectedIndex;
  @override
  void initState() {
    super.initState();
    currentlySelectedIndex = widget.initialIndex;
  }
    @override
    Widget build(BuildContext context) {

      final double screenWidth = MediaQuery.of(context).size.width;

      final List<Widget> screens = [
        const SendScreen(),
        const ReceiveScreen(),
        const HistoryScreen(),
        const SettingsScreen(),
      ];

      return Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: screens[currentlySelectedIndex],
        bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.09,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: Color(0xFF000000),
          border: Border(
            top: BorderSide(
              color: Color(0xFF2C2C2C),
              width: 1.0
            )
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildNavBarItem("Send", Icons.send_rounded, 0, screenWidth),
            buildNavBarItem("Receive", Icons.download_rounded, 1, screenWidth),
            buildNavBarItem("History", Icons.history_rounded, 2, screenWidth),
            buildNavBarItem("Settings", Icons.settings_rounded, 3, screenWidth)
          ]
        )
        )
      );
    }


    Widget buildNavBarItem(String title, IconData icon, int index, double screenWidth) {
      final bool isSelected = currentlySelectedIndex == index;

      return GestureDetector(
        onTap: () {
          setState(() {
            currentlySelectedIndex = index;
          });
        },

        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: screenWidth / 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                
                icon,
                color: isSelected ? const Color(0xFF258CF4) : const Color(0xFF9DA6B9),
                size: screenWidth * 0.065,
              ),

              const SizedBox(height: 4,),

              Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF258CFA) : const Color(0xFF9DA6B9),
                  fontSize: screenWidth * 0.03,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                )
              )
            ]
          )
        )
      );
    }
  }
