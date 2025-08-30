import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youseuf_app/models/child.dart';
import 'package:youseuf_app/services/api_service.dart';

class ViewAllChildrenViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Child> _childrenList = [];
  List<Child> _filteredChildren = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController searchController = TextEditingController();
  Timer? _filterDebounce;

  List<Child> get childrenList => _childrenList;
  List<Child> get filteredchildren => _filteredChildren;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  

   void init() {
  fetchChildren();
  searchController.addListener(_onSearchChanged);
 }


  void _onSearchChanged() {
    _filterDebounce?.cancel();
    _filterDebounce = Timer(const Duration(milliseconds: 300), _filterChildren);
  }

  Future<void> refreshChildren() async {
    await fetchChildren(); // مجرد التفاف حول الدالة الأصلية
  }

  Future<void> fetchChildren() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getMyChildren();
      debugPrint("📥 استجابة getMyChildren: $response");

      if (response != null) {
        _childrenList = response.map<Child>((child) {
          debugPrint("🧒 ابن: ${child['id']} - ${child['name']}");
          return Child.fromJson(child);
        }).toList();

        _filteredChildren = List.from(_childrenList);
        debugPrint("✅ تم جلب ${_childrenList.length} ابن.");
      } else {
        _childrenList = [];
        _filteredChildren = [];
        debugPrint("⚠️ استجابة خالية من الأبناء.");
      }
    } catch (e) {
      debugPrint("❌ خطأ في getMyChildren: $e");
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _filterChildren() {
    final query = searchController.text.toLowerCase();

    if (query.isEmpty) {
      _filteredChildren = List.from(_childrenList);
    } else {
      _filteredChildren = _childrenList
          .where((children) => children.name?.toLowerCase().contains(query) ?? false)
          .toList();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _filterDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
