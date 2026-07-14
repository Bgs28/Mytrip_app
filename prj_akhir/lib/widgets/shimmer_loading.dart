// lib/widgets/shimmer_loading.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShimmerMask(value: _controller.value, child: widget.child);
      },
    );
  }
}

class ShimmerMask extends StatelessWidget {
  final double value;
  final Widget child;

  const ShimmerMask({super.key, required this.value, required this.child});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: const [Colors.grey, Colors.white, Colors.grey],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment(-1.0 + value * 2, 0),
          end: Alignment(1.0 + value * 2, 0),
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: child,
    );
  }
}
