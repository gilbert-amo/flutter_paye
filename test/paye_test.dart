import 'package:test/test.dart';
import 'package:paye/src/models/employees.dart';

void main() {
  group('PayE Tests', () {
    late Country ukCountry;

    setUp(() {
      // Set up UK tax brackets for testing
      final taxBrackets = [
        TaxBracket(threshold: 12570, rate: 0.0), // Personal Allowance
        TaxBracket(threshold: 50270, rate: 0.20), // Basic Rate
        TaxBracket(threshold: 125140, rate: 0.40), // Higher Rate
        TaxBracket(threshold: 999999, rate: 0.45), // Additional Rate
      ];

      ukCountry = Country(
        name: 'United Kingdom',
        minimumWage: 10.42, // 2023/24 minimum wage
        taxBrackets: taxBrackets, currencyCode: 'GBP',
      );
    });

    test('calculates tax for salary below personal allowance', () {
      final result = ukCountry.calculateTax(10000);
      expect(result.totalTax, 0.0);
      expect(result.netIncome, 10000.0);
    });

    test('calculates tax for salary in basic rate band', () {
      final result = ukCountry.calculateTax(30000);
      expect(result.taxBreakdown['basicRate'], greaterThan(0));
      expect(result.taxBreakdown['higherRate'], 0);
      expect(result.taxBreakdown['additionalRate'], 0);
    });

    test('calculates tax for salary in higher rate band', () {
      final result = ukCountry.calculateTax(60000);
      expect(result.taxBreakdown['basicRate'], greaterThan(0));
      expect(result.taxBreakdown['higherRate'], greaterThan(0));
      expect(result.taxBreakdown['additionalRate'], 0);
    });

    test('calculates tax for salary in additional rate band', () {
      final result = ukCountry.calculateTax(150000);
      expect(result.taxBreakdown['basicRate'], greaterThan(0));
      expect(result.taxBreakdown['higherRate'], greaterThan(0));
      expect(result.taxBreakdown['additionalRate'], greaterThan(0));
    });

    test('validates minimum wage', () {
      expect(
          () => Country(
                name: 'Test',
                minimumWage: -1,
                taxBrackets: [],
                currencyCode: 'GBP',
              ),
          throwsArgumentError);
    });

    test('validates tax brackets are in ascending order', () {
      final invalidBrackets = [
        TaxBracket(threshold: 50000, rate: 0.20),
        TaxBracket(threshold: 25000, rate: 0.10),
      ];

      expect(
          () => Country(
                name: 'Test',
                minimumWage: 10.0,
                taxBrackets: invalidBrackets,
                currencyCode: 'GBP',
              ),
          throwsArgumentError);
    });
  });
}
