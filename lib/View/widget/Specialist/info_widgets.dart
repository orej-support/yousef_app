import 'package:flutter/material.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/models/child.dart';

class InfoWidgets extends StatelessWidget {
  final Child fallbackChild;

  const InfoWidgets({
    Key? key,
    required this.fallbackChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(21.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: grey300),
          ),
          child: Column(
            textDirection: TextDirection.rtl,
            children: [
              _buildInfoRow(
                  "الرقم التعريفي", fallbackChild.name ?? "غير متوفر"),
              _buildInfoRow(
                  "العمر",
                  fallbackChild.age != null
                      ? "${fallbackChild.age} سنوات"
                      : "غير متوفر"),
              // _buildInfoRow(
              //     "المشاكل الصحية", fallbackChild.healthIssues ?? "لا يوجد"),
              _buildInfoRow(
                "الجنس",
                (fallbackChild.gender.toLowerCase() == "male")
                    ? "ذكر"
                    : (fallbackChild.gender.toLowerCase() == "female")
                        ? "أنثى"
                        : "غير محدد",
              ),
              // _buildInfoRow("رقم تواصل للطوارئ",
              //     fallbackChild.emergencyContact ?? "غير متوفر"),
              _buildInfoRow("ملاحظات خاصة", fallbackChild.notes ?? "لا يوجد"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Column(
        children: [
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textDirection: TextDirection.rtl,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 13),
              Text(
                value,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 13,
                  color: blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
