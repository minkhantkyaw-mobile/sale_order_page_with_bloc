import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sale_order_project/models/product_price_list_model.dart';
import '../bloc/sale_order/sale_order_bloc.dart';
import '../bloc/sale_order/sale_order_event.dart';
import '../bloc/sale_order/sale_order_state.dart';
import '../models/product_model.dart';
import '../models/product_category_model.dart';
import '../models/sale_order_line_model.dart';
import '../models/sale_order_model.dart';
import '../services/db_service.dart';

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

  ProductCategory? selectedCategory;
  late Map<int, String> unitNames = {}; // unitId -> unitName

  List<SaleOrderLineModel> get _currentLines {
    final state = context.read<SaleOrderBloc>().state;
    if (state is SaleOrderProductsLoaded) {
      return state.lines;
    }
    return [];
  }

  double get totalPrice =>
      _currentLines.fold(0, (sum, line) => sum + line.quantity * line.price);

  @override
  void initState() {
    super.initState();
    dbService = DBService();
    _loadUnits();
    final bloc = context.read<SaleOrderBloc>();
    bloc.add(LoadSaleOrderProducts());
    bloc.add(LoadSaleOrderCategories());
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

    // Add product's base unit as a price list item
    final baseUnitPrice = ProductPriceListModel(
      id: -1, // temporary id for base unit
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
          title: Text('Add ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<ProductPriceListModel>(
                hint: const Text('Select Unit'),
                value: selectedPrice,
                items: allPrices.map((p) {
                  final unitName = unitNames[p.unitId] ?? 'Unknown';
                  return DropdownMenuItem(
                    value: p,
                    child: Text('$unitName - \$${p.price.toStringAsFixed(2)}'),
                  );
                }).toList(),
                onChanged: (val) => setState(() {
                  selectedPrice = val;
                }),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Quantity'),
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
      appBar: AppBar(title: const Text('Create Sale Order')),
      body: BlocBuilder<SaleOrderBloc, SaleOrderState>(
        builder: (context, state) {
          List<Product> products = [];
          List<ProductCategory> categories = [];

          if (state is SaleOrderProductsLoaded) {
            products = state.filteredProducts;
            categories = state.categories;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Info
                TextField(
                  controller: _nameCtrl,
                  decoration:
                  const InputDecoration(labelText: 'Customer Name'),
                ),
                TextField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 16),

                // Search & Category Filter
                TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Search Product',
                      suffixIcon: Icon(Icons.search)),
                  onChanged: (val) {
                    context.read<SaleOrderBloc>().add(SearchProducts(val));
                  },
                ),
                DropdownButton<ProductCategory>(
                  hint: const Text('Filter by Category'),
                  value: selectedCategory,
                  isExpanded: true,
                  items: categories
                      .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name),
                  ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedCategory = val;
                    });
                    if (val != null) {
                      context
                          .read<SaleOrderBloc>()
                          .add(FilterProductsByCategory(val.id));
                    } else {
                      context
                          .read<SaleOrderBloc>()
                          .add(LoadSaleOrderProducts());
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Product List
                const Text('Products:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                            'Price: ${product.price}, On-Hand: ${product.onHandQty}'),
                        onTap: () => _addProductToOrder(product),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Order Lines
                const Text('Order Lines:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
                  final baseUnitName =
                      unitNames[product.unitId] ?? 'Base Unit';

                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                        'Qty: ${line.quantity} $unitName '
                            '(${baseQty.toStringAsFixed(2)} $baseUnitName), '
                            'Price: ${line.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        context
                            .read<SaleOrderBloc>()
                            .add(RemoveLineItem(line.id!));
                      },
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),

                // Total & Confirm
                Text('Total: \$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
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
                        const SnackBar(content: Text('Sale Order Confirmed')));

                    setState(() {
                      _nameCtrl.clear();
                      _phoneCtrl.clear();
                      _addressCtrl.clear();
                    });
                  },
                  child: const Text('Confirm Sale Order'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
