import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:youseuf_app/services/api_service.dart';

class UploadReportViewModel extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedStatus = "ممتازة";
  String? selectedMediaType;
  List<File> selectedFiles = [];
  List<String> selectedFileNames = [];
  bool isLoading = false;
  String? errorMessage;

  final ApiService _apiService = ApiService();

  // اختيار الملفات (صور - فيديو - PDF)
  Future<void> pickMedia(BuildContext context, String? type) async {
    FilePickerResult? result;

    try {
      if (type == "صورة") {
        result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.image,
        );
      } else if (type == "فيديو") {
        result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.video,
        );
      } else if (type == "PDF") {
        result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
      }

      if (result != null) {
        selectedFiles = result.paths.map((path) => File(path!)).toList();
        selectedFileNames =
            selectedFiles.map((f) => f.path.split('/').last).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("خطأ أثناء اختيار الملفات: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء اختيار الملفات")),
      );
    }
  }

  String mapStatusToEnglish(String status) {
    switch (status) {
      case "ممتازة":
        return "ممتازة";
      case "جيدة":
        return "جيدة";
      case "سيئة":
        return "سيئة";
      default:
        return status;
    }
  }

  // رفع التقرير باستخدام Laravel API
  Future<void> uploadReport(BuildContext context, String childId) async {
    if (selectedFiles.isEmpty ||
        selectedStatus == null ||
        titleController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى تعبئة جميع الحقول واختيار الملفات")),
      );
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.createReport(
       
        childId,
        titleController.text,
        descriptionController.text,
        mapStatusToEnglish(selectedStatus!),
        selectedFiles,
      );

      if (response != null &&
          response['message'] != null &&
          response.containsKey('report')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
        Navigator.pop(context, true);
      } else if (response != null && response['errors'] != null) {
        String error = '';
        Map<String, dynamic> errors = response['errors'];
        errors.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            error += '${value[0]}\n';
          }
        });
        errorMessage = error.trim();
        notifyListeners();
      } else {
        errorMessage = response?['message'] ?? 'حدث خطأ غير متوقع من الخادم';
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء رفع التقرير: ${e.toString()}';
      notifyListeners();
    }

    isLoading = false;
    notifyListeners();
  }
}
