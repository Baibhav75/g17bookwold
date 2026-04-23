import 'package:flutter/material.dart';
import 'custom_refresh_indicator.dart'; // Import our new shimmer components

/// A Shimmer-based skeleton loader that replaces the old circular spinner.
/// This provides a more modern and premium loading experience.
class SchoolLoader extends StatelessWidget {
  final double size;
  final Color color;

  const SchoolLoader({
    super.key,
    this.size = 60,
    this.color = Colors.indigo,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      gradient: LinearGradient(
        colors: [
          Colors.grey[300]!,
          Colors.grey[100]!,
          Colors.grey[300]!,
        ],
        stops: const [0.1, 0.3, 0.4],
        begin: const Alignment(-1.0, -0.3),
        end: const Alignment(1.0, 0.3),
      ),
      child: ShimmerLoading(
        isLoading: true,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simulate a Header/Summary Card
              const SkeletonElement(
                height: 120,
                width: double.infinity,
                borderRadius: 12,
              ),
              const SizedBox(height: 20),

              // Search Bar Skeleton
              const SkeletonElement(
                height: 50,
                width: double.infinity,
                borderRadius: 10,
              ),
              const SizedBox(height: 20),

              // Table Header Skeleton
              SkeletonElement(
                height: 40,
                width: double.infinity,
                color: color.withOpacity(0.1),
                borderRadius: 4,
              ),
              const SizedBox(height: 10),

              // Simulate multiple list rows
              for (int i = 0; i < 5; i++) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      SkeletonElement(height: 20, width: 40),
                      SizedBox(width: 10),
                      SkeletonElement(height: 20, width: 60),
                      SizedBox(width: 10),
                      Expanded(child: SkeletonElement(height: 20)),
                    ],
                  ),
                ),
                Divider(color: Colors.grey[200]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}