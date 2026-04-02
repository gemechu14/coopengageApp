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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cyanblueColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cyanblueColor.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cyanblueColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.info_outline,
                      color: cyanblueColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cyanblueColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Complete the remaining details for each member',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.blueGrey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ...List.generate(memberCount, (i) {
            final member = stepperState.members[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: i == 0,
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  childrenPadding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cyanblueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: cyanblueColor,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    member.fullName ?? 'Member ${i + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    member.isVerified ? 'Verified' : 'Pending',
                    style: TextStyle(
                      fontSize: 12,
                      color: member.isVerified
                          ? cyanblueColor
                          : Colors.grey.shade500,
                    ),
                  ),
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                    _buildFieldLabel('Mother Name'),
                    const SizedBox(height: 6),
                    ReusableTextFormField(
                      hintText: 'Enter Mother Name',
                      controller: motherNameControllers[i],
                      keyboardType: TextInputType.text,
                      errorMessage: 'Mother Name cannot be empty',
                      leadingIcon: Icons.person,
                      isRequired: true,
                      onChanged: (value) {
                        notifier.updateMember(
                            i, member.copyWith(motherName: value));
                      },
                    ),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Title'),
                    const SizedBox(height: 6),
                    ReusableDropdown(
                      selectedValue: member.title,
                      items: ListContants.title,
                      hintText: 'Select Title',
                      onChanged: (newStatus) {
                        if (newStatus != null) {
                          notifier.updateMember(
                              i, member.copyWith(title: newStatus));
                        }
                      },
                      prefixIcon: Icons.badge,
                      errorMessage: 'Please select a title',
                      isRequired: true,
                    ),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Legal ID'),
                    const SizedBox(height: 6),
                    ReusableTextFormField(
                      hintText: 'Legal ID',
                      controller: legalIdControllers[i],
                      keyboardType: TextInputType.text,
                      errorMessage: validationErrors['legalId'] ?? '',
                      leadingIcon: Icons.badge,
                      isRequired: true,
                      onChanged: (value) {
                        notifier.updateMember(
                            i, member.copyWith(legalId: value));
                        if (value.isNotEmpty) _clearError('legalId');
                      },
                    ),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Issue Authority'),
                    const SizedBox(height: 6),
                    ReusableTextFormField(
                      hintText: 'Issue Authority',
                      controller: issueAuthorityControllers[i],
                      keyboardType: TextInputType.text,
                      errorMessage:
                          validationErrors['issueAuthority'] ?? '',
                      leadingIcon: Icons.verified,
                      isRequired: false,
                      onChanged: (value) {
                        notifier.updateMember(
                            i, member.copyWith(issueAuthority: value));
                        if (value.isNotEmpty)
                          _clearError('issueAuthority');
                      },
                    ),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Issue Date'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _selectIssueDate(context, i),
                      child: AbsorbPointer(
                        child: ReusableTextFormField(
                          hintText: 'Issue Date',
                          controller: issueDateControllers[i],
                          keyboardType: TextInputType.none,
                          errorMessage:
                              validationErrors['issueDate'] ?? '',
                          leadingIcon: Icons.calendar_today,
                          isRequired: false,
                          onChanged: (value) {
                            notifier.updateMember(
                                i, member.copyWith(issueDate: value));
                            if (value.isNotEmpty) _clearError('issueDate');
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Expire Date'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _selectExpireDate(context, i),
                      child: AbsorbPointer(
                        child: ReusableTextFormField(
                          hintText: 'Expire Date',
                          controller: expireDateControllers[i],
                          keyboardType: TextInputType.none,
                          errorMessage:
                              validationErrors['expireDate'] ?? '',
                          leadingIcon: Icons.event_busy,
                          isRequired: false,
                          onChanged: (value) {
                            notifier.updateMember(
                                i, member.copyWith(expireDate: value));
                            if (value.isNotEmpty) _clearError('expireDate');
                          },
                        ),
                      ),
                    ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
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
