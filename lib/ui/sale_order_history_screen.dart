import 'package:flutter/material.dart';
import '../services/db_service.dart';

class SaleOrderHistoryScreen extends StatefulWidget {
  const SaleOrderHistoryScreen({super.key});

  @override
  _SaleOrderHistoryScreenState createState() => _SaleOrderHistoryScreenState();
}

class _SaleOrderHistoryScreenState extends State<SaleOrderHistoryScreen> {
  final DBService dbService = DBService();
  List<Map<String, dynamic>> saleOrders = [];
  Map<int, List<Map<String, dynamic>>> saleOrderLines = {};

  @override
  void initState() {
    super.initState();
    _loadSaleOrders();
  }
  Future<void> _loadSaleOrders() async {
    final db = await dbService.database;

    final orders = await db.query('sale_orders');

    final units = await db.query('units');
    final unitNames = {for (var u in units) u['id'] as int: u['name'] as String};

    final products = await db.query('products');
    final productNames = {for (var p in products) p['id'] as int: p['name'] as String};

    final Map<int, List<Map<String, dynamic>>> linesMap = {};

    for (var order in orders) {
      final lines = await db.query(
        'sale_order_lines',
        where: 'saleOrderId = ?',
        whereArgs: [order['id']],
      );

      // create mutable copy and add unit/product names
      final mutableLines = lines.map((line) {
        return {
          ...line,
          'unitName': unitNames[line['unitId']] ?? 'Unknown',
          'productName': productNames[line['productId']] ?? 'Unknown',
        };
      }).toList();

      linesMap[order['id'] as int] = mutableLines;
    }

    setState(() {
      saleOrders = orders;
      saleOrderLines = linesMap;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sale Order History')),
      body: saleOrders.isEmpty
          ? const Center(child: Text('No sale orders found'))
          : ListView.builder(
        itemCount: saleOrders.length,
        itemBuilder: (context, index) {
          final order = saleOrders[index];
          final lines = saleOrderLines[order['id']] ?? [];

          return Card(
            margin: const EdgeInsets.all(8),
            child: ExpansionTile(
              title: Text(
                  '${order['customerName']} - ${order['createdAt']}'),
              subtitle: Text(
                  'Phone: ${order['customerPhone']}, Address: ${order['customerAddress']}'),
              children: lines.map((line) {
                return ListTile(
                  title: Text('Product: ${line['productName']}'),
                  subtitle: Text('Unit: ${line['unitName']}, Qty: ${line['quantity']}, Price: ${line['price']}'),
                );

              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
