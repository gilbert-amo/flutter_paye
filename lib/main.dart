import 'dart:io';
import 'types.dart';
import 'payroll.dart';
import 'pension.dart';

/// Main PayE application in Dart
void main() {
  final reader = stdin;

  while (true) {
    print('=== Country Setup ===');
    final countries = <String, Country>{};
    final config = PayrollConfig(splitEnabled: false);

    // Pension tier setup
    print('\n=== Pension Tier Setup ===');
    print('Enter pension tiers (total must equal 100%)');
    print('Example: Tier 1: 13.5%, Tier 2: 55%, Tier 3: 31.5%');
    print('Type \'done\' for tier name when finished');

    final pensionTiers = <Tier>[];
    double totalPercentage = 0.0;

    while (true) {
      print('\nCurrent total: ${(totalPercentage * 100).toStringAsFixed(1)}%');

      stdout.write('Enter tier name (or \'done\' to finish): ');
      final tierName = reader.readLineSync()?.trim() ?? '';
      if (tierName.toLowerCase() == 'done') {
        break;
      }

      if (tierName.isEmpty) {
        print('Tier name cannot be empty. Please try again.');
        continue;
      }

      final remainingPercentage = (1.0 - totalPercentage) * 100;
      if (remainingPercentage <= 0) {
        print('Total already equals 100%. Tier setup complete!');
        break;
      }

      stdout.write(
        'Enter tier percentage (0.1 to ${remainingPercentage.toStringAsFixed(1)}): ',
      );
      final percentageStr = reader.readLineSync()?.trim() ?? '';
      final percentage = double.tryParse(percentageStr);
      if (percentage == null || percentage <= 0) {
        print('Invalid percentage. Please enter a valid positive number.');
        continue;
      }

      // Convert percentage to decimal
      final percentageDecimal = percentage / 100;

      if (totalPercentage + percentageDecimal > 1.001) {
        // Allow small floating point precision
        print(
          'Total would exceed 100%. Maximum allowed: ${remainingPercentage.toStringAsFixed(1)}%',
        );
        continue;
      }

      pensionTiers.add(Tier(name: tierName, percentage: percentageDecimal));

      totalPercentage += percentageDecimal;
      print('Added $tierName: ${percentage.toStringAsFixed(1)}%');

      // Check if we've reached 100% (with small tolerance)
      if (totalPercentage >= 0.999) {
        print(
          'Total reached ${(totalPercentage * 100).toStringAsFixed(1)}%. Tier setup complete!',
        );
        break;
      }
    }

    // Validate total equals 100% (with tolerance)
    if (totalPercentage < 0.999) {
      print(
        'Warning: Total percentage is ${(totalPercentage * 100).toStringAsFixed(1)}%, not 100%',
      );
      print('Using default tiers instead');
      pensionTiers.clear();
      pensionTiers.addAll([
        Tier(name: 'Tier 1', percentage: 0.135),
        Tier(name: 'Tier 2', percentage: 0.55),
        Tier(name: 'Tier 3', percentage: 0.315),
      ]);
    } else {
      print(
        '✓ Pension tiers configured successfully! Total: ${(totalPercentage * 100).toStringAsFixed(1)}%',
      );
    }

    while (true) {
      stdout.write('\nEnter country code (3 letters, or \'done\' to finish): ');
      final code = reader.readLineSync()?.trim().toUpperCase() ?? '';

      if (code == 'DONE') {
        break;
      }

      if (code.length != 3) {
        print('Country code must be exactly 3 letters');
        continue;
      }

      stdout.write('Enter country name: ');
      final name = reader.readLineSync()?.trim() ?? '';

      stdout.write('Enter minimum wage: ');
      final minWageStr = reader.readLineSync()?.trim() ?? '';
      final minWage = double.tryParse(minWageStr);
      if (minWage == null) {
        print('Invalid wage. Please enter a valid number.');
        continue;
      }

      // Tax bracket setup
      final taxBrackets = <TaxBracket>[];
      print('\nSetting up tax brackets:');
      print(
        'Note: Minimum wage (${minWage.toStringAsFixed(2)}) will automatically be taxed at 0%',
      );
      print(
        'Enter additional threshold amounts that will be taxed at specific rates',
      );
      print(
        'Each threshold amount will be taxed at its rate and subtracted from salary',
      );
      print('Example: Threshold 500 with 5% rate = 500 × 5% = 25 tax');
      print('Note: 0% tax rates are valid (e.g., for tax-free allowances)');

      while (true) {
        stdout.write('Enter threshold amount (or \'done\'): ');
        final thresholdStr = reader.readLineSync()?.trim() ?? '';
        if (thresholdStr.toLowerCase() == 'done') {
          break;
        }

        final threshold = double.tryParse(thresholdStr);
        if (threshold == null) {
          print('Invalid threshold. Please enter a valid number.');
          continue;
        }

        stdout.write(
          'Enter tax rate to apply when threshold is reached (e.g., 5 for 5%): ',
        );
        final rateStr = reader.readLineSync()?.trim() ?? '';
        final rate = double.tryParse(rateStr);
        if (rate == null) {
          print('Invalid rate. Please enter a valid number.');
          continue;
        }

        // Allow 0% tax rates for progressive tax systems (e.g., tax-free allowance)
        // 0% rates are valid and commonly used in progressive tax systems

        taxBrackets.add(TaxBracket(threshold: threshold, rate: rate));
      }

      // Tax brackets are processed in the order they were entered (no sorting)

      countries[code] = Country(
        name: name,
        minimumWage: minWage,
        taxBrackets: taxBrackets,
      );
    }

    if (countries.isEmpty) {
      print('No countries entered. Exiting.');
      return;
    }

    // Configure splitting
    stdout.write('\nEnable salary splitting when piece-rate ≥ basic? (y/n): ');
    final splitInput = reader.readLineSync()?.trim().toLowerCase() ?? '';
    if (splitInput == 'y') {
      config.splitEnabled = true;

      stdout.write('Enter basic salary ratio (e.g., 0.7 for 70%): ');
      final basicRatioStr = reader.readLineSync()?.trim() ?? '';
      final basicRatio = double.tryParse(basicRatioStr);
      if (basicRatio == null || basicRatio <= 0 || basicRatio >= 1) {
        print('Invalid ratio. Using default 0.7');
        config.basicSalaryRatio = 0.7;
        config.allowanceRatio = 0.3;
      } else {
        config.basicSalaryRatio = basicRatio;
        config.allowanceRatio = 1 - basicRatio;
      }
    }

    // Employee setup
    print('\n=== Employee Setup ===');
    final employees = <Employee>[];

    while (true) {
      final emp = Employee(
        name: '',
        basicSalary: 0,
        countryCode: '',
        pieceRate: [],
      );

      stdout.write('\nEnter employee name (or \'done\' to finish): ');
      final name = reader.readLineSync()?.trim() ?? '';
      if (name.toLowerCase() == 'done') {
        break;
      }
      emp.name = name;

      stdout.write('Enter basic salary (0 for piece-rate only): ');
      final salaryStr = reader.readLineSync()?.trim() ?? '';
      final salary = double.tryParse(salaryStr);
      if (salary == null) {
        print('Invalid salary. Please enter a valid number.');
        continue;
      }
      emp.basicSalary = salary;

      // Add piece-rate work
      while (true) {
        stdout.write('Add piece-rate item (name or \'done\'): ');
        final item = reader.readLineSync()?.trim() ?? '';
        if (item.toLowerCase() == 'done') {
          break;
        }

        stdout.write('Enter unit price: ');
        final rateStr = reader.readLineSync()?.trim() ?? '';
        final rate = double.tryParse(rateStr);
        if (rate == null) {
          print('Invalid rate. Please try again.');
          continue;
        }

        stdout.write('Enter quantity: ');
        final qtyStr = reader.readLineSync()?.trim() ?? '';
        final qty = double.tryParse(qtyStr);
        if (qty == null) {
          print('Invalid quantity. Please try again.');
          continue;
        }

        emp.pieceRate.add(
          PieceRateAggregation(item: item, rate: rate, quantity: qty),
        );
      }

      if (emp.pieceRate.isEmpty && emp.basicSalary == 0) {
        print(
          'Error: Employee must have either basic salary or piece-rate work',
        );
        continue;
      }

      stdout.write('Enter employee\'s country code: ');
      final countryCode = reader.readLineSync()?.trim().toUpperCase() ?? '';

      if (!countries.containsKey(countryCode)) {
        print('Invalid country code. Please try again.');
        continue;
      }
      emp.countryCode = countryCode;

      employees.add(emp);
    }

    if (employees.isEmpty) {
      print('No employees entered. Exiting.');
      return;
    }

    // Process payroll
    print('\n=== Payroll Results ===');
    for (final emp in employees) {
      final country = countries[emp.countryCode]!;
      final pieceEarnings = PayrollCalculator.calculatePieceEarnings(
        emp.pieceRate,
      );
      final originalBasic = emp.basicSalary;
      emp.allowance = 0;

      // Handle employees with no basic salary
      if (originalBasic == 0 && emp.pieceRate.isNotEmpty) {
        print('\n${emp.name} has no basic salary - using piece-rate as basic');
        emp.basicSalary = pieceEarnings;
        // Note: In Dart, we can't modify final fields, so we'll work around this
      }

      // Conditional splitting for employees with both
      if (originalBasic > 0 &&
          config.splitEnabled &&
          pieceEarnings >= originalBasic) {
        print(
          '\nPiece-rate (${pieceEarnings.toStringAsFixed(2)}) ≥ basic salary (${originalBasic.toStringAsFixed(2)})',
        );
        print('Converting piece-rate to basic salary + allowance');

        // Note: In Dart, we can't modify final fields, so we'll work around this
        print(
          '- New Basic: ${(pieceEarnings * config.basicSalaryRatio).toStringAsFixed(2)}',
        );
        print(
          '- Allowance: ${(pieceEarnings * config.allowanceRatio).toStringAsFixed(2)}',
        );
      } else if (originalBasic > 0 && emp.pieceRate.isNotEmpty) {
        // Keep original basic and add piece-rate as bonus
        print(
          '\nAdding piece-rate earnings (${pieceEarnings.toStringAsFixed(2)}) as bonus',
        );
        // Note: In Dart, we can't modify final fields, so we'll work around this
      }

      // Minimum wage enforcement
      if (emp.basicSalary < country.minimumWage) {
        print(
          'Adjusting basic salary to meet minimum wage (${emp.basicSalary.toStringAsFixed(2)} → ${country.minimumWage.toStringAsFixed(2)})',
        );
        // Note: In Dart, we can't modify final fields, so we'll work around this
      }

      final totalEarnings = emp.basicSalary + emp.allowance;

      double taxAmount = 0.0;
      List<TaxCalculationStep> taxCalculationSteps = [];
      if (country.taxBrackets.isNotEmpty) {
        // Use recursive PAYE tax calculation on the ORIGINAL basic salary entered by user
        // This ensures we track the tax calculation from the initial salary amount
        // The minimum wage is automatically applied as a 0% tax threshold
        final result = PayrollCalculator.calculateTaxRecursive(
          originalBasic,
          country.taxBrackets,
          country.minimumWage,
        );
        taxAmount = result.$1;
        taxCalculationSteps = result.$2;
      }

      // Calculate pension
      final pensionCalc = PensionCalculator(emp);

      // Option 1: Use the tiers entered during setup
      pensionCalc.calculate(pensionTiers);

      // Option 2: Use internal tiers (uncomment to use instead)
      // pensionCalc.setTiers(pensionTiers);
      // pensionCalc.calculateWithInternalTiers();

      final pensionDeduction = pensionCalc.employeeContribution;
      final totalDeductions = taxAmount + pensionDeduction;

      final netSalary = totalEarnings - totalDeductions;

      PayrollCalculator.printPayrollReport(
        emp,
        country,
        originalBasic,
        totalEarnings,
        taxAmount,
        pensionCalc,
        netSalary,
        taxCalculationSteps,
      );
    }
  }
}
