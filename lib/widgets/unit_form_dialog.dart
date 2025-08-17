import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_unit/product_unit_bloc.dart';
import '../bloc/product_unit/product_unit_event.dart';
import '../models/product_unit_model.dart';

class UnitFormDialog extends StatelessWidget {
  final Unit? unit;

  const UnitFormDialog({super.key, this.unit});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: unit?.name ?? '');

    return AlertDialog(
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
    );
  }
}
