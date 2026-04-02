import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/core/constants/kconstant.dart';
import 'package:coopengageplus/core/constants/listConstants.dart';
import 'package:coopengageplus/shared/widgets/ReusableTextFormField.dart';
import 'package:coopengageplus/shared/widgets/dropDown/ReusableDropdown.dart';
import '../providers/stepper_provider.dart';

class MemberAdditionalInfoStep extends ConsumerStatefulWidget {
  const MemberAdditionalInfoStep({Key? key}) : super(key: key);

  @override
  ConsumerState<MemberAdditionalInfoStep> createState() =>
      _MemberAdditionalInfoStepState();
}

class _MemberAdditionalInfoStepState
    extends ConsumerState<MemberAdditionalInfoStep> {
  List<TextEditingController> legalIDControllers = [];
  List<TextEditingController> issueAuthorityControllers = [];
  List<TextEditingController> issueDateControllers = [];
  List<TextEditingController> expireDateControllers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    final members = ref.read(stepperProvider).members;
    _syncControllersWithMembers(members);
  }

  void _syncControllersWithMembers(List<dynamic> members) {
    final numberOfMembers = members.length;

    void ensureLength(
      List<TextEditingController> controllers,
      int length,
      String? Function(int index) initialValue,
      void Function(int index, TextEditingController controller)
          listenerFactory,
    ) {
      while (controllers.length > length) {
        controllers.removeLast().dispose();
      }
      while (controllers.length < length) {
        final index = controllers.length;
        final controller = TextEditingController();
        final initial = initialValue(index);
        if (initial != null && initial.isNotEmpty) {
          controller.text = initial;
        }
        listenerFactory(index, controller);
        controllers.add(controller);
      }
    }

    ensureLength(
      legalIDControllers,
      numberOfMembers,
      (index) {
        final member = members[index];
        return member.legalId ??
            member.verifiedData?['legalId']?.toString() ??
            member.verifiedData?['sub']?.toString();
      },
      (index, controller) {
        controller.addListener(() {
          ref
              .read(stepperProvider.notifier)
              .updateMemberLegalId(index, controller.text);
        });
      },
    );

    ensureLength(
      issueAuthorityControllers,
      numberOfMembers,
      (index) {
        final authority = members[index].issueAuthority;
        if (authority != null && authority.isNotEmpty) return authority;
        return 'ET';
      },
      (index, controller) {
        controller.addListener(() {
          ref
              .read(stepperProvider.notifier)
              .updateMemberIssueAuthority(index, controller.text);
        });
      },
    );

    ensureLength(
      issueDateControllers,
      numberOfMembers,
      (index) => members[index].issueDate,
      (index, controller) {
        controller.addListener(() {
          ref
              .read(stepperProvider.notifier)
              .updateMemberIssueDate(index, controller.text);
        });
      },
    );

    ensureLength(
      expireDateControllers,
      numberOfMembers,
      (index) => members[index].expirayDate,
      (index, controller) {
        controller.addListener(() {
          ref
              .read(stepperProvider.notifier)
              .updateMemberExpirayDate(index, controller.text);
        });
      },
    );

    for (var i = 0; i < numberOfMembers; i++) {
      final member = members[i];
      final defaultLegalId = member.legalId ??
          member.verifiedData?['legalId']?.toString() ??
          member.verifiedData?['sub']?.toString();
      if (defaultLegalId != null && defaultLegalId.isNotEmpty) {
        if (legalIDControllers[i].text.isEmpty) {
          legalIDControllers[i].text = defaultLegalId;
        }
      }
      if (issueAuthorityControllers[i].text.isEmpty) {
        issueAuthorityControllers[i].text = 'ET';
      }
    }
  }

  @override
  void dispose() {
    for (final c in legalIDControllers) c.dispose();
    for (final c in issueAuthorityControllers) c.dispose();
    for (final c in issueDateControllers) c.dispose();
    for (final c in expireDateControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepperState = ref.watch(stepperProvider);
    final members = stepperState.members;

    if (legalIDControllers.length != members.length ||
        issueAuthorityControllers.length != members.length ||
        issueDateControllers.length != members.length ||
        expireDateControllers.length != members.length) {
      _syncControllersWithMembers(members);
    }

    if (members.isEmpty) {
      return const Center(
        child: Text(
          'No members found. Please complete National ID authentication first.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final verifiedMembers = members
        .asMap()
        .entries
        .where((entry) => entry.value.isVerified)
        .toList();

    if (verifiedMembers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.info_outline,
                    size: 48, color: Colors.orange.shade400),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Verified Members',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'There are no verified members yet. You can either go back to '
                'complete the verification process now, or finish the registration '
                '\u2014 we\u2019ll send a verification link to your email so you '
                'can complete the process later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          ...verifiedMembers.map((entry) {
            final index = entry.key;
            final member = entry.value;
            return _buildMemberCard(index, member);
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
            child: const Icon(Icons.person_add_alt_1_rounded,
                color: cyanblueColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Member Details',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cyanblueColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Provide additional information for each verified member',
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
    );
  }

  Widget _buildMemberCard(int index, dynamic member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cyanblueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: cyanblueColor, size: 22),
          ),
          title: Text(
            member.fullName ?? 'Member ${index + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified,
                          color: Colors.green.shade600, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          initiallyExpanded: index == 0,
          children: [
            const SizedBox(height: 8),
            _buildFieldLabel('Legal ID'),
            ReusableTextFormField(
              hintText: 'Enter Legal ID',
              controller: legalIDControllers[index],
              keyboardType: TextInputType.text,
              leadingIcon: Icons.badge_outlined,
              isRequired: false,
            ),
            const SizedBox(height: 14),
            _buildFieldLabel('Title'),
            ReusableDropdown(
              selectedValue: member.title,
              items: ListContants.title,
              hintText: 'Select Title',
              onChanged: (newTitle) {
                if (newTitle != null) {
                  ref.read(stepperProvider.notifier).updateMember(
                        index,
                        member.copyWith(title: newTitle),
                      );
                }
              },
              prefixIcon: Icons.person_outline,
              errorMessage: 'Please select a title',
              isRequired: true,
            ),
            const SizedBox(height: 14),
            _buildFieldLabel('Issue Authority'),
            ReusableTextFormField(
              hintText: 'Enter Issue Authority',
              controller: issueAuthorityControllers[index],
              keyboardType: TextInputType.text,
              leadingIcon: Icons.account_balance_outlined,
              isRequired: false,
            ),
            const SizedBox(height: 14),
            _buildFieldLabel('Issue Date'),
            _buildDatePicker(
              controller: issueDateControllers[index],
              hint: 'Issue Date',
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            ),
            const SizedBox(height: 14),
            _buildFieldLabel('Expire Date'),
            _buildDatePicker(
              controller: expireDateControllers[index],
              hint: 'Expire Date',
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required TextEditingController controller,
    required String hint,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: controller.text.isNotEmpty
              ? DateTime.tryParse(controller.text) ?? DateTime.now()
              : DateTime.now(),
          firstDate: firstDate,
          lastDate: lastDate,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: cyanblueColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black87,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          controller.text = date.toString().split(' ')[0];
        }
      },
      child: AbsorbPointer(
        child: ReusableTextFormField(
          hintText: hint,
          controller: controller,
          keyboardType: TextInputType.text,
          leadingIcon: Icons.calendar_today_rounded,
          isRequired: false,
        ),
      ),
    );
  }
}
