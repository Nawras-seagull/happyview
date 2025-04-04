// A simple animated panda widget
import 'package:flutter/material.dart';

class AnimatedPanda extends StatefulWidget {
  @override
  _AnimatedPandaState createState() => _AnimatedPandaState();
}

class _AnimatedPandaState extends State<AnimatedPanda>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.2),
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Image.asset(
          'lib/assets/images/panda_peek.png', // Cute little panda face!
          width: 80,
        ),
      ),
    );
  }
}