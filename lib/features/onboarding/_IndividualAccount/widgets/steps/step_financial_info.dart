import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/constants/listConstants.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import '../common/reusable_dropdown.dart';
import '../../providers/registration_providers.dart';

class StepFinancialInfo extends ConsumerStatefulWidget {
  const StepFinancialInfo({super.key});

  @override
  ConsumerState<StepFinancialInfo> createState() => _StepFinancialInfoState();
}

class _StepFinancialInfoState extends ConsumerState<StepFinancialInfo> {
  late TextEditingController _occupationController;
  late TextEditingController _monthlyIncomeController;
  late TextEditingController _initialDepositController;
  String? _selectedSector;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _occupationController = TextEditingController();
    _monthlyIncomeController = TextEditingController();
    _initialDepositController = TextEditingController();
    
    // Initialize with existing data if available
    final registrationData = ref.read(registrationDataProvider);
    if (registrationData.occupation != null) {
      _occupationController.text = registrationData.occupation!;
    }
    if (registrationData.monthlyIncome != null) {
      _monthlyIncomeController.text = registrationData.monthlyIncome!;
    }
    if (registrationData.initialDeposit != null) {
      _initialDepositController.text = registrationData.initialDeposit!;
    }
    if (registrationData.sector != null) {
      _selectedSector = registrationData.sector;
    }
    
    // Add listeners to update registration data when text changes
    _occupationController.addListener(() {
      ref.read(registrationDataProvider.notifier).updateFinancialInfo(
        occupation: _occupationController.text,
      );
      // Clear validation error when user types
      if (_occupationController.text.isNotEmpty) {
        ref.read(formValidationProvider.notifier).clearError('occupation');
      }
    });
    
    _monthlyIncomeController.addListener(() {
      ref.read(registrationDataProvider.notifier).updateFinancialInfo(
        monthlyIncome: _monthlyIncomeController.text,
      );
      // Clear validation error when user types
      if (_monthlyIncomeController.text.isNotEmpty) {
        ref.read(formValidationProvider.notifier).clearError('monthlyIncome');
      }
    });
    
    _initialDepositController.addListener(() {
      ref.read(registrationDataProvider.notifier).updateFinancialInfo(
        initialDeposit: _initialDepositController.text,
      );
      // Clear validation error when user types
      if (_initialDepositController.text.isNotEmpty) {
        ref.read(formValidationProvider.notifier).clearError('initialDeposit');
      }
    });
  }

  @override
  void dispose() {
    _occupationController.dispose();
    _monthlyIncomeController.dispose();
    _initialDepositController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validationErrors = ref.watch(formValidationProvider);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: graybackgroundColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Financial Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please provide your financial information for account setup.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sector
              _buildLabel("Sector"),
              ReusableDropdown(
                selectedValue: _selectedSector,
                items: ListContants.sectors,
                hintText: 'Select Sector',
                onChanged: (newStatus) {
                  setState(() {
                    _selectedSector = newStatus;
                  });
                  // Update registration data
                  ref.read(registrationDataProvider.notifier).updateFinancialInfo(
                    sector: newStatus,
                  );
                  // Clear validation error when user selects
                  if (newStatus != null && newStatus.isNotEmpty) {
                    ref.read(formValidationProvider.notifier).clearError('sector');
                  }
                },
                prefixIcon: Icons.category,
                errorMessage: validationErrors['sector'] ?? 'Please select a Sector',
                isRequired: true,
              ),

              const SizedBox(height: 16),

              // Occupation
              _buildLabel("Occupation"),
              ReusableTextFormField(
                hintText: "Enter Occupation",
                controller: _occupationController,
                keyboardType: TextInputType.text,
                errorMessage: validationErrors['occupation'] ?? "Occupation cannot be empty",
                leadingIcon: Icons.work,
                isRequired: true,
              ),

              const SizedBox(height: 16),

              // Monthly Income
              _buildLabel("Monthly Income"),
              ReusableTextFormField(
                hintText: "Enter Monthly Income",
                controller: _monthlyIncomeController,
                keyboardType: TextInputType.number,
                errorMessage: validationErrors['monthlyIncome'] ?? "",
                leadingIcon: Icons.trending_up,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Only allow numbers
                ],
                isRequired: false,
              ),

              const SizedBox(height: 16),

              // Initial Deposit
              _buildLabel("Initial Deposit"),
              ReusableTextFormField(
                hintText: "Enter Initial Deposit",
                controller: _initialDepositController,
                keyboardType: TextInputType.number,
                errorMessage: validationErrors['initialDeposit'] ?? "Initial Deposit cannot be empty",
                leadingIcon: Icons.account_balance_wallet,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Only allow numbers
                ],
                isRequired: true,
              ),

              const SizedBox(height: 30),

              // Progress indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Step Progress',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '5 of 8',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.625,
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '62.5% Complete',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, left: 10, right: 3),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 