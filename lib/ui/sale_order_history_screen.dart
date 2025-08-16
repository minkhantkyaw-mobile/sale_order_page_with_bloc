import 'package:flutter/material.dart';
import '../services/db_service.dart';
import 'package:intl/intl.dart';

class SaleOrderHistoryScreen extends StatefulWidget {
  const SaleOrderHistoryScreen({super.key});

  @override
  _SaleOrderHistoryScreenState createState() => _SaleOrderHistoryScreenState();
}

class _SaleOrderHistoryScreenState extends State<SaleOrderHistoryScreen> {
  final DBService dbService = DBService();
  List<Map<String, dynamic>> saleOrders = [];
  Map<int, List<Map<String, dynamic>>> saleOrderLines = {};

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

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

  double _calculateTotal(List<Map<String, dynamic>> lines) {
    return lines.fold(0.0, (sum, line) {
      final price = line['price'] as num? ?? 0;
      final qty = line['quantity'] as num? ?? 0;
      return sum + (price * qty);
    }).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Order History',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blueAccent,
      ),
      body: saleOrders.isEmpty
          ? const Center(child: Text('No sale orders found'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: saleOrders.length,
        itemBuilder: (context, index) {
          final order = saleOrders[index];
          final lines = saleOrderLines[order['id']] ?? [];
          final totalPrice = _calculateTotal(lines);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Order Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          order['customerName'] ?? 'Unknown Customer',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Phone: ${order['customerPhone'] ?? '-'} | Address: ${order['customerAddress'] ?? '-'}',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Date: ${order['createdAt'] != null ? dateFormat.format(DateTime.parse(order['createdAt'])) : '-'}',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const Divider(height: 16, thickness: 1),
                  // Line Items
                  ...lines.map((line) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              line['productName'] ?? 'Unknown Product',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${line['quantity'] ?? 0} ${line['unitName'] ?? ''}',
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '\$${line['price'] ?? 0}',
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
