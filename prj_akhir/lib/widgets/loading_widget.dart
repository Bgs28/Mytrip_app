// lib/widgets/loading_widget.dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class LoadingWidget extends StatelessWidget {
  final bool isFullScreen;
  final String? message;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.isFullScreen = false,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppTheme.primaryBlue,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.grey),
          ),
        ],
      ],
    );

    if (isFullScreen) {
      return Scaffold(
        backgroundColor: AppTheme.white.withOpacity(0.9),
        body: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

// Shimmer Loading untuk Card
class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Shimmer(child: child);
  }
}

// Simple Shimmer Widget (tanpa package)
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
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
