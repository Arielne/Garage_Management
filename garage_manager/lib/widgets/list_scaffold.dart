import 'package:flutter/material.dart';

class ListScaffold extends StatelessWidget {
  const ListScaffold({
    super.key,
    this.header,
    required this.children,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget? header;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding,
      children: [
        if (header != null) ...[header!, const SizedBox(height: 16)],
        ...children,
      ],
    );
  }
}
