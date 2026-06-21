import 'package:flutter/material.dart';

import 'primary_button.dart';

class FormScaffold extends StatelessWidget {
  const FormScaffold({
    super.key,
    required this.children,
    required this.submitLabel,
    required this.onSubmit,
    this.padding = const EdgeInsets.all(16),
  });

  final List<Widget> children;
  final String submitLabel;
  final VoidCallback? onSubmit;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding,
      children: [
        ...children,
        const SizedBox(height: 24),
        PrimaryButton(label: submitLabel, onPressed: onSubmit),
      ],
    );
  }
}
