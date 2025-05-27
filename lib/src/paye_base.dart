import 'dart:io';

import 'package:paye/src/models/employees.dart';
import 'package:paye/paye.dart';

void main() {
  // Set up tax brackets
  final taxBrackets = [
    TaxBracket(threshold: 12570, rate: 0.0),  // Personal Allowance
    TaxBracket(threshold: 50270, rate: 0.20), // Basic Rate
    TaxBracket(threshold: 125140, rate: 0.40), // Higher Rate
    TaxBracket(threshold: 999999, rate: 0.45), // Additional Rate
  ];

  // Create country
  final ukCountry = Country(
    name: 'United Kingdom',
    minimumWage: 10.42,
    taxBrackets: taxBrackets,
  );

  // Create employee
  final employee = Employee(
    name: 'John Doe',
    basicSalary: 50000,
    countryCode: 'GBR',
    pieceRate: [],
    allowance: 1000,
  );

  // Calculate payroll
  final paye = PayE(
    country: ukCountry,
    employee: employee,
  );
  
  final result = paye.calculatePayroll();
  
  print('Total Earnings: £${result.totalEarnings}');
  print('Tax: £${result.taxResult.totalTax}');
  print('Pension: £${result.pensionResult.totalContribution}');
}
