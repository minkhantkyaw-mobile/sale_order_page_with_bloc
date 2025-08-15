import 'package:sale_order_project/models/sale_order_line_model.dart';

class SaleOrderModel {
  final int? id;
  final String customerName;
  final String phone;
  final String address;
  final double totalPrice;
  final List<SaleOrderLineModel> lines;

  SaleOrderModel({
    this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.totalPrice,
    required this.lines,
  });
}
