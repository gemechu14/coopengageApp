import 'package:flutter/material.dart';
import 'package:coopengageplus/shared/widgets/card/event_card.dart';

class Passed extends StatelessWidget {
  const Passed({super.key, this.data});
  final data;
  @override
  Widget build(BuildContext context) {
    return
        // Task list
        ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length > 10 ? 10 : data.length,
      itemBuilder: (context, index) {
        return EventCard(data: data[index]);
      },
    );
  }
}
