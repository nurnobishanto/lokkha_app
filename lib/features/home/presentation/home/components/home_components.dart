import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';

import 'package:lokkha/shared/models/user.dart';

Widget topRankedUser({
  required String imagePath,
  required String id,
  required int rank,
  required User user,
  bool isFirst = false,
}) {
  final double outerRadius = isFirst ? 26.r : 26.r;

  return Column(
    children: [
      Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: outerRadius,
            backgroundColor: LightThemeColors.primaryColor,
            child: buildAvatar(user),
          ),
          Positioned(
            top: -4.r,
            right: -6.r,
            child: CircleAvatar(
              radius: 10.r,
              backgroundColor: Colors.green,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      5.0.h.height,
      Builder(
        builder: (ctx) => Text(
          "ID: $id",
          style: TextStyle(
            color: ctx.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
          ),
        ),
      ),
    ],
  ).paddingAll(5.r);
}
