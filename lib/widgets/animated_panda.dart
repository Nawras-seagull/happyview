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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
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
    return Container(
      alignment: Alignment.bottomCenter,  // Center alignment
      width: double.infinity,  // Takes full width to enable center alignment
      child: SlideTransition(
        position: _offsetAnimation,
        child: Image.asset(
          'lib/assets/images/panda_peek.png',
          width: 80,
        ),
      ),
    );
  }
}