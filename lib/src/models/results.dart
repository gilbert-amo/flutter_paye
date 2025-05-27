import 'employees.dart';

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
