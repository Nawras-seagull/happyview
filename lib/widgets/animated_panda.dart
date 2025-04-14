

import 'package:flutter/material.dart';

class AnimatedPanda extends StatefulWidget {
  const AnimatedPanda({super.key});

  @override
  AnimatedPandaState createState() => AnimatedPandaState();
}

class AnimatedPandaState extends State<AnimatedPanda>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  bool isHoldingOn = false;
  Offset position = const Offset(150, 400); // initial position for draggable panda

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.7),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!isHoldingOn)
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _offsetAnimation,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isHoldingOn = true;
                  });
                },
                child: Image.asset(
                  'lib/assets/images/panda_normal.png',
                  width: 120,
                ),
              ),
            ),
          ),
        if (isHoldingOn)
          Positioned(
            left: position.dx,
            top: position.dy,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isHoldingOn = false;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  position += details.delta;
                });
              },
              child: Image.asset(
                'lib/assets/images/panda_hold.png',
                width: 120,
              ),
            ),
          ),
      ],
    );
  }
}
