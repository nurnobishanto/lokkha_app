import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CourseImageViewer extends StatelessWidget {
  final String imageUrl;
  const CourseImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.00.r),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: Icon(Icons.broken_image, size: 40.sp, color: Colors.grey),
          ),
          memCacheWidth: (MediaQuery.of(context).size.width * 2)
              .toInt(), // reduce memory usage
          memCacheHeight:
              (MediaQuery.of(context).size.width * 9 ~/ 16 * 2).toInt(),
        ),
      ),
    );
  }
}
