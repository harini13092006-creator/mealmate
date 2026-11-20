import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/grocery_item.dart';
import '../../core/responsive_layout.dart';
import 'groceries_view_model.dart';

class GroceriesScreen extends StatelessWidget {
  const GroceriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GroceriesViewModel>();
    final theme = Theme.of(context);

    // Group items by category
    final Map<String, List<GroceryItem>> grouped = {};
    for (final item in viewModel.items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    final checkedCount = viewModel.items.where((i) => i.isChecked).length;
    final totalCount = viewModel.items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Grocery List'),
        actions: [
          if (checkedCount > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear completed items',
              onPressed: () => viewModel.clearCompleted(),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveContent(
        maxWidth: 900,
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : viewModel.items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: 64,
                      color: theme.disabledColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your grocery list is empty',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add items manually or from any recipe page',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Item'),
                      onPressed: () => _showAddItemDialog(context, viewModel),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Progress banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$checkedCount of $totalCount items purchased',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: totalCount > 0
                                      ? (checkedCount / totalCount)
                                      : 0,
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      itemCount: grouped.keys.length,
                      itemBuilder: (context, catIndex) {
                        final category = grouped.keys.elementAt(catIndex);
                        final items = grouped[category]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                category,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            ...items.map((item) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: item.isChecked,
                                    onChanged: (_) =>
                                        viewModel.toggleItem(item.id),
                                  ),
                                  title: Text(
                                    item.name,
                                    style: TextStyle(
                                      decoration: item.isChecked
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: item.isChecked
                                          ? Colors.grey
                                          : null,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    item.recipeOrigin != null
                                        ? '${item.quantity} • For: ${item.recipeOrigin}'
                                        : item.quantity,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () =>
                                        viewModel.removeItem(item.id),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context, viewModel),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, GroceriesViewModel viewModel) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    String category = 'Produce';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Grocery Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Item name (e.g. Olive Oil)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity (e.g. 1 bottle, 500g)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Produce',
                          child: Text('Produce'),
                        ),
                        DropdownMenuItem(
                          value: 'Dairy & Eggs',
                          child: Text('Dairy & Eggs'),
                        ),
                        DropdownMenuItem(
                          value: 'Meat & Seafood',
                          child: Text('Meat & Seafood'),
                        ),
                        DropdownMenuItem(
                          value: 'Grains & Pasta',
                          child: Text('Grains & Pasta'),
                        ),
                        DropdownMenuItem(
                          value: 'Pantry',
                          child: Text('Pantry'),
                        ),
                        DropdownMenuItem(
                          value: 'General',
                          child: Text('General'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => category = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      viewModel.addItem(
                        name: nameController.text.trim(),
                        category: category,
                        quantity: quantityController.text.trim(),
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
