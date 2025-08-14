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
        title: Text(unit == null ? 'Add Unit' : 'Edit Unit'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Unit Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newUnit = Unit(
                id: unit?.id ?? DateTime.now().millisecondsSinceEpoch,
                name: nameController.text,

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
      appBar: AppBar(title: const Text('Units')),
      body: BlocBuilder<UnitBloc, UnitState>(
        builder: (context, state) {
          if (state is UnitLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UnitLoaded) {
            if (state.units.isEmpty) return const Center(child: Text('No units yet.'));
            return ListView.builder(
              itemCount: state.units.length,
              itemBuilder: (context, index) {
                final unit = state.units[index];
                return ListTile(
                  title: Text(unit.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showFormDialog(context, unit: unit),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          context.read<UnitBloc>().add(DeleteUnit(unit.id));
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is UnitError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
