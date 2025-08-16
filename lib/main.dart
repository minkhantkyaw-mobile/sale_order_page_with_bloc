import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:sale_order_project/repository/product_repository.dart';
import 'package:sale_order_project/services/db_service.dart';
import 'package:sale_order_project/ui/product_form_screen.dart';
import 'package:sale_order_project/ui/sale_order_history_screen.dart';
import 'package:sale_order_project/ui/sale_order_screen.dart';
import 'package:sale_order_project/ui/welcome_screen.dart';
import 'bloc/product/product_bloc.dart';
import 'bloc/product/product_event.dart';
import 'bloc/product_category/product_category_bloc.dart';
import 'bloc/product_category/product_category_event.dart';
import 'bloc/product_price_list/product_price_list_bloc.dart';
import 'bloc/product_price_list/product_price_list_event.dart';
import 'bloc/product_unit/product_unit_bloc.dart';
import 'bloc/product_unit/product_unit_event.dart';
import 'bloc/sale_order/sale_order_bloc.dart';
import 'bloc/sale_order/sale_order_event.dart';



void main() {
  final dbService = DBService();
  final productRepository = ProductRepository(dbService);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProductBloc(productRepository)..add(LoadProducts()),
        ),
        BlocProvider(
          create: (_) => ProductCategoryBloc(dbService)..add(LoadCategories()),
        ),
        BlocProvider(
          create: (_) => UnitBloc(dbService)..add(LoadUnits()),
        ),
        BlocProvider(
          create: (_) => ProductPricelistBloc(dbService)..add(LoadPricelist()),
        ),
        BlocProvider(
          create: (_) => SaleOrderBloc(productRepository: productRepository, dbService:  dbService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: WelcomeScreen(),
    );
  }
}
