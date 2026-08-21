

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  bool _isVisible = true;
  Offset position = const Offset(150, 400); // initial position for draggable panda

  bool get isAnimating => _controller.isAnimating;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.7),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _syncAnimation();
  }

  void _syncAnimation() {
    if (!mounted) return;

    final shouldAnimate = _isVisible && !isHoldingOn;

    if (shouldAnimate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!shouldAnimate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  void setVisible(bool visible) {
  if (!mounted) return;
  if (_isVisible == visible) return;

  setState(() => _isVisible = visible);
  _syncAnimation();
}

  void handleVisibilityChanged(VisibilityInfo info) {
    setVisible(info.visibleFraction > 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const ValueKey('animated_panda_visibility'),
      onVisibilityChanged: handleVisibilityChanged,
      child: Stack(
        children: [
          if (!isHoldingOn)
            Align(
              alignment: Alignment.bottomCenter,
              child: RepaintBoundary(
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: GestureDetector(
                    onTap: () {
  if (!mounted) return;
  setState(() => isHoldingOn = true);
  _syncAnimation();
},
                    child: Image.asset(
                      'lib/assets/images/panda_normal.webp',
                      width: 120,
                      cacheHeight: 240,
                      cacheWidth: 240,
                    ),
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
                    _syncAnimation();
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    position += details.delta;
                  });
                },
                child: Image.asset(
                  'lib/assets/images/panda_hold.webp',
                  width: 120,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
