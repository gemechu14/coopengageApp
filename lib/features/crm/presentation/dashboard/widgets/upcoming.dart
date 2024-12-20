import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coopengageplus/common_widgets/card/event_card.dart';

class Upcoming extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> data;

  const Upcoming(
      {super.key, required this.data}); // Initialize `data` using `this.data`

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UpcomingState();
}

class _UpcomingState extends ConsumerState<Upcoming> {
  @override
  Widget build(BuildContext context) {
    return

        // Task list
        ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.data.length > 10 ? 10 : widget.data.length,
      itemBuilder: (context, index) {
        return EventCard(data: widget.data[index]);
      },
    );
  }
}
