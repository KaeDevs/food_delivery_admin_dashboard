import 'package:flutter/material.dart';

class LoadingShimmer extends StatefulWidget {
  final int count;
  final double height;
  final double? width;

  const LoadingShimmer({
    super.key,
    this.count = 5,
    this.height = 48,
    this.width,
  });

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    _colorAnimation = ColorTween(
      begin: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      end: theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, _) {
        return Column(
          children: List.generate(widget.count, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                height: widget.height,
                width: widget.width ?? double.infinity,
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class ShimmerCard extends StatefulWidget {
  const ShimmerCard({super.key});

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    _colorAnimation = ColorTween(
      begin: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      end: theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, _) {
        return Container(
          height: 120,
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}
