import 'package:flick/action_icon_button.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 700;
    final double sizeOfContainer = (size.width * 0.6).clamp(180.0, 300.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.05),

                  SizedBox(height: isSmallScreen ? 20 : 40,),

                  Text(
                    'Flick',
                    style: TextStyle(
                      color: const Color(0xFFCBD5E1),
                      fontSize: sizeOfContainer * 0.075,
                      fontWeight: FontWeight.w400,
                    )
                  ),

                  SizedBox(height: (size.height * 0.08).clamp(20.0, 80.0)),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: size.width * 0.04,
                      mainAxisSpacing: size.width * 0.04,
                      childAspectRatio: 1.1,

                      children: [

                        ActionIconButton(
                          title: "Send",
                          icon: Icons.near_me_outlined,
                          sizeOfContainer: sizeOfContainer,
                          onPressed: () {
                            // To be implemented
                          }
                        ),

                        ActionIconButton(
                          title: "Receive",
                          icon: Icons.file_download_outlined,
                          sizeOfContainer: sizeOfContainer,
                          onPressed: () {
                            // To be implemented
                          }
                        ),
                        ActionIconButton(
                          title: "History",
                          icon: Icons.history_rounded,
                          sizeOfContainer: sizeOfContainer,
                          onPressed: () {
                            // To be implemented
                          }
                        ),

                        ActionIconButton(
                          title: "Settings",
                          icon: Icons.settings_outlined,
                          sizeOfContainer: sizeOfContainer,
                          onPressed: () {
                            // To be implemented
                          }
                        ),
                      ]
                    )
                  )
                ]
              )
            )
          )
        )
      )
    );
  }
}