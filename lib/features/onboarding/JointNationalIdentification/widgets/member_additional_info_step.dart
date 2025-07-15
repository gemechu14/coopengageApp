import 'package:coopengageplus/constants/kconstant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/features/onboarding/JointNationalIdentification/providers/stepper_provider.dart';
import 'package:coopengageplus/widget/ReusableTextFormField.dart';
import 'package:coopengageplus/common_widgets/dropDown/ReusableDropdown.dart';
import 'package:coopengageplus/constants/listConstants.dart';

class MemberAdditionalInfoStep extends ConsumerStatefulWidget {
  const MemberAdditionalInfoStep({Key? key}) : super(key: key);

  @override
  ConsumerState<MemberAdditionalInfoStep> createState() =>
      _MemberAdditionalInfoStepState();
}

class _MemberAdditionalInfoStepState
    extends ConsumerState<MemberAdditionalInfoStep> {
  int expandedIndex = 0;
  final List<TextEditingController> motherNameControllers = [];

  @override
  void dispose() {
    for (final controller in motherNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepperState = ref.watch(stepperProvider);
    final notifier = ref.read(stepperProvider.notifier);
    final memberCount = stepperState.numberOfMembers;

    // Ensure controllers are up to date
    while (motherNameControllers.length < memberCount) {
      motherNameControllers.add(TextEditingController());
    }
    while (motherNameControllers.length > memberCount) {
      motherNameControllers.removeLast().dispose();
    }

    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
        // color: const Color.fromARGB(255, 201, 23, 23),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: ExpansionPanelList(
            elevation: 8,
            dividerColor: whiteColor,
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (panelIndex, isExpanded) {
              setState(() {
                expandedIndex = panelIndex;
                // Update controller with current value
                final member = stepperState.members[panelIndex];
                motherNameControllers[panelIndex].text =
                    member.motherName ?? '';
              });
            },
            children: List.generate(memberCount, (i) {
              final member = stepperState.members[i];
              return ExpansionPanel(
                canTapOnHeader: true,
                isExpanded: expandedIndex == i,
                headerBuilder: (context, isExpanded) => ListTile(
                  leading: Icon(Icons.person, color: Colors.blueAccent),
                  title: Text(
                    'Member ${i + 1}',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                body: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text('Mother Name',
                      //     style: Theme.of(context).textTheme.bodyLarge),

                      TextLabel("MotherName"),
                      const SizedBox(height: 8),
                      ReusableTextFormField(
                        hintText: 'Enter Mother Name',
                        controller: motherNameControllers[i],
                        keyboardType: TextInputType.text,
                        errorMessage: 'Mother Name cannot be empty',
                        leadingIcon: Icons.person,
                        isRequired: true,
                        onChanged: (value) {
                          final updatedMember =
                              member.copyWith(motherName: value);
                          notifier.updateMember(i, updatedMember);
                        },
                      ),
                      const SizedBox(height: 24),
                      // Text('Title',
                      //     style: Theme.of(context).textTheme.bodyLarge),

                      TextLabel("Title"),
                      const SizedBox(height: 8),
                      ReusableDropdown(
                        selectedValue: member.title,
                        items: ListContants.title,
                        hintText: 'Select Title',
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            final updatedMember =
                                member.copyWith(title: newStatus);
                            notifier.updateMember(i, updatedMember);
                          }
                        },
                        prefixIcon: Icons.badge,
                        errorMessage: 'Please select a title',
                        isRequired: true,
                      ),
                      const SizedBox(height: 8),
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
}
