# PayE Dart Implementation

A complete Dart implementation of the PayE payroll and pension management system, featuring progressive subtraction tax calculation and comprehensive payroll reporting.

## Features

- **Multi-country support** with configurable tax brackets
- **Progressive subtraction tax calculation** where threshold amounts are progressively subtracted from basic salary
- **Flexible salary calculation** supporting both basic salary and piece-rate work
- **Pension contribution calculations** with configurable tiered allocation
- **Detailed payroll reporting** with step-by-step tax calculation breakdown
- **Configurable salary splitting** between basic salary and allowances
- **No automatic sorting** - tax brackets are processed in the exact order they were entered

## Progressive Subtraction Tax Calculation

The system implements a progressive subtraction tax calculation where:

1. **Each threshold amount** gets taxed at its respective rate
2. **Threshold amounts are progressively subtracted** from the basic salary
3. **Tax calculation**: Each threshold amount × its tax rate = tax for that amount
4. **PAYE tax**: Sum of all calculated tax amounts
5. **Net salary**: Original salary minus total tax

### Example Tax Bracket Setup:
```
Threshold 490: 0% tax = 0.00 tax
Threshold 110: 5% tax = 5.50 tax
Threshold 130: 10% tax = 13.00 tax
Threshold 3166: 17.5% tax = 554.05 tax
Threshold 16000: 25% tax = 4,000.00 tax
Threshold 30520: 30% tax = 9,156.00 tax
```

### Progressive Subtraction Example:
Starting salary: 50,416.67
- Subtract 490 → Remaining: 49,926.67, Tax: 0.00
- Subtract 110 → Remaining: 49,816.67, Tax: 5.50
- Subtract 130 → Remaining: 49,686.67, Tax: 13.00
- Subtract 3166 → Remaining: 46,520.67, Tax: 554.05
- Subtract 16000 → Remaining: 30,520.67, Tax: 4,000.00
- Subtract 30520 → Remaining: 0.00, Tax: 9,156.00

**Total PAYE Tax: 13,728.55**

## Project Structure

```
PayE_Dart/
├── lib/
│   ├── main.dart          # Main application entry point
│   ├── types.dart          # Core data structures
│   ├── payroll.dart        # Payroll and tax calculations
│   └── pension.dart        # Pension calculations
├── pubspec.yaml            # Dart project configuration
└── README.md               # This file
```

## Installation

1. **Install Dart SDK** (version 3.0.0 or higher)
2. **Clone or download** the PayE_Dart folder
3. **Navigate to the project directory**:
   ```bash
   cd PayE_Dart
   ```
4. **Get dependencies**:
   ```bash
   dart pub get
   ```

## Usage

### Run the Application
```bash
dart run lib/main.dart
```

### Interactive Setup Process

1. **Pension Tier Setup**
   - Enter custom pension tiers (total must equal 100%)
   - Or use default tiers if total doesn't reach 100%

2. **Country Setup**
   - Enter country code (3 letters)
   - Enter country name and minimum wage
   - Set up tax brackets (threshold amounts and rates)
   - Minimum wage automatically gets 0% tax rate

3. **Salary Configuration**
   - Enable/disable salary splitting
   - Configure basic salary and allowance ratios

4. **Employee Setup**
   - Enter employee details
   - Set basic salary and/or piece-rate work
   - Assign country code

5. **Payroll Processing**
   - Automatic tax calculation using progressive subtraction
   - Pension calculations with tier allocations
   - Comprehensive payroll reports

## Key Classes

### Employee
- Basic salary, piece-rate work, country information
- Automatic calculation of total earnings

### TaxBracket
- Threshold amount and tax rate
- No automatic sorting - preserves input order

### PensionCalculator
- Employee and employer contributions
- Tier-based allocation system
- Configurable contribution rates

### PayrollCalculator
- Progressive subtraction tax calculation
- Salary and piece-rate calculations
- Comprehensive reporting functions

## Tax Calculation Algorithm

```dart
// Progressive subtraction: each threshold amount is subtracted from basic salary
double remainingSalary = originalSalary;
for (final bracket in enhancedBrackets) {
  if (remainingSalary >= bracket.threshold) {
    // Tax at the threshold rate for the full threshold amount
    taxAmount = bracket.threshold * (bracket.rate / 100);
    remainingSalary -= bracket.threshold;
  } else if (remainingSalary > 0) {
    // Apply the same rate to the remaining salary
    taxAmount = remainingSalary * (bracket.rate / 100);
    remainingSalary = 0;
  }
  totalTax += taxAmount;
}
```

## Example Output

```
Progressive Subtraction Tax Calculation Steps:
Step | Remaining Salary | Subtract Amount | Tax Rate | Tax Amount
-----|------------------|----------------|----------|-----------
   1 |         50416.67 |         490.00 |     0.0% |       0.00
   2 |         49926.67 |         110.00 |     5.0% |       5.50
   3 |         49816.67 |         130.00 |    10.0% |      13.00
   4 |         49686.67 |        3166.00 |    17.5% |     554.05
   5 |         46520.67 |       16000.00 |    25.0% |    4000.00
   6 |         30520.67 |       30520.00 |    30.0% |    9156.00

Total Tax: 13728.55
```

## Dependencies

- **Dart SDK**: >=3.0.0
- **args**: ^2.4.0 (for command-line argument parsing)

## Development

### Run Tests
```bash
dart test
```

### Format Code
```bash
dart format .
```

### Analyze Code
```bash
dart analyze
```

## Differences from Go Implementation

1. **Immutable vs Mutable**: Dart classes use mutable fields for runtime modifications
2. **Records**: Uses Dart 3.0+ records for returning multiple values
3. **Null Safety**: Full null safety implementation
4. **Collections**: Uses Dart's built-in collection methods (fold, map, etc.)
5. **String Interpolation**: Modern Dart string interpolation syntax

## License

[Add your license information here]
