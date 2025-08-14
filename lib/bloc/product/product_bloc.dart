import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc(this.repository) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  void _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await repository.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onAddProduct(AddProduct event, Emitter<ProductState> emit) async {
    await repository.insertProduct(event.product);
    add(LoadProducts());
  }

  void _onUpdateProduct(UpdateProductEvent event, Emitter<ProductState> emit) async {
    await repository.updateProduct(event.product);
    add(LoadProducts());
  }

  void _onDeleteProduct(DeleteProductEvent event, Emitter<ProductState> emit) async {
    await repository.deleteProduct(event.id);
    add(LoadProducts());
  }
}
