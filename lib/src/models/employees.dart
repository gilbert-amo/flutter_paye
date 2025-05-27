import 'package:decimal/decimal.dart';

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
    required this.allowance,
  });
}

class PieceRateAggregation {
  String item;
  double rate;
  double quantity;

  PieceRateAggregation({
    required this.item,
    required this.rate,
    required this.quantity,
  });
}

/// Represents a tax bracket with a threshold and rate
class TaxBracket {
  final double threshold;
  final double rate;

  TaxBracket({
    required this.threshold,
    required this.rate,
  }) {
    if (rate < 0 || rate > 1) {
      throw ArgumentError('Tax rate must be between 0 and 1');
    }
  }
}

class Tier {
  String name;
  double percentage;

  Tier({
    required this.name,
    required this.percentage,
  });
}

/// Represents a country with its tax system
class Country {
  final String name;
  final double minimumWage;
  final List<TaxBracket> taxBrackets;

  Country({
    required this.name,
    required this.minimumWage,
    required this.taxBrackets,
  }) {
    if (minimumWage < 0) {
      throw ArgumentError('Minimum wage cannot be negative');
    }

    // Validate that tax brackets are in ascending order
    for (int i = 1; i < taxBrackets.length; i++) {
      if (taxBrackets[i].threshold <= taxBrackets[i - 1].threshold) {
        throw ArgumentError('Tax brackets must be in ascending order');
      }
    }
  }

  /// Calculates tax for a given annual salary
  TaxResult calculateTax(double annualSalary) {
    final salary = Decimal.parse(annualSalary.toString());
    var totalTax = Decimal.zero;
    final taxBreakdown = <String, double>{
      'personalAllowance': 0.0,
      'basicRate': 0.0,
      'higherRate': 0.0,
      'additionalRate': 0.0,
    };

    // Calculate tax for each bracket
    for (int i = 0; i < taxBrackets.length; i++) {
      final bracket = taxBrackets[i];
      final threshold = Decimal.parse(bracket.threshold.toString());
      final rate = Decimal.parse(bracket.rate.toString());

      // Get the previous threshold (or 0 for the first bracket)
      final previousThreshold = i > 0
          ? Decimal.parse(taxBrackets[i - 1].threshold.toString())
          : Decimal.zero;

      // Calculate taxable amount in this bracket
      Decimal taxableInBracket;
      if (salary <= previousThreshold) {
        taxableInBracket = Decimal.zero;
      } else if (salary >= threshold) {
        taxableInBracket = threshold - previousThreshold;
      } else {
        taxableInBracket = salary - previousThreshold;
      }

      // Calculate and store tax for this bracket
      if (taxableInBracket > Decimal.zero) {
        final taxForBracket = taxableInBracket * rate;
        totalTax += taxForBracket;

        // Store tax breakdown
        final bandName = i == 0
            ? 'personalAllowance'
            : i == 1
                ? 'basicRate'
                : i == 2
                    ? 'higherRate'
                    : 'additionalRate';
        taxBreakdown[bandName] = taxForBracket.toDouble();
      }
    }

    return TaxResult(
      annualSalary: annualSalary,
      taxableIncome:
          (salary - Decimal.parse(taxBrackets[0].threshold.toString()))
              .toDouble(),
      totalTax: totalTax.toDouble(),
      netIncome: (salary - totalTax).toDouble(),
      taxBreakdown: taxBreakdown,
    );
  }
}

/// Represents the result of a tax calculation
class TaxResult {
  final double annualSalary;
  final double taxableIncome;
  final double totalTax;
  final double netIncome;
  final Map<String, double> taxBreakdown;

  TaxResult({
    required this.annualSalary,
    required this.taxableIncome,
    required this.totalTax,
    required this.netIncome,
    required this.taxBreakdown,
  });
}
