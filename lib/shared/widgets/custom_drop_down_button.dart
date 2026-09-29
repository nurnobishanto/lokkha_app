import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/core/core.dart';

class CustomDropdownButton extends StatelessWidget {
  final List<String> items;
  final String dropdownValue;
  final void Function(String?)? onChanged;

  const CustomDropdownButton({
    super.key,
    required this.items,
    required this.dropdownValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height / 20.0,
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border.all(
          color: context.borderColor,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: DropdownButton<String>(
          isExpanded: true,
          value: dropdownValue,
          dropdownColor: context.cardColor,
          icon: Icon(Icons.arrow_drop_down, color: context.textSecondary),
          elevation: 16,
          style: TextStyle(
            color: context.textPrimary,
          ),
          underline: const SizedBox(),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: context.textPrimary)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
