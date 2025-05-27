import 'package:paye/src/models/employees.dart';

class PensionCalculator {
  Employee employee;
  double employeeContribution = 0.0;
  double employerContribution = 0.0;
  double totalMandatory = 0.0;
  Map<String, double> tierContributions = {};

  PensionCalculator(this.employee);

  void calculate(List<Tier> tiers) {
    double basicSalary = employee.basicSalary;

    employeeContribution = basicSalary * 0.055;
    employerContribution = basicSalary * 0.13;
    totalMandatory = employeeContribution + employerContribution;

    for (var tier in tiers) {
      tierContributions[tier.name] = totalMandatory * tier.percentage;
    }
  }

  Map<String, double> getContributionBreakdown() {
    return {
      'Basic Salary': employee.basicSalary,
      'Employee Contribution': employeeContribution,
      'Employer Contribution': employerContribution,
      'Total Mandatory': totalMandatory,
    };
  }

  Map<String, double> getTierBreakdown() {
    return tierContributions;
  }
}
