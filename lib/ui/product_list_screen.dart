import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:sale_order_project/services/db_service.dart';
import 'package:sale_order_project/ui/product_form_screen.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../../bloc/product/product_state.dart';
import '../models/product_category_model.dart';
import '../models/product_unit_model.dart';
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  Map<int, String> categoryNames = {}; // categoryId -> categoryName
  Map<int, String> unitNames = {}; // unitId -> unitName
  late final DBService dbService;

  @override
  void initState() {
    super.initState();
    dbService = DBService();
    _loadCategoriesAndUnit();

  }

  Future<void> _loadCategoriesAndUnit() async {
    //  categories
    final categoryMaps = await dbService.getCategories();
    final categories = categoryMaps.map((c) => ProductCategory.fromMap(c)).toList();

    setState(() {
      categoryNames = {for (var c in categories) c.id: c.name};
    });
    print("Categories: $categoryNames");
    print('${categoryNames[4] ?? '-'}');

    //  units
    final unitMaps = await dbService.getUnits();
    final units = unitMaps.map((u) => Unit.fromMap(u)).toList();

    setState(() {
      unitNames = {for (var u in units) u.id: u.name};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductLoaded) {
            if (state.products.isEmpty) {
              return const Center(
                child: Text('No products available', style: TextStyle(fontSize: 16)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final p = state.products[index];
                final categoryName = categoryNames[p.categoryId] ?? '-';
                final unitName = unitNames[p.unitId] ?? '-';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: Colors.grey.shade300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name,
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Chip(
                                    backgroundColor: Colors.green.shade100,
                                    label: Text('Price: ${p.price}',
                                        style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Chip(
                                    backgroundColor: Colors.orange.shade100,
                                    label: Text('Qty: ${p.onHandQty}',
                                        style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Chip(
                                    backgroundColor: Colors.blue.shade50,
                                    label: Text(
                                      'Category: ${categoryNames[p.categoryId] ?? '-'}',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Chip(
                                    backgroundColor: Colors.purple.shade50,
                                    label: Text(
                                      'Unit: ${unitNames[p.unitId] ?? '-'}',
                                      style: const TextStyle(
                                        color: Colors.purple,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),


                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ProductFormScreen(product: p)),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                context.read<ProductBloc>().add(DeleteProductEvent(p.id!));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          else if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message, // 👈 now using the actual error message
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // 👇 Trigger reload
                      context.read<ProductBloc>().add(LoadProducts());
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          else {
            return const Center(
              child: Text('Error loading products', style: TextStyle(color: Colors.red)),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         Get.offAll(() => ProductFormScreen());
        },
        child:  Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        tooltip: 'Add New Product',
      ),
    );
  }
}
