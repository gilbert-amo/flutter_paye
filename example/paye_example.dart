import 'package:paye/src/models/employees.dart';

void main() {
  // Set up UK tax brackets
  final taxBrackets = [
    TaxBracket(threshold: 12570, rate: 0.0), // Personal Allowance
    TaxBracket(threshold: 50270, rate: 0.20), // Basic Rate
    TaxBracket(threshold: 125140, rate: 0.40), // Higher Rate
    TaxBracket(threshold: 999999, rate: 0.45), // Additional Rate
  ];

  final ukCountry = Country(
    name: 'United Kingdom',
    minimumWage: 10.42, // 2023/24 minimum wage
    taxBrackets: taxBrackets,
  );

  // Example 1: Salary below personal allowance
  print('Example 1: Salary below personal allowance (£10,000)');
  _printTaxCalculation(ukCountry.calculateTax(10000));

  // Example 2: Salary in basic rate band
  print('\nExample 2: Salary in basic rate band (£30,000)');
  _printTaxCalculation(ukCountry.calculateTax(30000));

  // Example 3: Salary in higher rate band
  print('\nExample 3: Salary in higher rate band (£60,000)');
  _printTaxCalculation(ukCountry.calculateTax(60000));

  // Example 4: Salary in additional rate band
  print('\nExample 4: Salary in additional rate band (£150,000)');
  _printTaxCalculation(ukCountry.calculateTax(150000));
}

void _printTaxCalculation(TaxResult result) {
  print('Annual Salary: £${result.annualSalary.toStringAsFixed(2)}');
  print('Taxable Income: £${result.taxableIncome.toStringAsFixed(2)}');
  print('Total Tax: £${result.totalTax.toStringAsFixed(2)}');
  print('Net Income: £${result.netIncome.toStringAsFixed(2)}');

  print('\nTax Breakdown:');
  print(
      'Personal Allowance: £${result.taxBreakdown['personalAllowance']?.toStringAsFixed(2) ?? '0.00'}');
  print(
      'Basic Rate: £${result.taxBreakdown['basicRate']?.toStringAsFixed(2) ?? '0.00'}');
  print(
      'Higher Rate: £${result.taxBreakdown['higherRate']?.toStringAsFixed(2) ?? '0.00'}');
  print(
      'Additional Rate: £${result.taxBreakdown['additionalRate']?.toStringAsFixed(2) ?? '0.00'}');
}
