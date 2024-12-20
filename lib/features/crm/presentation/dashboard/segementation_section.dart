import 'package:flutter/material.dart';
import 'package:coopengageplus/constants/app_sizes.dart';
import 'package:coopengageplus/features/crm/presentation/dashboard/widgets/customer_segementation.dart';

class SegementationSection extends StatelessWidget {
  const SegementationSection({super.key, required this.height});
  final double height;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Container(
          height: height * 0.26,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                offset: const Offset(-4, -4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(4, 4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CustomerSegementation(),
        ));
  }
}
