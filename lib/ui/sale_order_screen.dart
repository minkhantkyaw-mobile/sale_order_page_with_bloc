import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sale_order_project/ui/sale_order_history_screen.dart';
import '../bloc/sale_order/sale_order_bloc.dart';
import '../bloc/sale_order/sale_order_event.dart';
import '../bloc/sale_order/sale_order_state.dart';
import '../models/product_model.dart';
import '../models/product_category_model.dart';
import '../models/sale_order_line_model.dart';
import '../models/sale_order_model.dart';
import '../services/db_service.dart';
import '../models/product_price_list_model.dart';

class SaleOrderScreen extends StatefulWidget {
  const SaleOrderScreen({super.key});

  @override
  _SaleOrderScreenState createState() => _SaleOrderScreenState();
}

class _SaleOrderScreenState extends State<SaleOrderScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  late final DBService dbService;
  late Map<int, String> unitNames = {};

  List<SaleOrderLineModel> get _currentLines {
    final state = context.read<SaleOrderBloc>().state;
    if (state is SaleOrderProductsLoaded) return state.lines;
    return [];
  }

  double get totalPrice =>
      _currentLines.fold(0, (sum, line) => sum + line.quantity * line.price);

  bool isFormValid = false;
  @override
  void initState() {
    super.initState();
    dbService = DBService();
    _loadUnits();
    final bloc = context.read<SaleOrderBloc>();
    bloc.add(LoadSaleOrderProducts());
    bloc.add(LoadSaleOrderCategories());

    _nameCtrl.addListener(_updateFormValid);
    _phoneCtrl.addListener(_updateFormValid);
    _addressCtrl.addListener(_updateFormValid);
  }

  void _updateFormValid() {
    setState(() {
      isFormValid = _nameCtrl.text.isNotEmpty &&
          _phoneCtrl.text.isNotEmpty &&
          _addressCtrl.text.isNotEmpty &&
          _currentLines.isNotEmpty;
    });

  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUnits() async {
    final unitsList = await dbService.getUnits();
    setState(() {
      unitNames = {for (var u in unitsList) u['id'] as int: u['name'] as String};
    });
  }

  void _addProductToOrder(Product product) async {
    final pricelistMaps = await dbService.getProductPricelist(product.id!);
    final pricelist =
    pricelistMaps.map((p) => ProductPriceListModel.fromMap(p)).toList();

    final baseUnitPrice = ProductPriceListModel(
      id: -1,
      productId: product.id!,
      unitId: product.unitId,
      price: product.price,
      factor: 1.0,
    );

    final allPrices = [baseUnitPrice, ...pricelist];
    ProductPriceListModel? selectedPrice;
    double qty = 1;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Add ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ProductPriceListModel>(
                decoration: const InputDecoration(
                  labelText: 'Select Unit',
                  border: OutlineInputBorder(),
                ),
                value: selectedPrice,
                items: allPrices.map((p) {
                  final unitName = unitNames[p.unitId] ?? 'Unknown';
                  return DropdownMenuItem(
                    value: p,
                    child: Text('$unitName - \$${p.price.toStringAsFixed(2)}'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedPrice = val),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                    labelText: 'Quantity', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: (val) => qty = double.tryParse(val) ?? 1,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (selectedPrice != null) {
                  final line = SaleOrderLineModel(
                    id: DateTime.now().millisecondsSinceEpoch,
                    orderId: 0,
                    productId: product.id!,
                    unitId: selectedPrice!.unitId,
                    quantity: qty,
                    price: selectedPrice!.price,
                    factor: selectedPrice!.factor,
                  );
                  context.read<SaleOrderBloc>().add(AddLineItem(line));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Create Sale Order', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon:  Icon(Icons.history, color: Colors.white),
            tooltip: 'Sale Order History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>  SaleOrderHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SaleOrderBloc, SaleOrderState>(
        builder: (context, state) {
          if (state is SaleOrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SaleOrderProductsLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                isFormValid = _nameCtrl.text.isNotEmpty &&
                    _phoneCtrl.text.isNotEmpty &&
                    _addressCtrl.text.isNotEmpty &&
                    state.lines.isNotEmpty;
              });
            });
            final products = state.filteredProducts;
            final categories = state.categories;
            final selectedCategory = state.selectedCategoryId;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Info
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                        labelText: 'Customer Name',
                        border: OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneCtrl,
                    decoration: InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone)),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressCtrl,
                    decoration: InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.home)),
                  ),
                  const SizedBox(height: 16),

                  // Search & Category Filter
                  TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                        labelText: 'Search Product',
                        border: OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search)),
                    onChanged: (val) {
                      context.read<SaleOrderBloc>().add(SearchProducts(val));
                    },
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<ProductCategory>(
                    value: state.selectedCategoryId != null
                        ? state.categories.firstWhere(
                          (c) => c.id == state.selectedCategoryId,

                    )
                        : null,
                    hint: const Text('Filter by Category'),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: state.categories
                        .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.name),
                    ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        context
                            .read<SaleOrderBloc>()
                            .add(FilterProductsByCategory(val.id));
                      } else {
                        context.read<SaleOrderBloc>().add(LoadSaleOrderProducts());
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Product List
                  const Text('Products:',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(product.name,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              'Price: \$${product.price}, On-Hand: ${product.onHandQty}'),
                          trailing: const Icon(Icons.add_shopping_cart,
                              color: Colors.green),
                          onTap: () => _addProductToOrder(product),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Order Lines
                  const Text('Order Lines:',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ..._currentLines.map((line) {
                    final product = products.firstWhere(
                            (p) => p.id == line.productId,
                        orElse: () => Product(
                            id: 0,
                            name: 'Unknown',
                            categoryId: 0,
                            unitId: 0,
                            price: 0,
                            onHandQty: 0));

                    final baseQty = line.quantity / line.factor;
                    final unitName = unitNames[line.unitId] ?? 'Unknown';
                    final baseUnitName = unitNames[product.unitId] ?? 'Base Unit';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                            'Qty: ${line.quantity} $unitName (${baseQty.toStringAsFixed(2)} $baseUnitName), '
                                'Price: \$${line.price.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context
                                .read<SaleOrderBloc>()
                                .add(RemoveLineItem(line.id!));
                          },
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 16),
                  // Total & Confirm
                  Text('Total: \$${totalPrice.toStringAsFixed(2)}',
                      style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child:ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFormValid ? Colors.blueAccent : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: isFormValid
                          ? () {
                        final order = SaleOrderModel(
                          id: DateTime.now().millisecondsSinceEpoch,
                          customerName: _nameCtrl.text,
                          phone: _phoneCtrl.text,
                          address: _addressCtrl.text,
                          totalPrice: totalPrice,
                          lines: _currentLines,
                        );
                        context.read<SaleOrderBloc>().add(ConfirmSaleOrder(order));

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sale Order Confirmed')),
                        );

                        _nameCtrl.clear();
                        _phoneCtrl.clear();
                        _addressCtrl.clear();
                      }
                          : null,
                      child: const Text('Confirm Sale Order', style: TextStyle(fontSize: 16)),
                    ),

                  ),
                ],
              ),
            );
          }

          if (state is SaleOrderError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
