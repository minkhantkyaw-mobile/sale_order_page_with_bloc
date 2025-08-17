import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_price_list/product_price_list_bloc.dart';
import '../bloc/product_price_list/product_price_list_event.dart';
import '../models/product_model.dart';
import '../models/product_unit_model.dart';
import '../models/product_price_list_model.dart';

class ProductPriceListFormDialog extends StatefulWidget {
  final ProductPriceListModel? pricelist;
  final List<Product> products;
  final List<Unit> units;

  const ProductPriceListFormDialog({
    super.key,
    this.pricelist,
    required this.products,
    required this.units,
  });

  @override
  State<ProductPriceListFormDialog> createState() => _ProductPriceListFormDialogState();
}

class _ProductPriceListFormDialogState extends State<ProductPriceListFormDialog> {
  late Product? selectedProduct;
  late Unit? selectedUnit;
  late TextEditingController priceController;
  late TextEditingController factorController;

  @override
  void initState() {
    super.initState();

    selectedProduct = widget.pricelist != null
        ? widget.products.firstWhere((p) => p.id == widget.pricelist!.productId)
        : widget.products.isNotEmpty
        ? widget.products.first
        : null;

    selectedUnit = widget.pricelist != null
        ? widget.units.firstWhere((u) => u.id == widget.pricelist!.unitId)
        : widget.units.isNotEmpty
        ? widget.units.first
        : null;

    priceController =
        TextEditingController(text: widget.pricelist?.price.toString() ?? '');
    factorController =
        TextEditingController(text: widget.pricelist?.factor.toString() ?? '1');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(widget.pricelist == null ? 'Add Price' : 'Edit Price'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Product>(
              value: selectedProduct,
              decoration: const InputDecoration(
                  labelText: 'Product', border: OutlineInputBorder()),
              items: widget.products
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                  .toList(),
              onChanged: (val) => setState(() => selectedProduct = val),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Unit>(
              value: selectedUnit,
              decoration: const InputDecoration(
                  labelText: 'Unit', border: OutlineInputBorder()),
              items: widget.units
                  .map((u) => DropdownMenuItem(value: u, child: Text(u.name)))
                  .toList(),
              onChanged: (val) => setState(() => selectedUnit = val),
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
                id: widget.pricelist?.id ?? DateTime.now().millisecondsSinceEpoch,
                productId: selectedProduct!.id!,
                unitId: selectedUnit!.id!,
                price: double.tryParse(priceController.text) ?? 0,
                factor: double.tryParse(factorController.text) ?? 1,
              );

              if (widget.pricelist == null) {
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
    );
  }
}
