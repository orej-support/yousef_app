class ReportModel {
  final String id;
  final String title;
  final String content;
  final String status;
  final DateTime createdAt;
  final List<String> files; // <-- بدلاً من String? file

  ReportModel({
    required this.id,
    required this.title,
    required this.content,
    required this.status,
    required this.createdAt,
    required this.files,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      status: map['status'] ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      files:
          (map['file_urls'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
