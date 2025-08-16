import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/product_unit/product_unit_bloc.dart';
import '../bloc/product_unit/product_unit_event.dart';
import '../bloc/product_unit/product_unit_state.dart';
import '../models/product_unit_model.dart';

class UnitPage extends StatelessWidget {
  const UnitPage({super.key});

  void _showFormDialog(BuildContext context, {Unit? unit}) {
    final nameController = TextEditingController(text: unit?.name ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(unit == null ? 'Add Unit' : 'Edit Unit'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Unit Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newUnit = Unit(
                id: unit?.id ?? DateTime.now().millisecondsSinceEpoch,
                name: nameController.text.trim(),
              );

              if (unit == null) {
                context.read<UnitBloc>().add(AddUnit(newUnit));
              } else {
                context.read<UnitBloc>().add(UpdateUnit(newUnit));
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Units',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: BlocBuilder<UnitBloc, UnitState>(
        builder: (context, state) {
          if (state is UnitLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UnitLoaded) {
            if (state.units.isEmpty) {
              return const Center(
                child: Text(
                  'No units yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.units.length,
              itemBuilder: (context, index) {
                final unit = state.units[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    title: Text(
                      unit.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showFormDialog(context, unit: unit),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context.read<UnitBloc>().add(DeleteUnit(unit.id));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is UnitError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
        tooltip: 'Add Unit',
      ),
    );
  }
}
