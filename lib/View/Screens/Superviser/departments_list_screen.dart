
import 'package:flutter/material.dart';
import 'package:youseuf_app/View/Screens/Superviser/department_details_screen.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/icons.dart';
import 'package:youseuf_app/services/api_service.dart';

class DepartmentsListScreen extends StatefulWidget {
  const DepartmentsListScreen({super.key});

  @override
  State<DepartmentsListScreen> createState() => _DepartmentsListScreenState();
}

class _DepartmentsListScreenState extends State<DepartmentsListScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _departments = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final departments = await _apiService.getDepartmentsData(context);
      setState(() {
        _departments = departments;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل جلب الأقسام: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ?  Center(child: CircularProgressIndicator(color: blue))
          : _errorMessage.isNotEmpty
              ? _buildErrorContent()
              : _departments.isEmpty
                  ? _buildEmptyContent()
                  : _buildDepartmentList(),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.add, color: red, size: 50),
            const SizedBox(height: 20),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: red, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchDepartments,
              icon: const Icon(AppIcons.replay),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.infoOutline, color: grey, size: 50),
          const SizedBox(height: 20),
          Text(
            'لا توجد أقسام لعرضها.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: darkgrey),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentList() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: _departments.length,
        itemBuilder: (context, index) {
          final department = _departments[index] as Map<String, dynamic>;
          final String name = department['name'] ?? 'بدون اسم';
          final String departmentId = department['id']?.toString() ?? '';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: blue,
              child: const Icon(Icons.apartment,
                  color: Colors.white), // أيقونة قسم
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (departmentId.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DepartmentDetailsScreen(departmentId: departmentId),
                  ),
                ).then((_) => _fetchDepartments());
              }
            },
          );
        },
      ),
    );
  }
}
