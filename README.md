# PayE

A Dart package for calculating PAYE (Pay As You Earn) tax, pension contributions, and piece rate earnings for employees across different countries.

## Features

- **Multi-country Support**: Configure tax systems for different countries
- **Flexible Tax Brackets**: Define custom tax brackets and rates
- **Pension Calculations**: Calculate employee and employer pension contributions
- **Piece Rate Support**: Handle piece rate earnings alongside basic salary
- **Allowances**: Include various allowances in the final calculation
- **Detailed Breakdowns**: Get comprehensive breakdowns of tax and pension calculations

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  paye: ^1.0.0
```

## Usage

### Basic Usage

```dart
import 'package:paye/paye.dart';

void main() {
  // Set up tax brackets for a country
  final taxBrackets = [
    TaxBracket(threshold: 12570, rate: 0.0),  // Personal Allowance
    TaxBracket(threshold: 50270, rate: 0.20), // Basic Rate
    TaxBracket(threshold: 125140, rate: 0.40), // Higher Rate
    TaxBracket(threshold: 999999, rate: 0.45), // Additional Rate
  ];

  // Create a country with its tax system
  final ukCountry = Country(
    name: 'United Kingdom',
    minimumWage: 10.42,
    taxBrackets: taxBrackets,
    currencyCode: 'GBP'
  );

  // Create an employee
  final employee = Employee(
    name: 'John Doe',
    basicSalary: 50000,
    countryCode: 'GBR',
    pieceRate: [
      PieceRateAggregation(
        item: 'Overtime',
        rate: 25.0,
        quantity: 10,
      ),
    ],
    allowance: 1000,
  );

  // Calculate payroll
  final paye = PayE(
    country: ukCountry,
    employee: employee,
  );
  
  final result = paye.calculatePayroll();
  
  // Access the results
  print('Employee: ${result.employee.name}');
  print('Basic Salary: £${result.employee.basicSalary}');
  print('Piece Rate Earnings: £${result.pieceRateEarnings}');
  print('Allowance: £${result.employee.allowance}');
  print('Total Earnings: £${result.totalEarnings}');
  print('\nTax Breakdown:');
  print('Total Tax: £${result.taxResult.totalTax}');
  print('Net Income: £${result.taxResult.netIncome}');
  print('\nPension Breakdown:');
  print('Employee Contribution: £${result.pensionResult.employeeContribution}');
  print('Employer Contribution: £${result.pensionResult.employerContribution}');
  print('Total Contribution: £${result.pensionResult.totalContribution}');
}
```

### Configuring Tax Brackets

Tax brackets must be defined in ascending order of thresholds:

```dart
final taxBrackets = [
  TaxBracket(threshold: 12570, rate: 0.0),  // Personal Allowance
  TaxBracket(threshold: 50270, rate: 0.20), // Basic Rate
  TaxBracket(threshold: 125140, rate: 0.40), // Higher Rate
  TaxBracket(threshold: 999999, rate: 0.45), // Additional Rate
];
```

### Handling Piece Rate Work

You can include piece rate earnings for employees who are paid per item or task:

```dart
final pieceRate = [
  PieceRateAggregation(
    item: 'Overtime',
    rate: 25.0,    // Rate per hour
    quantity: 10,  // Number of hours
  ),
  PieceRateAggregation(
    item: 'Bonus',
    rate: 100.0,   // Rate per item
    quantity: 5,   // Number of items
  ),
];
```

## Features in Detail

### Tax Calculation
- Supports multiple tax brackets
- Handles personal allowances
- Calculates progressive tax rates
- Provides detailed tax breakdowns

### Pension Calculation
- Configurable employee and employer contribution rates
- Automatic calculation based on salary
- Support for different pension schemes

### Piece Rate Support
- Multiple piece rate items per employee
- Automatic calculation of piece rate earnings
- Integration with basic salary calculations

### Allowances
- Support for various types of allowances
- Integration with total earnings calculation
- Tax treatment of allowances

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
