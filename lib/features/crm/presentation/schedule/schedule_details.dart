// import 'package:flutter/material.dart';
// ignore_for_file: unused_local_variable

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coopengageplus/constants/app_sizes.dart';
import 'package:coopengageplus/constants/kconstant.dart';
import 'package:coopengageplus/constants/text_styles.dart';
import 'package:coopengageplus/features/crm/providers/meeting/meeting_provider.dart';

class ScheduleDetails extends ConsumerStatefulWidget {
  final Map<String, dynamic> meetingDetails;
  final String eventType;

  const ScheduleDetails({
    Key? key,
    this.meetingDetails = const {
      "id": 39,
      "highProfileCustomerName": "Yared Mesele",
      "crmName": "crm",
      "meetingDate": "2024-11-26",
      "meetingTime": "17:46:00",
      "reason": "description",
      "feeling": null,
      "emotionalAttachment": null,
      "notes": "",
      "address": "bole",
      "category": null,
      "status": "COMPLETED",
      "createdAt": "2024-11-25T14:46:41.148532",
      "updatedAt": "2024-11-25T14:46:41.148602"
    },
    required this.eventType,
  }) : super(key: key);

  @override
  ConsumerState<ScheduleDetails> createState() => _ScheduleDetailsState();
}

class _ScheduleDetailsState extends ConsumerState<ScheduleDetails> {
  late TextEditingController _highProfileCustomerNameController;
  late TextEditingController _crmNameController;
  late TextEditingController _meetingDateController;
  late TextEditingController _meetingTimeController;
  late TextEditingController _reasonController;
  late TextEditingController _addressController;
  late TextEditingController _feelingControlller;
  late TextEditingController _notesController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _highProfileCustomerNameController = TextEditingController(
        text: widget.meetingDetails['highProfileCustomerName']);
    _crmNameController =
        TextEditingController(text: widget.meetingDetails['crmName']);
    _feelingControlller =
        TextEditingController(text: widget.meetingDetails['feeling']);
    _meetingDateController =
        TextEditingController(text: widget.meetingDetails['meetingDate']);
    _meetingTimeController =
        TextEditingController(text: widget.meetingDetails['meetingTime']);
    _reasonController =
        TextEditingController(text: widget.meetingDetails['reason']);
    _addressController =
        TextEditingController(text: widget.meetingDetails['address']);
    _status = widget.meetingDetails['status'];
    _notesController =
        TextEditingController(text: widget.meetingDetails["notes"]);
  }

  @override
  void dispose() {
    _highProfileCustomerNameController.dispose();
    _crmNameController.dispose();
    _meetingDateController.dispose();
    _meetingTimeController.dispose();
    _reasonController.dispose();
    _addressController.dispose();
    _feelingControlller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<String> _getStatusOptions() {
    if (widget.eventType == "meeting") {
      return ["COMPLETED", "PENDING", "CANCELLED", "SCHEDULED"];
    } else if (widget.eventType == "task") {
      return ["TO_DO", "IN_PROGRESS", "COMPLETED"];
    }
    return [];
  }

  String? selectedFeeling;
  String? selectedFeelingLabel;

  final List<Map<String, String>> feelings = [
    {"emoji": "😊", "label": "Happy"},
    {"emoji": "😐", "label": "Neutral"},
    {"emoji": "😞", "label": "Sad"},
    {"emoji": "😡", "label": "Angry"},
    {"emoji": "😲", "label": "Surprised"},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: Text(
          "Edit Schedule Details",
          style: subHeadingStyle,
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios)),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.save,
              color: primaryBlue,
            ),
            onPressed: () async {
              // Save logic here
              // Gather updated details and process them
              final updatedDetails = {
                "highProfileCustomerName":
                    _highProfileCustomerNameController.text,
                "crmName": _crmNameController.text,
                "meetingDate": _meetingDateController.text,
                "meetingTime": _meetingTimeController.text,
                "reason": _reasonController.text,
                "address": _addressController.text,
                "status": _status,
                "feeling": selectedFeelingLabel,
                "notes": _notesController.text
              };
              try {
                final provider = ref.read(meetingProvider.notifier);

                // final updatedSchedule = await provider.updateMeeting(
                //     meetingId: widget.meetingDetails["id"],
                //     token: AppConstants.access_token,
                //     meetingDate: _meetingDateController.text,
                //     meetingTime: _meetingTimeController.text,
                //     address: _addressController.text,
                //     status: _status,
                //     reason: _reasonController.text,
                //     feeling: selectedFeelingLabel,
                //     notes: _notesController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Meeting updated')),
                );
                // print({updatedSchedule});
              } catch (e) {
                print(e);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to add task: $e')),
                );
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   "Meeting Details",
            //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            // ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: "Customer Name",
              controller: _highProfileCustomerNameController,
              hint: "Enter customer name",
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: "Date",
              controller: _meetingDateController,
              hint: "Enter date",
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: "Time",
              controller: _meetingTimeController,
              hint: "Enter time",
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: "Description",
              controller: _reasonController,
              hint: "Enter description",
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: "Address",
              controller: _addressController,
              hint: "Enter address",
            ),
            const SizedBox(height: 16),
            Text("Status", style: titleStyle),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _status,
              items: _getStatusOptions()
                  .map((option) => DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(Sizes.p12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: primaryBlue, width: 1),
                  borderRadius: BorderRadius.circular(Sizes.p12),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                  borderRadius: BorderRadius.circular(Sizes.p12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                  borderRadius: BorderRadius.circular(Sizes.p12),
                ),
              ),
            ),
            gapH12,
            widget.eventType == "meeting"
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEditableField(
                        label: "Note",
                        controller: _notesController,
                        hint: "Enter meeting summary ",
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "How did the meeting go?",
                        style: titleStyle,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 5,
                        children: feelings.map((feeling) {
                          final isSelected =
                              selectedFeeling == feeling["emoji"];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedFeeling = feeling["emoji"];
                                selectedFeelingLabel = feeling["label"];
                                _feelingControlller.text =
                                    selectedFeeling as String;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue[100]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    feeling["emoji"]!,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    feeling["label"]!,
                                    style: titleStyle,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: titleStyle,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(Sizes.p12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: primaryBlue, width: 1),
              borderRadius: BorderRadius.circular(Sizes.p12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 1),
              borderRadius: BorderRadius.circular(Sizes.p12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1),
              borderRadius: BorderRadius.circular(Sizes.p12),
            ),
          ),
          maxLines: maxLines,
        ),
      ],
    );
  }
}
