/// A Dart package for calculating PAYE (Pay As You Earn) tax and pension contributions.
library;

import 'src/models/employees.dart';
import 'src/payroll/payroll_calculator.dart';
import 'src/pension/pension_calculator.dart';

export 'src/models/employees.dart';
export 'src/models/results.dart';
export 'src/payroll/payroll_calculator.dart';
export 'src/pension/pension_calculator.dart';

/// Main class for coordinating payroll and pension calculations
class PayE {
  final Country country;
  final Employee employee;
  late final PayrollCalculator _payrollCalculator;
  late final PensionCalculator _pensionCalculator;

  PayE({
    required this.country,
    required this.employee,
  }) {
    _payrollCalculator = PayrollCalculator(
      country: country,
      employee: employee,
    );
    _pensionCalculator = PensionCalculator(
      country: country,
      employee: employee,
    );
  }

  /// Calculates the complete payroll including tax and pension
  PayrollResult calculatePayroll() {
    // Calculate basic payroll
    final payrollResult = _payrollCalculator.calculate();

    // Calculate pension contributions
    final pensionResult = _pensionCalculator.calculate(payrollResult.totalEarnings);

    // Return updated result with pension calculations
    return PayrollResult(
      employee: employee,
      taxResult: payrollResult.taxResult,
      pensionResult: PensionResult(
        employeeContribution: pensionResult.employeeContribution,
        employerContribution: pensionResult.employerContribution,
        totalContribution: pensionResult.totalContribution,
      ),
      pieceRateEarnings: payrollResult.pieceRateEarnings,
      totalEarnings: payrollResult.totalEarnings - pensionResult.employeeContribution,
    );
  }
}

/// Represents the complete payroll calculation result
class PayrollResult {
  final Employee employee;
  final TaxResult taxResult;
  final PensionResult pensionResult;
  final double pieceRateEarnings;
  final double totalEarnings;

  PayrollResult({
    required this.employee,
    required this.taxResult,
    required this.pensionResult,
    required this.pieceRateEarnings,
    required this.totalEarnings,
  });
}

/// Represents the pension calculation result
class PensionResult {
  final double employeeContribution;
  final double employerContribution;
  final double totalContribution;

  PensionResult({
    required this.employeeContribution,
    required this.employerContribution,
    required this.totalContribution,
  });
}
