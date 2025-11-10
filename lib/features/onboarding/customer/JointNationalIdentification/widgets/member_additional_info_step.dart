import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:coopengageplus/features/onboarding/customer/JointNationalIdentification/providers/stepper_provider.dart';
import 'package:coopengageplus/shared/widgets/ReusableTextFormField.dart';
import 'package:coopengageplus/shared/widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/core/constants/listConstants.dart';

class MemberAdditionalInfoStep extends ConsumerStatefulWidget {
  const MemberAdditionalInfoStep({Key? key}) : super(key: key);

  @override
  ConsumerState<MemberAdditionalInfoStep> createState() =>
      _MemberAdditionalInfoStepState();
}

class _MemberAdditionalInfoStepState
    extends ConsumerState<MemberAdditionalInfoStep> {
  final List<TextEditingController> motherNameControllers = [];
  final List<TextEditingController> legalIdControllers = [];
  final List<TextEditingController> issueAuthorityControllers = [];
  final List<TextEditingController> issueDateControllers = [];
  final List<TextEditingController> expireDateControllers = [];

  final Map<String, String> validationErrors = {};

  @override
  void dispose() {
    for (final c in [
      ...motherNameControllers,
      ...legalIdControllers,
      ...issueAuthorityControllers,
      ...issueDateControllers,
      ...expireDateControllers,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Delay so it runs after first frame (safe from build cycle)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stepperState = ref.read(stepperProvider);
      final notifier = ref.read(stepperProvider.notifier);

      for (int i = 0; i < stepperState.numberOfMembers; i++) {
        final member = stepperState.members[i];


        final updatedMember = member.copyWith(
          motherName: member.motherName ?? '',
          legalId:
              member.legalId ?? (member.verifiedData?['sub'] as String? ?? ''),
          issueAuthority: member.issueAuthority ?? 'ET',
          issueDate: member.issueDate ?? '',
          expireDate: member.expireDate ?? '',
        );

        if (updatedMember != member) {
          notifier.updateMember(i, updatedMember);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stepperState = ref.watch(stepperProvider);
    final notifier = ref.read(stepperProvider.notifier);
    final memberCount = stepperState.numberOfMembers;

    // Keep controller lists in sync with member count
    _syncControllers(motherNameControllers, memberCount);
    _syncControllers(legalIdControllers, memberCount);
    _syncControllers(issueAuthorityControllers, memberCount);
    _syncControllers(issueDateControllers, memberCount);
    _syncControllers(expireDateControllers, memberCount);

    // Prefill controllers from state so values persist across navigation
    for (int i = 0; i < memberCount; i++) {
      final member = stepperState.members[i];

      final motherName = member.motherName ?? '';
      if (motherNameControllers[i].text != motherName) {
        motherNameControllers[i].text = motherName;
      }

      final legalId = member.legalId ?? (member.verifiedData?['sub'] as String? ?? '');
      if (legalIdControllers[i].text != legalId) {
        legalIdControllers[i].text = legalId;
      }

      final issueAuthority = member.issueAuthority ?? 'ET';
      if (issueAuthorityControllers[i].text != issueAuthority) {
        issueAuthorityControllers[i].text = issueAuthority;
      }

      final issueDate = member.issueDate ?? '';
      if (issueDateControllers[i].text != issueDate) {
        issueDateControllers[i].text = issueDate;
      }

      final expireDate = member.expireDate ?? '';
      if (expireDateControllers[i].text != expireDate) {
        expireDateControllers[i].text = expireDate;
      }
    }

    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: ExpansionPanelList.radio(
            elevation: 8,
            expandedHeaderPadding: EdgeInsets.zero,
            dividerColor: whiteColor,
            children: List.generate(memberCount, (i) {
              final member = stepperState.members[i];
              return ExpansionPanelRadio(
                value: i,
                headerBuilder: (context, isExpanded) => ListTile(
                  leading: const Icon(Icons.person, color: Colors.blueAccent),
                  title: Text(
                    'Member ${i + 1}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                body: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Mother Name ---
                      TextLabel("Mother Name"),
                      const SizedBox(height: 8),
                      ReusableTextFormField(
                        hintText: 'Enter Mother Name',
                        controller: motherNameControllers[i],
                        keyboardType: TextInputType.text,
                        errorMessage: 'Mother Name cannot be empty',
                        leadingIcon: Icons.person,
                        isRequired: true,
                        onChanged: (value) {
                          notifier.updateMember(
                            i,
                            member.copyWith(motherName: value),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // --- Title ---
                      TextLabel("Title"),
                      const SizedBox(height: 8),
                      ReusableDropdown(
                        selectedValue: member.title,
                        items: ListContants.title,
                        hintText: 'Select Title',
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            notifier.updateMember(
                              i,
                              member.copyWith(title: newStatus),
                            );
                          }
                        },
                        prefixIcon: Icons.badge,
                        errorMessage: 'Please select a title',
                        isRequired: true,
                      ),
                      const SizedBox(height: 24),

                      // --- Issue Date ---
                      TextLabel("Issue Date"),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectIssueDate(context, i),
                        child: AbsorbPointer(
                          child: ReusableTextFormField(
                            hintText: "Issue Date",
                            controller: issueDateControllers[i],
                            keyboardType: TextInputType.none,
                            errorMessage: validationErrors['issueDate'] ?? '',
                            leadingIcon: Icons.calendar_today,
                            isRequired: false,
                            onChanged: (value) {
                              notifier.updateMember(
                                i,
                                member.copyWith(issueDate: value),
                              );
                              if (value.isNotEmpty) _clearError('issueDate');
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- Expire Date ---
                      TextLabel("Expire Date"),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectExpireDate(context, i),
                        child: AbsorbPointer(
                          child: ReusableTextFormField(
                            hintText: "Expire Date",
                            controller: expireDateControllers[i],
                            keyboardType: TextInputType.none,
                            errorMessage: validationErrors['expireDate'] ?? '',
                            leadingIcon: Icons.event_busy,
                            isRequired: false,
                            onChanged: (value) {
                              notifier.updateMember(
                                i,
                                member.copyWith(expireDate: value),
                              );
                              if (value.isNotEmpty) _clearError('expireDate');
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextLabel("Legal ID *"),
                      const SizedBox(height: 8),
                      ReusableTextFormField(
                        hintText: "Legal ID",
                        controller: legalIdControllers[i],
                        keyboardType: TextInputType.text,
                        errorMessage: validationErrors['legalId'] ?? '',
                        leadingIcon: Icons.badge,
                        isRequired: true,
                        onChanged: (value) {
                          notifier.updateMember(
                            i,
                            member.copyWith(legalId: value),
                          );
                          if (value.isNotEmpty) _clearError('legalId');
                        },
                      ),

                      const SizedBox(height: 16),

                      TextLabel("Issue Authority"),
                      const SizedBox(height: 8),
                      ReusableTextFormField(
                        hintText: "Issue Authority",
                        controller: issueAuthorityControllers[i],
                        keyboardType: TextInputType.text,
                        errorMessage: validationErrors['issueAuthority'] ?? '',
                        leadingIcon: Icons.verified,
                        isRequired: false,
                        onChanged: (value) {
                          notifier.updateMember(
                            i,
                            member.copyWith(issueAuthority: value),
                          );
                          if (value.isNotEmpty) _clearError('issueAuthority');
                        },
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // 🔹 Shared label builder
  Padding TextLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 3),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 🔹 Helper to sync controller count
  void _syncControllers(List<TextEditingController> list, int count) {
    while (list.length < count) {
      list.add(TextEditingController());
    }
    while (list.length > count) {
      list.removeLast().dispose();
    }
  }

  // 🔹 Date pickers per member
  Future<void> _selectIssueDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        issueDateControllers[index].text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
      ref.read(stepperProvider.notifier).updateMember(
            index,
            ref.read(stepperProvider).members[index].copyWith(
                  issueDate: issueDateControllers[index].text,
                ),
          );
      _clearError('issueDate');
    }
  }

  Future<void> _selectExpireDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365 * 5)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 12)),
    );
    if (picked != null) {
      setState(() {
        expireDateControllers[index].text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
      ref.read(stepperProvider.notifier).updateMember(
            index,
            ref.read(stepperProvider).members[index].copyWith(
                  expireDate: expireDateControllers[index].text,
                ),
          );
      _clearError('expireDate');
    }
  }

  // 🔹 Validation helper
  void _clearError(String field) {
    setState(() {
      validationErrors.remove(field);
    });
  }
}
