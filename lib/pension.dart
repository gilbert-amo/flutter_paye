import 'types.dart';

/// Manages pension calculations for employees
class PensionCalculator {
  final Employee employee;
  double _employeeContribution = 0.0;
  double _employerContribution = 0.0;
  double _totalMandatory = 0.0;
  final Map<String, double> _tierContributions = {};

  PensionCalculator(this.employee);

  /// Calculate pension contributions based on basic salary and tiers
  void calculate(List<Tier> tiers) {
    final basicSalary = employee.basicSalary;

    // Calculate contributions
    _employeeContribution = basicSalary * 0.055; // 5.5%
    _employerContribution = basicSalary * 0.13; // 13%
    _totalMandatory = _employeeContribution + _employerContribution;

    // Calculate tier allocations
    for (final tier in tiers) {
      _tierContributions[tier.name] = _totalMandatory * tier.percentage;
    }
  }

  /// Get employee contribution amount
  double get employeeContribution => _employeeContribution;

  /// Get employer contribution amount
  double get employerContribution => _employerContribution;

  /// Get total mandatory contribution
  double get totalMandatory => _totalMandatory;

  /// Get contribution breakdown
  Map<String, double> getContributionBreakdown() {
    return {
      'Basic Salary': employee.basicSalary,
      'Employee Contribution': _employeeContribution,
      'Employer Contribution': _employerContribution,
      'Total Mandatory': _totalMandatory,
    };
  }

  /// Get tier breakdown
  Map<String, double> getTierBreakdown() {
    return Map.from(_tierContributions);
  }

  /// Set custom tiers
  void setTiers(List<Tier> tiers) {
    _tierContributions.clear();
    for (final tier in tiers) {
      _tierContributions[tier.name] = 0.0;
    }
  }

  /// Calculate with internal tiers
  void calculateWithInternalTiers() {
    final defaultTiers = [
      Tier(name: 'Tier 1', percentage: 0.135),
      Tier(name: 'Tier 2', percentage: 0.55),
      Tier(name: 'Tier 3', percentage: 0.315),
    ];
    calculate(defaultTiers);
  }
}
