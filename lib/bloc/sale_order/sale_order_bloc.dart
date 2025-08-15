import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sale_order_project/bloc/sale_order/sale_order_event.dart';
import 'package:sale_order_project/bloc/sale_order/sale_order_state.dart';
import '../../models/product_model.dart';
import '../../models/product_category_model.dart';
import '../../models/sale_order_line_model.dart';
import '../../models/sale_order_model.dart';
import '../../repository/product_repository.dart';
import '../../services/db_service.dart';

class SaleOrderBloc extends Bloc<SaleOrderEvent, SaleOrderState> {
  final ProductRepository productRepository;
  final DBService dbService;

  List<Product> _allProducts = [];
  List<ProductCategory> _allCategories = [];

  SaleOrderBloc({
    required this.productRepository,
    required this.dbService,
  }) : super(SaleOrderInitial()) {
    on<LoadSaleOrderProducts>(_onLoadProducts);
    on<LoadSaleOrderCategories>(_onLoadCategories);
    on<FilterProductsByCategory>(_onFilterProductsByCategory);
    on<SearchProducts>(_onSearchProducts);
    on<AddLineItem>(_onAddLineItem);
    on<RemoveLineItem>(_onRemoveLineItem);
    on<UpdateLineItem>(_onUpdateLineItem);
    on<ConfirmSaleOrder>(_onConfirmSaleOrder);
  }

  Future<void> _onLoadProducts(
      LoadSaleOrderProducts event, Emitter<SaleOrderState> emit) async {
    emit(SaleOrderLoading());
    try {
      _allProducts = await productRepository.getProducts();
      emit(SaleOrderProductsLoaded(
          products: _allProducts, filteredProducts: _allProducts));
    } catch (e) {
      emit(SaleOrderError(e.toString()));
    }
  }

  Future<void> _onLoadCategories(
      LoadSaleOrderCategories event, Emitter<SaleOrderState> emit) async {
    emit(SaleOrderLoading());
    try {
      final db = await dbService.database;
      final maps = await db.query('product_categories');
      _allCategories = maps
          .map((map) => ProductCategory(
        id: map['id'] as int,
        name: map['name'] as String,
      ))
          .toList();

      final state = this.state;
      if (state is SaleOrderProductsLoaded) {
        emit(state.copyWith(categories: _allCategories));
      } else {
        emit(SaleOrderProductsLoaded(
            products: _allProducts,
            filteredProducts: _allProducts,
            categories: _allCategories));
      }
    } catch (e) {
      emit(SaleOrderError(e.toString()));
    }
  }

  void _onFilterProductsByCategory(
      FilterProductsByCategory event, Emitter<SaleOrderState> emit) {
    final state = this.state;
    if (state is SaleOrderProductsLoaded) {
      final filtered = _allProducts
          .where((p) => p.categoryId == event.categoryId)
          .toList();
      emit(state.copyWith(filteredProducts: filtered));
    }
  }

  void _onSearchProducts(SearchProducts event, Emitter<SaleOrderState> emit) {
    final state = this.state;
    if (state is SaleOrderProductsLoaded) {
      final searched = _allProducts
          .where((p) => p.name.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(state.copyWith(filteredProducts: searched));
    }
  }

  void _onAddLineItem(AddLineItem event, Emitter<SaleOrderState> emit) {
    final state = this.state;
    if (state is SaleOrderProductsLoaded) {
      final updatedLines = List<SaleOrderLineModel>.from(state.lines)
        ..add(event.line);
      emit(state.copyWith(lines: updatedLines));
    }
  }

  void _onRemoveLineItem(RemoveLineItem event, Emitter<SaleOrderState> emit) {
    final state = this.state;
    if (state is SaleOrderProductsLoaded) {
      final updatedLines =
      state.lines.where((l) => l.id != event.lineId).toList();
      emit(state.copyWith(lines: updatedLines));
    }
  }

  void _onUpdateLineItem(UpdateLineItem event, Emitter<SaleOrderState> emit) {
    final state = this.state;
    if (state is SaleOrderProductsLoaded) {
      final updatedLines = state.lines
          .map((l) => l.id == event.line.id ? event.line : l)
          .toList();
      emit(state.copyWith(lines: updatedLines));
    }
  }

  Future<void> _onConfirmSaleOrder(
      ConfirmSaleOrder event, Emitter<SaleOrderState> emit) async {
    final state = this.state;
    if (state is SaleOrderProductsLoaded) {
      emit(SaleOrderLoading());
      try {
        final db = await dbService.database;

        // Insert sale order master
        final orderId = await db.insert('sale_orders', {
          'customerName': event.order.customerName,
          'customerPhone': event.order.phone,
          'customerAddress': event.order.address,
          'createdAt': DateTime.now().toIso8601String(),
        });

        print("This is orderID : $orderId");

        // Insert sale order lines and update product stock
        for (var line in event.order.lines) {
          await db.insert('sale_order_lines', {
            'saleOrderId': orderId,
            'productId': line.productId,
            'unitId': line.unitId,
            'quantity': line.quantity,
            'price': line.price,
          });

          final productMap = await db.query(
            'products',
            where: 'id = ?',
            whereArgs: [line.productId],
          );

          if (productMap.isNotEmpty) {
            final product = productMap.first;
            final currentQty = (product['onHandQty'] as num).toDouble();
            final updatedQty = currentQty - (line.quantity * line.factor);
            print("This is currentQty : $currentQty");
            print("This is update : $currentQty");


            await db.update(
              'products',
              {'onHandQty': updatedQty},
              where: 'id = ?',
              whereArgs: [line.productId],
            );
          }
        }

        _allProducts = await productRepository.getProducts();
        emit(SaleOrderProductsLoaded(
            products: _allProducts, filteredProducts: _allProducts));
      } catch (e) {
        emit(SaleOrderError(e.toString()));
      }
    }
  }
}
