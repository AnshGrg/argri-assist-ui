import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class NutrientInputField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final String? hintText;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;

  const NutrientInputField({
    super.key,
    required this.label,
    this.initialValue,
    this.hintText,
    required this.onChanged,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: TextFormField(
              initialValue: initialValue,
              onChanged: onChanged,
              keyboardType: keyboardType,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
