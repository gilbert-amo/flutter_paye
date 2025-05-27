import '../models/employees.dart';
import '../models/results.dart';

/// Handles payroll calculations including tax and deductions
class PayrollCalculator {
  final Country country;
  final Employee employee;

  PayrollCalculator({
    required this.country,
    required this.employee,
  });

  /// Calculates the complete payroll for an employee
  PayrollResult calculate() {
    // Calculate basic tax
    final taxResult = country.calculateTax(employee.basicSalary);

    // Calculate piece rate earnings if any
    final pieceRateEarnings = _calculatePieceRateEarnings();

    // Calculate total earnings including allowances
    final totalEarnings = taxResult.netIncome + 
                         pieceRateEarnings + 
                         employee.allowance;

    return PayrollResult(
      employee: employee,
      taxResult: taxResult,
      pensionResult: PensionResult(
        employeeContribution: 0.0,
        employerContribution: 0.0,
        totalContribution: 0.0,
      ),
      pieceRateEarnings: pieceRateEarnings,
      totalEarnings: totalEarnings,
    );
  }

  /// Calculates earnings from piece rate work
  double _calculatePieceRateEarnings() {
    return employee.pieceRate.fold<double>(
      0.0,
      (sum, piece) => sum + (piece.rate * piece.quantity),
    );
  }
} 