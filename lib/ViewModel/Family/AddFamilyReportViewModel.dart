import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:youseuf_app/services/api_service.dart';

class AddFamilyReportViewModel extends ChangeNotifier {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final uuid = Uuid();

  String? selectedCategory;
  bool isUploading = false;
  List<File> selectedFiles = [];

  final ApiService _apiService = ApiService();

  void setCategory(String? value) {
    selectedCategory = value;
    notifyListeners();
  }

  Future<void> pickFiles(BuildContext context) async {
    List<File> tempFiles = [];

    // 1. اختيار الصور والفيديوهات
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedMedia = await picker.pickMultipleMedia(
      imageQuality: 70,
    );
    if (pickedMedia != null) {
      tempFiles.addAll(pickedMedia.map((xfile) => File(xfile.path)));
    }

    // 2. اختيار ملفات PDF
    final FilePickerResult? pickedPdfs = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (pickedPdfs != null) {
      tempFiles.addAll(pickedPdfs.files
          .where((file) => file.path != null)
          .map((f) => File(f.path!)));
    }

    selectedFiles.addAll(tempFiles);
    notifyListeners();
  }

  void removeFile(int index) {
    selectedFiles.removeAt(index);
    notifyListeners();
  }

  Future<bool> uploadReport(BuildContext context) async {
    if (titleController.text.isEmpty ||
        selectedCategory == null ||
        descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return false;
    }

    isUploading = true;
    notifyListeners();

    try {
      final result = await _apiService.createReportFamily(
        context,
        titleController.text.trim(),
        selectedCategory!,
        descController.text.trim(),
        selectedFiles,
      );

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم إرسال التقرير بنجاح')),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في رفع التقرير')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}')),
      );
      return false;
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }
}
