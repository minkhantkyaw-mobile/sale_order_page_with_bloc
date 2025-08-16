import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sale_order_project/models/product_price_list_model.dart';

import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_state.dart';
import '../bloc/product_price_list/product_price_list_bloc.dart';
import '../bloc/product_price_list/product_price_list_event.dart';
import '../bloc/product_price_list/product_price_list_state.dart';
import '../bloc/product_unit/product_unit_bloc.dart';
import '../bloc/product_unit/product_unit_state.dart';
import '../models/product_model.dart';
import '../models/product_unit_model.dart';

class ProductPriceListScreen extends StatelessWidget {
  const ProductPriceListScreen({super.key});

  void _showFormDialog(BuildContext context,
      {ProductPriceListModel? pricelist,
        List<Product> products = const [],
        List<Unit> units = const []}) {
    Product? selectedProduct = pricelist != null
        ? products.firstWhere((p) => p.id == pricelist.productId)
        : products.isNotEmpty
        ? products[0]
        : null;

    Unit? selectedUnit = pricelist != null
        ? units.firstWhere((u) => u.id == pricelist.unitId)
        : units.isNotEmpty
        ? units[0]
        : null;

    final priceController =
    TextEditingController(text: pricelist?.price.toString() ?? '');
    final factorController =
    TextEditingController(text: pricelist?.factor.toString() ?? '1');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(pricelist == null ? 'Add Price' : 'Edit Price'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Product>(
                value: selectedProduct,
                decoration: const InputDecoration(
                    labelText: 'Product', border: OutlineInputBorder()),
                items: products
                    .map((p) =>
                    DropdownMenuItem(value: p, child: Text(p.name)))
                    .toList(),
                onChanged: (val) => selectedProduct = val,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Unit>(
                value: selectedUnit,
                decoration: const InputDecoration(
                    labelText: 'Unit', border: OutlineInputBorder()),
                items: units
                    .map((u) => DropdownMenuItem(value: u, child: Text(u.name)))
                    .toList(),
                onChanged: (val) => selectedUnit = val,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: factorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Factor',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (selectedProduct != null && selectedUnit != null) {
                final newPricelist = ProductPriceListModel(
                  id: pricelist?.id ?? DateTime.now().millisecondsSinceEpoch,
                  productId: selectedProduct!.id!,
                  unitId: selectedUnit!.id!,
                  price: double.tryParse(priceController.text) ?? 0,
                  factor: double.tryParse(factorController.text) ?? 1,
                );

                if (pricelist == null) {
                  context.read<ProductPricelistBloc>().add(AddPricelist(newPricelist));
                } else {
                  context.read<ProductPricelistBloc>().add(UpdatePricelist(newPricelist));
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Pricelist',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, productState) {
          final products = productState is ProductLoaded
              ? List<Product>.from(productState.products)
              : <Product>[];

          return BlocBuilder<UnitBloc, UnitState>(
            builder: (context, unitState) {
              final units = unitState is UnitLoaded
                  ? List<Unit>.from(unitState.units)
                  : <Unit>[];

              return BlocBuilder<ProductPricelistBloc, ProductPricelistState>(
                builder: (context, state) {
                  if (state is PricelistLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PricelistLoaded) {
                    if (state.pricelists.isEmpty) {
                      return const Center(
                        child: Text(
                          'No pricelist yet.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: state.pricelists.length,
                      itemBuilder: (context, index) {
                        final pricelist = state.pricelists[index];
                        final product = products.firstWhere(
                              (p) => p.id == pricelist.productId,
                          orElse: () => Product(
                              id: 0,
                              name: 'Unknown',
                              categoryId: 0,
                              unitId: 0,
                              price: 0,
                              onHandQty: 0),
                        );
                        final unit = units.firstWhere(
                              (u) => u.id == pricelist.unitId,
                          orElse: () => Unit(id: 0, name: 'Unknown'),
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            title: Text(
                              '${product.name} - ${unit.name}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                                'Price: \$${pricelist.price}, Factor: ${pricelist.factor}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showFormDialog(
                                    context,
                                    pricelist: pricelist,
                                    products: products,
                                    units: units,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    context
                                        .read<ProductPricelistBloc>()
                                        .add(DeletePricelist(pricelist.id!));
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is PricelistError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(
          context,
          products: (context.read<ProductBloc>().state is ProductLoaded)
              ? (context.read<ProductBloc>().state as ProductLoaded).products
              : [],
          units: (context.read<UnitBloc>().state is UnitLoaded)
              ? (context.read<UnitBloc>().state as UnitLoaded).units
              : [],
        ),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
        tooltip: 'Add Price',
      ),
    );
  }
}
