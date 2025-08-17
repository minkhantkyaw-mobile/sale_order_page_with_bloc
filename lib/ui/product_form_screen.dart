import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:sale_order_project/bloc/product_unit/product_unit_bloc.dart';
import 'package:sale_order_project/bloc/product_unit/product_unit_state.dart';
import 'package:sale_order_project/ui/product_category_screen.dart';
import 'package:sale_order_project/ui/product_list_screen.dart';
import 'package:sale_order_project/ui/product_price_list_screen.dart';
import 'package:sale_order_project/ui/product_unit_screen.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../bloc/product_category/product_category_bloc.dart';
import '../bloc/product_category/product_category_state.dart';
import '../models/product_category_model.dart';
import '../models/product_model.dart';
import '../models/product_unit_model.dart';
import '../widgets/navigation_button.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController qtyCtrl;

  List<ProductCategory> categories = [];
  List<Unit> units = [];
  ProductCategory? selectedCategory;
  Unit? selectedUnit;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.product?.name.toString() ?? '');
    priceCtrl = TextEditingController(text: widget.product?.price.toString() ?? '');
    qtyCtrl = TextEditingController(text: widget.product?.onHandQty.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product',
        style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,

        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  // Product Name
                  TextFormField(
                    key: ValueKey(nameCtrl.text),
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      prefixIcon: const Icon(Icons.shopping_bag),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter product name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  BlocBuilder<ProductCategoryBloc, ProductCategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is CategoryLoaded) {
                        final categories = state.categories;

                        return DropdownButtonFormField<ProductCategory>(
                          value: categories.any((c) => c.id == selectedCategory?.id)
                              ? selectedCategory
                              : null,
                          items: categories
                              .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.name),
                          ))
                              .toList(),
                          onChanged: (val) => setState(() => selectedCategory = val),
                          decoration: InputDecoration(
                            labelText: 'Category',
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (value) =>
                          value == null ? 'Please select category' : null,
                        );
                      } else if (state is CategoryError) {
                        return Text("Error: ${state.message}");
                      }
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(height: 16),

                  //  Unit Dropdown
                  BlocBuilder<UnitBloc, UnitState>(
                    builder: (context, state) {
                      if (state is UnitLoading) {
                        return  Center(child: CircularProgressIndicator());
                      } else if (state is UnitLoaded) {
                        final units = state.units;

                        return DropdownButtonFormField<Unit>(
                          value: units.any((c) => c.id == selectedUnit?.id)
                              ? selectedUnit
                              : null,
                          items: units
                              .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.name),
                          ))
                              .toList(),
                          onChanged: (val) => setState(() => selectedUnit = val),
                          decoration: InputDecoration(
                            labelText: 'Unit',
                            prefixIcon: const Icon(Icons.straighten),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (value) =>
                          value == null ? 'Please select Unit' : null,
                        );
                      } else if (state is UnitError) {
                        return Text("Error: ${state.message}");
                      }
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Price
                  TextFormField(
                    controller: priceCtrl,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Quantity
                  TextFormField(
                    controller: qtyCtrl,
                    decoration: InputDecoration(
                      labelText: 'On-Hand Quantity',
                      prefixIcon: const Icon(Icons.inventory_2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {

                        if (_formKey.currentState!.validate()) {
                          final product = Product(
                            id: widget.product?.id,
                            name: nameCtrl.text,
                            categoryId: selectedCategory!.id,
                            unitId: selectedUnit!.id,
                            price: double.tryParse(priceCtrl.text) ?? 0,
                            onHandQty: double.tryParse(qtyCtrl.text) ?? 0,
                          );

                          if (widget.product == null) {
                            context.read<ProductBloc>().add(AddProduct(product));
                          } else {
                            context.read<ProductBloc>().add(UpdateProductEvent(product));
                          }

                          ///snackbar
                          Get.snackbar(
                            "Success",
                            widget.product == null
                                ? "Product added successfully!"
                                : "Product updated successfully!",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green.shade600,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(12),
                            borderRadius: 12,
                          );



                          /// Reset dropdowns
                          setState(() {
                            nameCtrl = TextEditingController(); // reset controller
                            priceCtrl.clear();
                            qtyCtrl.clear();
                            selectedCategory = null;
                            selectedUnit = null;
                          });

                          _formKey.currentState!.reset();
                        }

                      },
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'Save Product',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Navigation Buttons
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      NavigationButton(
                        icon: Icons.list,
                        label: "Product List",
                        page: ProductListScreen(),
                      ),
                      const NavigationButton(
                        icon: Icons.category,
                        label: "Categories",
                        page: ProductCategoryScreen(),
                      ),
                      const NavigationButton(
                        icon: Icons.straighten,
                        label: "Units",
                        page: UnitPage(),
                      ),
                      const NavigationButton(
                        icon: Icons.price_change,
                        label: "Price List",
                        page: ProductPriceListScreen(),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
