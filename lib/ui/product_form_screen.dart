import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sale_order_project/repository/product_category_respository.dart';
import 'package:sale_order_project/repository/product_unit_repositroy.dart';
import 'package:sale_order_project/ui/product_category_screen.dart';
import 'package:sale_order_project/ui/product_list_screen.dart';
import 'package:sale_order_project/ui/product_price_list_screen.dart';
import 'package:sale_order_project/ui/product_unit_screen.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/product/product_event.dart';
import '../models/product_category_model.dart';
import '../models/product_model.dart';
import '../models/product_unit_model.dart';
import '../services/db_service.dart';


class ProductFormScreen extends StatefulWidget {
  final Product? product;
  ProductFormScreen({this.product});

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
    nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    priceCtrl = TextEditingController(text: widget.product?.price.toString() ?? '');
    qtyCtrl = TextEditingController(text: widget.product?.onHandQty.toString() ?? '');
    _loadDropdowns();
  }

  void _loadDropdowns() async {
    final categoryRepo = ProductCategoryRespository(DBService());
    final unitRepo = ProductUnitRepositroy(DBService());

    final catList = await categoryRepo.getCategories();
    final unitList = await unitRepo.getUnits();

    setState(() {
      categories = catList;
      units = unitList;
      selectedCategory = categories.firstWhere(
              (c) => c.id == widget.product?.categoryId,
          orElse: () => categories[0]);
      selectedUnit = units.firstWhere(
              (u) => u.id == widget.product?.unitId,
          orElse: () => units[0]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.product == null ? 'Add Product' : 'Edit Product')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: 'Product Name'),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter product name' : null,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<ProductCategory>(
                  value: selectedCategory,
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
                  },
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (value) =>
                  value == null ? 'Please select category' : null,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<Unit>(
                  value: selectedUnit,
                  items: units
                      .map((u) => DropdownMenuItem(
                    value: u,
                    child: Text(u.name),
                  ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedUnit = val;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Unit'),
                  validator: (value) => value == null ? 'Please select unit' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: priceCtrl,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: qtyCtrl,
                  decoration: InputDecoration(labelText: 'On-Hand Quantity'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 24),
                ElevatedButton(
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
                        print("Product Created !!");
                      } else {
                        context.read<ProductBloc>().add(UpdateProductEvent(product));
                      }

                    }
                  },
                  child: Text('Save'),
                ),
                ElevatedButton(onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context) => ProductListScreen()));
                }, child: Text("Go to product list")),
                ElevatedButton(onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context) => ProductCategoryScreen()));
                }, child: Text("Go to Category list")),
                ElevatedButton(onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context) => UnitPage()));
                }, child: Text("Go to Unit list")),
                ElevatedButton(onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context) => ProductPriceListScreen()));
                }, child: Text("Go to Product price list"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

