import 'package:paye/src/models/employees.dart';

class Config {
  bool splitEnabled;
  double basicSalaryRatio;
  double allowanceRatio;

  Config({
    this.splitEnabled = false,
    this.basicSalaryRatio = 0.0,
    this.allowanceRatio = 0.0,
  });
}

double calculateSalary(Employee e) {
  double totalPieceRate = calculatePieceRate(e);
  return e.basicSalary > 0 ? e.basicSalary + totalPieceRate : totalPieceRate;
}

double calculatePieceRate(Employee e) {
  return e.pieceRate.fold(0.0, (sum, item) => sum + item.rate * item.quantity);
}

void addPieceRate(Employee e, String item, double rate, double quantity) {
  e.pieceRate
      .add(PieceRateAggregation(item: item, rate: rate, quantity: quantity));
}
