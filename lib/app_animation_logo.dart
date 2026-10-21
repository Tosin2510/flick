import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppAnimationLogo extends StatefulWidget {
  final double sizeOfContainer;
  final bool isPreferenceAnimation;

  const AppAnimationLogo({
    super.key,
    required this.sizeOfContainer,
    this.isPreferenceAnimation = true,
  });

  @override
  State<AppAnimationLogo> createState() => _AppAnimationLogoState();
}

class _AppAnimationLogoState extends State<AppAnimationLogo> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> logoRotation;
  late Animation<double> pulseScale;
  late Animation<double> opacity;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    logoRotation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    pulseScale = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    opacity = Tween<double>(begin: 0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.1, 0.9, curve: Curves.linear),
      ),
    );

    if (widget.isPreferenceAnimation) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.sizeOfContainer,
      height: widget.sizeOfContainer,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (widget.isPreferenceAnimation)

              Transform.scale(
                scale: pulseScale.value,
                child: Container(
                  width: widget.sizeOfContainer * 0.6,
                  height: widget.sizeOfContainer * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF258CF4).withValues(alpha: opacity.value),
                    
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF258CFA).withValues(alpha: opacity.value),
                        blurRadius: widget.sizeOfContainer * 0.15,
                        spreadRadius: 5,
                      )
                    ]
                  )
                )
              ),

              Container(
                width: widget.sizeOfContainer * 0.7,
                height: widget.sizeOfContainer * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF000000).withValues(alpha: 0.5),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1.5,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF258CF4).withValues(alpha: 0.1),
                      blurRadius: 20,
                    ),
                  ],
                )
              ),

              Transform.rotate(
                angle: widget.isPreferenceAnimation ? logoRotation.value : 0,
                child: Icon(
                  Icons.swap_calls_rounded,
                  size: widget.sizeOfContainer * 0.25,
                  color: const Color(0xFF258CF4),
                )
              )
            ]
          );
        }
      )
    );
  }
}