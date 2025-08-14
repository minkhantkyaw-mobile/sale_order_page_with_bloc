import '../../models/product_unit_model.dart';

abstract class UnitState {}

class UnitLoading extends UnitState {}

class UnitLoaded extends UnitState {
  final List<Unit> units;
  UnitLoaded(this.units);
}

class UnitError extends UnitState {
  final String message;
  UnitError(this.message);
}
