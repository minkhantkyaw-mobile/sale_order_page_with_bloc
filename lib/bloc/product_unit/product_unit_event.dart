import '../../models/product_unit_model.dart';

abstract class UnitEvent {}

class LoadUnits extends UnitEvent {}

class AddUnit extends UnitEvent {
  final Unit unit;
  AddUnit(this.unit);
}

class UpdateUnit extends UnitEvent {
  final Unit unit;
  UpdateUnit(this.unit);
}

class DeleteUnit extends UnitEvent {
  final int id;
  DeleteUnit(this.id);
}
