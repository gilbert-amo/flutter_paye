/// Core data structures for the PayE system

/// Represents an employee with basic salary, piece-rate work, and country information
class Employee {
  String name;
  double basicSalary;
  String countryCode;
  List<PieceRateAggregation> pieceRate;
  double allowance;

  Employee({
    required this.name,
    required this.basicSalary,
    required this.countryCode,
    required this.pieceRate,
    this.allowance = 0.0,
  });

  /// Calculate total piece rate earnings
  double get totalPieceRate {
    return pieceRate.fold(
      0.0,
      (sum, item) => sum + (item.rate * item.quantity),
    );
  }

  /// Calculate total salary (basic + piece rate)
  double get totalSalary {
    return basicSalary + totalPieceRate;
  }
}

/// Represents piece-rate work items with rate and quantity
class PieceRateAggregation {
  final String item;
  final double rate;
  final double quantity;

  PieceRateAggregation({
    required this.item,
    required this.rate,
    required this.quantity,
  });

  /// Calculate earnings for this piece-rate item
  double get earnings => rate * quantity;
}

/// Defines tax brackets with thresholds and rates
class TaxBracket {
  final double threshold;
  final double rate;

  TaxBracket({required this.threshold, required this.rate});
}

/// Represents pension contribution tiers
class Tier {
  final String name;
  final double percentage;

  Tier({required this.name, required this.percentage});
}

/// Contains country-specific information including minimum wage and tax brackets
class Country {
  final String name;
  final double minimumWage;
  final List<TaxBracket> taxBrackets;

  Country({
    required this.name,
    required this.minimumWage,
    required this.taxBrackets,
  });
}

/// Configuration for salary splitting
class Config {
  bool splitEnabled;
  double basicSalaryRatio;
  double allowanceRatio;

  Config({
    this.splitEnabled = false,
    this.basicSalaryRatio = 0.7,
    this.allowanceRatio = 0.3,
  });
}
