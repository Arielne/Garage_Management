
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() => context.read<InventoryProvider>().fetchParts());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Kho Phụ Tùng')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.parts.length,
              itemBuilder: (context, index) {
                final part = provider.parts[index];
                return ListTile(
                  title: Text(part.name),
                  subtitle: Text('Tồn kho: ${part.stockQty} | Giá: ${part.price}đ'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: () {}),

                      IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () {}),
                    ],
                  ),
                );
              },
            ),
    );
  }
}