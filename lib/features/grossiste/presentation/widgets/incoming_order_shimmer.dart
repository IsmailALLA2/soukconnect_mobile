import 'package:flutter/material.dart';

import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/shimmer_box.dart';

class IncomingOrderShimmer extends StatelessWidget {
  const IncomingOrderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: ShimmerList(
        itemCount: 5,
        spacing: 12,
        itemBuilder: (_, _) => Container(
          height: 110.h,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ShimmerBox(width: 40, height: 40, borderRadius: 12),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShimmerBox(height: 14, width: 120),
                        SizedBox(height: 6.h),
                        const ShimmerBox(height: 12, width: 80),
                      ],
                    ),
                  ),
                  const ShimmerBox(height: 24, width: 80, borderRadius: 20),
                ],
              ),
              SizedBox(height: 12.h),
              const ShimmerBox(height: 12, width: double.infinity),
            ],
          ),
        ),
      ),
    );
  }
}
