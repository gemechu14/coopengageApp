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
  // Controllers for each member
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
      void Function(int index, TextEditingController controller) listenerFactory,
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
          ref.read(stepperProvider.notifier).updateMemberLegalId(index, controller.text);
        });
      },
    );

    ensureLength(
      issueAuthorityControllers,
      numberOfMembers,
      (index) {
        final authority = members[index].issueAuthority;
        if (authority != null && authority.isNotEmpty) {
          return authority;
        }
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
          ref.read(stepperProvider.notifier).updateMemberIssueDate(index, controller.text);
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
    for (final c in legalIDControllers) {
      c.dispose();
    }
    for (final c in issueAuthorityControllers) {
      c.dispose();
    }
    for (final c in issueDateControllers) {
      c.dispose();
    }
    for (final c in expireDateControllers) {
      c.dispose();
    }
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

    // Filter only verified members
    final verifiedMembers = members.asMap().entries
        .where((entry) => entry.value.isVerified)
        .toList();

    if (verifiedMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'No Verified Members',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please complete National ID authentication for at least one member before proceeding.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(0),
          //   child: Text(
          //     'Member Additional Information',
          //     style: TextStyle(
          //       fontSize: 20,
          //       fontWeight: FontWeight.bold,
          //       color: Colors.grey[800],
          //     ),
          //   ),
          // ),
          // const Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 16),
          //   child: Text(
          //     'Please provide additional information for each verified member.',
          //     style: TextStyle(fontSize: 14, color: Colors.grey),
          //   ),
          // ),
          // const SizedBox(height: 16),
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

  Widget _buildMemberCard(int index, dynamic member) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: cyanblueColor,
          child: Icon(
            Icons.person,
            color: whiteColor,
          ),
        ),
        title: Text(
          member.fullName ?? 'Member ${index + 1}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.verified, color: Colors.green, size: 16),
            const SizedBox(width: 4),
            const Text(
              'Verified',
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
          ],
        ),
        initiallyExpanded: index == 0, // Expand first member by default
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: 'Legal ID',
                  controller: legalIDControllers[index],
                  icon: Icons.badge,
                  hint: 'Enter Legal ID',
                ),
                const SizedBox(height: 16),
                _buildTitleDropdown(index, member),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Issue Authority',
                  controller: issueAuthorityControllers[index],
                  icon: Icons.business,
                  hint: 'Enter Issue Authority',
                ),
                const SizedBox(height: 16),
                _buildDateField(
                  label: 'Issue Date',
                  controller: issueDateControllers[index],
                  icon: Icons.calendar_today,
                  hint: 'Select Issue Date',
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                ),
                const SizedBox(height: 16),
                _buildDateField(
                  label: 'Expire Date',
                  controller: expireDateControllers[index],
                  icon: Icons.event,
                  hint: 'Select Expire Date',
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: cyanblueColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        ReusableTextFormField(
          hintText: hint,
          controller: controller,
          keyboardType: TextInputType.text,
          leadingIcon: icon,
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: cyanblueColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
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
                    colorScheme: ColorScheme.light(
                      primary: cyanblueColor,
                      onPrimary: whiteColor,
                      surface: whiteColor,
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
              leadingIcon: icon,
              isRequired: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleDropdown(int index, dynamic member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.badge, size: 18, color: cyanblueColor),
              const SizedBox(width: 8),
              const Text(
                'Title',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
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
          prefixIcon: Icons.badge,
          errorMessage: 'Please select a title',
          isRequired: true,
        ),
      ],
    );
  }

}

