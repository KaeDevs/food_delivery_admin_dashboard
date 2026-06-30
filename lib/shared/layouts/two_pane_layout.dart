import 'package:flutter/material.dart';

class TwoPaneLayout extends StatelessWidget {
  final Widget listPane;
  final Widget? detailPane;
  final double splitRatio;

  const TwoPaneLayout({
    super.key,
    required this.listPane,
    this.detailPane,
    this.splitRatio = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLarge = width >= 1200;

    if (!isLarge || detailPane == null) {
      return listPane;
    }

    return Row(
      children: [
        SizedBox(
          width: (width - 240) * splitRatio, // Subtract nav rail width
          child: listPane,
        ),
        VerticalDivider(
          width: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(child: detailPane!),
      ],
    );
  }
}
