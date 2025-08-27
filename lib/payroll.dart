import 'dart:io';
import 'types.dart';
import 'pension.dart';

/// Configuration for salary splitting
class PayrollConfig {
  bool splitEnabled;
  double basicSalaryRatio;
  double allowanceRatio;

  PayrollConfig({
    this.splitEnabled = false,
    this.basicSalaryRatio = 0.7,
    this.allowanceRatio = 0.3,
  });
}

/// Represents a single step in the progressive tax calculation
class TaxCalculationStep {
  final double remainingSalary;
  final double taxRate;
  final double taxAmount;
  final double bracketThreshold;
  final double taxableAmount;
  final String bracketRange;

  TaxCalculationStep({
    required this.remainingSalary,
    required this.taxRate,
    required this.taxAmount,
    required this.bracketThreshold,
    required this.taxableAmount,
    required this.bracketRange,
  });
}

/// Handles salary and tax calculations
class PayrollCalculator {
  /// Calculate total salary including piece-rate work
  static double calculateSalary(Employee employee) {
    final totalPieceRate = _calculatePieceRate(employee);

    if (employee.basicSalary > 0) {
      // Piece work is a bonus on top of basic salary
      return employee.basicSalary + totalPieceRate;
    }
    // Piece work is the entire salary
    return totalPieceRate;
  }

  /// Calculate total piece-rate earnings
  static double _calculatePieceRate(Employee employee) {
    return employee.pieceRate.fold(
      0.0,
      (total, item) => total + (item.rate * item.quantity),
    );
  }

  /// Calculate piece-rate earnings
  static double calculatePieceEarnings(List<PieceRateAggregation> pieces) {
    return pieces.fold(
      0.0,
      (total, piece) => total + (piece.rate * piece.quantity),
    );
  }

  /// Add piece-rate work item to employee
  static void addPieceRate(
    Employee employee,
    String item,
    double rate,
    double quantity,
  ) {
    employee.pieceRate.add(
      PieceRateAggregation(item: item, rate: rate, quantity: quantity),
    );
  }

  /// Progressive subtraction tax calculation
  /// Each threshold amount is progressively subtracted from the basic salary
  static (double, List<TaxCalculationStep>) calculateTaxRecursive(
    double originalSalary,
    List<TaxBracket> brackets,
    double minimumWage,
  ) {
    double totalTax = 0.0;
    final List<TaxCalculationStep> steps = [];

    // Create enhanced brackets with minimum wage as 0% tax threshold
    final enhancedBrackets = <TaxBracket>[
      TaxBracket(threshold: minimumWage, rate: 0.0), // 0% tax on minimum wage
      ...brackets,
    ];

    // Progressive subtraction: each threshold amount is subtracted from basic salary
    double remainingSalary = originalSalary;
    for (final bracket in enhancedBrackets) {
      double taxAmount;
      double taxableAmount;

      if (remainingSalary >= bracket.threshold) {
        // Tax at the threshold rate for the full threshold amount
        taxAmount = bracket.threshold * (bracket.rate / 100);
        taxableAmount = bracket.threshold;
        remainingSalary -= bracket.threshold;
      } else if (remainingSalary > 0) {
        // Apply the same rate to the remaining salary and end calculation
        taxAmount = remainingSalary * (bracket.rate / 100);
        taxableAmount = remainingSalary;
        remainingSalary = 0; // Set to 0 since we're taxing the remaining amount
      } else {
        // No remaining salary to tax
        break;
      }

      totalTax += taxAmount;

      // Record this calculation step
      final step = TaxCalculationStep(
        remainingSalary:
            remainingSalary + taxableAmount, // Show salary before this step
        taxRate: bracket.rate,
        taxAmount: taxAmount,
        bracketThreshold: bracket.threshold,
        taxableAmount: taxableAmount,
        bracketRange: 'Tax at ${bracket.rate.toStringAsFixed(1)}%',
      );
      steps.add(step);

      // If we've taxed the remaining salary (less than threshold), end the session
      if (remainingSalary == 0) {
        break;
      }

      // If salary becomes negative, stop
      if (remainingSalary < 0) {
        break;
      }
    }

    return (totalTax, steps);
  }

  /// Calculate tax (backward compatibility)
  static double calculateTax(
    double salary,
    List<TaxBracket> brackets,
    double minimumWage,
  ) {
    final (tax, _) = calculateTaxRecursive(salary, brackets, minimumWage);
    return tax;
  }

  /// Get tax calculation summary
  static String getTaxCalculationSummary(List<TaxCalculationStep> steps) {
    if (steps.isEmpty) {
      return 'No tax calculation steps available';
    }

    final totalTax = _calculateTotalTax(steps);
    final averageRate = _calculateAverageTaxRate(steps);

    return '''
Tax Calculation Summary:
Total Steps: ${steps.length}
Total Tax: ${totalTax.toStringAsFixed(2)}
Average Tax Rate: ${averageRate.toStringAsFixed(2)}%
''';
  }

  /// Calculate total tax from all steps
  static double _calculateTotalTax(List<TaxCalculationStep> steps) {
    return steps.fold(0.0, (total, step) => total + step.taxAmount);
  }

  /// Calculate average tax rate across all steps
  static double _calculateAverageTaxRate(List<TaxCalculationStep> steps) {
    if (steps.isEmpty) return 0.0;

    final totalRate = steps.fold(0.0, (total, step) => total + step.taxRate);
    return totalRate / steps.length;
  }

  /// Print detailed payroll report
  static void printPayrollReport(
    Employee emp,
    Country country,
    double originalBasic,
    double gross,
    double tax,
    PensionCalculator pensionCalc,
    double net,
    List<TaxCalculationStep> taxSteps,
  ) {
    print('\n=== ${emp.name} ===');
    print(
      'Country: ${country.name} (Min Wage: ${country.minimumWage.toStringAsFixed(2)})',
    );

    if (originalBasic > 0) {
      print('\nOriginal Basic Salary: ${originalBasic.toStringAsFixed(2)}');
    }
    print('Current Basic Salary: ${emp.basicSalary.toStringAsFixed(2)}');

    if (emp.allowance > 0) {
      print('Allowance: ${emp.allowance.toStringAsFixed(2)}');
    }

    if (emp.pieceRate.isNotEmpty) {
      print('\nPiece-Rate Details:');
      for (final piece in emp.pieceRate) {
        print(
          '- ${piece.item}: ${piece.quantity.toInt()} × ${piece.rate.toStringAsFixed(2)} = ${piece.earnings.toStringAsFixed(2)}',
        );
      }
      print(
        'Total Piece-Rate Earnings: ${calculatePieceEarnings(emp.pieceRate).toStringAsFixed(2)}',
      );
    }

    print('\nTax Calculation:');
    for (final bracket in country.taxBrackets) {
      print(
        '- Threshold ${bracket.threshold.toStringAsFixed(2)}: ${bracket.rate.toStringAsFixed(1)}%',
      );
    }

    // Display progressive subtraction tax calculation steps if available
    if (taxSteps.isNotEmpty) {
      print('\nProgressive Subtraction Tax Calculation Steps:');
      print(
        'Step | Remaining Salary | Subtract Amount | Tax Rate | Tax Amount',
      );
      print('-----|------------------|----------------|----------|-----------');
      for (int i = 0; i < taxSteps.length; i++) {
        final step = taxSteps[i];
        print(
          '${(i + 1).toString().padLeft(4)} | ${step.remainingSalary.toStringAsFixed(2).padLeft(16)} | ${step.taxableAmount.toStringAsFixed(2).padLeft(14)} | ${step.taxRate.toStringAsFixed(1).padLeft(8)}% | ${step.taxAmount.toStringAsFixed(2).padLeft(10)}',
        );
      }
      print('Total Tax: ${tax.toStringAsFixed(2)}');
    }

    // Print pension information
    print('\nPension Contributions:');
    final pensionBreakdown = pensionCalc.getContributionBreakdown();
    for (final entry in pensionBreakdown.entries) {
      print('${entry.key.padRight(20)}: ${entry.value.toStringAsFixed(2)}');
    }

    print('\nPension Tier Allocations:');
    final tierBreakdown = pensionCalc.getTierBreakdown();
    for (final entry in tierBreakdown.entries) {
      print('${entry.key.padRight(20)}: ${entry.value.toStringAsFixed(2)}');
    }

    print('\nGROSS SALARY: ${gross.toStringAsFixed(2)}');
    print('TAX DEDUCTION: ${tax.toStringAsFixed(2)}');
    print(
      'PENSION DEDUCTION: ${pensionCalc.employeeContribution.toStringAsFixed(2)}',
    );
    print(
      'TOTAL DEDUCTIONS: ${(tax + pensionCalc.employeeContribution).toStringAsFixed(2)}',
    );
    print('NET SALARY: ${net.toStringAsFixed(2)}');
    print('=' * 30);
  }

  /// Get salary breakdown with pension
  static String getSalaryBreakdownWithPension(
    Employee employee,
    PensionCalculator pensionCalc,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('\nSalary Breakdown for ${employee.name}:');
    buffer.writeln('-' * 30);

    if (employee.basicSalary > 0) {
      buffer.writeln(
        'Basic Salary: \$${employee.basicSalary.toStringAsFixed(2)}',
      );
    }

    if (employee.pieceRate.isNotEmpty) {
      print('\nPiece Rate Earnings:');
      for (final item in employee.pieceRate) {
        final earnings = item.rate * item.quantity;
        print(
          '- ${item.item}: ${item.quantity.toInt()} units @ \$${item.rate.toStringAsFixed(2)} = \$${earnings.toStringAsFixed(2)}',
        );
      }
      print(
        'Total Piece Rate: \$${_calculatePieceRate(employee).toStringAsFixed(2)}',
      );
    }

    final total = calculateSalary(employee);
    if (employee.basicSalary > 0 && employee.pieceRate.isNotEmpty) {
      buffer.writeln(
        '\nTotal Salary (Basic + Piece Rate): \$${total.toStringAsFixed(2)}',
      );
    } else {
      buffer.writeln('\nTotal Earnings: \$${total.toStringAsFixed(2)}');
    }

    final pensionBreakdown = pensionCalc.getContributionBreakdown();
    buffer.writeln('\nPension Contributions:');
    for (final entry in pensionBreakdown.entries) {
      buffer.writeln(
        '${entry.key.padRight(20)}: ${entry.value.toStringAsFixed(2)}',
      );
    }

    return buffer.toString();
  }
}
