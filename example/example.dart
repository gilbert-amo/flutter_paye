import '../lib/types.dart';
import '../lib/payroll.dart';
import '../lib/pension.dart';

/// Example usage of the PayE Dart implementation
void main() {
  print('=== PayE Dart Implementation Example ===\n');

  // Create tax brackets (in the order they should be processed)
  final taxBrackets = [
    TaxBracket(threshold: 490.0, rate: 0.0), // 0% tax
    TaxBracket(threshold: 110.0, rate: 5.0), // 5% tax
    TaxBracket(threshold: 130.0, rate: 10.0), // 10% tax
    TaxBracket(threshold: 3166.0, rate: 17.5), // 17.5% tax
    TaxBracket(threshold: 16000.0, rate: 25.0), // 25% tax
    TaxBracket(threshold: 30520.0, rate: 30.0), // 30% tax
  ];

  // Create a country
  final country = Country(
    name: 'Ghana',
    minimumWage: 490.0,
    taxBrackets: taxBrackets,
  );

  // Create an employee
  final employee = Employee(
    name: 'John Doe',
    basicSalary: 50416.67,
    countryCode: 'GHA',
    pieceRate: [],
  );

  print('Employee: ${employee.name}');
  print('Basic Salary: \$${employee.basicSalary.toStringAsFixed(2)}');
  print('Country: ${country.name}');
  print('Minimum Wage: \$${country.minimumWage.toStringAsFixed(2)}');
  print('Tax Brackets: ${country.taxBrackets.length}');

  print('\n=== Progressive Tax Calculation ===');

  // Calculate tax using progressive subtraction
  final (totalTax, taxSteps) = PayrollCalculator.calculateTaxRecursive(
    employee.basicSalary,
    country.taxBrackets,
    country.minimumWage,
  );

  print('Starting Salary: \$${employee.basicSalary.toStringAsFixed(2)}');
  print('Total Tax: \$${totalTax.toStringAsFixed(2)}');
  print(
      'Net Salary: \$${(employee.basicSalary - totalTax).toStringAsFixed(2)}');

  print('\nTax Calculation Steps:');
  print('Step | Remaining Salary | Subtract Amount | Tax Rate | Tax Amount');
  print('-----|------------------|----------------|----------|-----------');

  for (int i = 0; i < taxSteps.length; i++) {
    final step = taxSteps[i];
    print(
        '${(i + 1).toString().padLeft(4)} | ${step.remainingSalary.toStringAsFixed(2).padLeft(16)} | ${step.taxableAmount.toStringAsFixed(2).padLeft(14)} | ${step.taxRate.toStringAsFixed(1).padLeft(8)}% | ${step.taxAmount.toStringAsFixed(2).padLeft(10)}');
  }

  print('\n=== Pension Calculation ===');

  // Create pension calculator
  final pensionCalc = PensionCalculator(employee);

  // Set up pension tiers
  final pensionTiers = [
    Tier(name: 'Tier 1', percentage: 0.135),
    Tier(name: 'Tier 2', percentage: 0.55),
    Tier(name: 'Tier 3', percentage: 0.315),
  ];

  // Calculate pension
  pensionCalc.calculate(pensionTiers);

  print(
      'Employee Contribution: \$${pensionCalc.employeeContribution.toStringAsFixed(2)}');
  print(
      'Employer Contribution: \$${pensionCalc.employerContribution.toStringAsFixed(2)}');
  print('Total Mandatory: \$${pensionCalc.totalMandatory.toStringAsFixed(2)}');

  print('\nPension Tier Allocations:');
  final tierBreakdown = pensionCalc.getTierBreakdown();
  for (final entry in tierBreakdown.entries) {
    print('${entry.key.padRight(20)}: \$${entry.value.toStringAsFixed(2)}');
  }

  print('\n=== Final Payroll Summary ===');
  final grossSalary = employee.basicSalary;
  final netSalary = grossSalary - totalTax - pensionCalc.employeeContribution;

  print('Gross Salary: \$${grossSalary.toStringAsFixed(2)}');
  print('Tax Deduction: \$${totalTax.toStringAsFixed(2)}');
  print(
      'Pension Deduction: \$${pensionCalc.employeeContribution.toStringAsFixed(2)}');
  print(
      'Total Deductions: \$${(totalTax + pensionCalc.employeeContribution).toStringAsFixed(2)}');
  print('Net Salary: \$${netSalary.toStringAsFixed(2)}');

  print('\n=== Tax Calculation Summary ===');
  print(PayrollCalculator.getTaxCalculationSummary(taxSteps));

  print('\n=== Example Complete ===');
  print('This demonstrates the complete PayE Dart implementation');
  print('with progressive subtraction tax calculation and pension management.');
}
