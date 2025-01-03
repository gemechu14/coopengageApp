import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          // Simulate the bar chart
          Container(
            height: 175,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 20,
                      height: (index + 1) * 30.0,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 10,
                      color: Colors.grey,
                    ),
                  ],
                );
              }),
            ),
          ),
          SizedBox(height: 16),
          // Simulate the legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 20, height: 10, color: Colors.grey),
              SizedBox(width: 8),
              Container(width: 80, height: 10, color: Colors.grey),
              SizedBox(width: 16),
              Container(width: 20, height: 10, color: Colors.grey),
              SizedBox(width: 8),
              Container(width: 80, height: 10, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
