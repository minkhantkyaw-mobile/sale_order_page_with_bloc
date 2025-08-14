import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sale_order_project/bloc/product_unit/product_unit_event.dart';
import 'package:sale_order_project/bloc/product_unit/product_unit_state.dart';
import '../../models/product_unit_model.dart';
import '../../services/db_service.dart';


class UnitBloc extends Bloc<UnitEvent, UnitState> {
  final DBService dbService;

  UnitBloc(this.dbService) : super(UnitLoading()) {
    on<LoadUnits>((event, emit) async {
      emit(UnitLoading());
      try {
        final db = await dbService.database;
        final maps = await db.query('units', orderBy: 'id DESC');
        final units = maps.map((map) => Unit(
          id: map['id'] as int,
          name: map['name'] as String,
        )).toList();
        emit(UnitLoaded(units));
      } catch (e) {
        emit(UnitError(e.toString()));
      }
    });

    on<AddUnit>((event, emit) async {
      final db = await dbService.database;
      await db.insert('units', {'name': event.unit.name});
      add(LoadUnits());
    });

    on<UpdateUnit>((event, emit) async {
      final db = await dbService.database;
      await db.update(
        'units',
        {'name': event.unit.name},
        where: 'id = ?',
        whereArgs: [event.unit.id],
      );
      add(LoadUnits());
    });

    on<DeleteUnit>((event, emit) async {
      final db = await dbService.database;
      await db.delete('units', where: 'id = ?', whereArgs: [event.id]);
      add(LoadUnits());
    });
  }
}
