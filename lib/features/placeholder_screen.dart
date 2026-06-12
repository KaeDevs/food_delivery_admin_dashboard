import 'package:flutter/material.dart';
import '../../shared/widgets/empty_state.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyState(
        icon: icon,
        title: title,
        subtitle: description,
      ),
    );
  }
}
