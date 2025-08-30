// lib/models/course.dart
import 'package:flutter/material.dart';
class Course {
  final int id;
  final String title;
  final String imageUrl;
  final String specialistId; // هذا يبدو String من الـ JSON
  final String link;
  final String type;
  final String createdAt;
  final String updatedAt;

  Course({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.specialistId,
    required this.link,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {

    return Course(
      id: json['id'] as int, // تأكد أنه يتم تحويله إلى int
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      specialistId: json['specialist_id'] as String, // تأكد أنه يتم تحويله إلى String
      link: json['link'] as String, // **هذا هو الجزء الأهم الذي يجب التأكد منه**
      type: json['type'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}