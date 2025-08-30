
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youseuf_app/View/Screens/Superviser/specialist_children_screen.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/icons.dart';
import 'package:youseuf_app/models/specialist.dart';
import 'package:youseuf_app/services/api_service.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد

class SpecialistsListScreen extends StatefulWidget {
  const SpecialistsListScreen({super.key});

  @override
  State<SpecialistsListScreen> createState() => _SpecialistsListScreenState();
}

class _SpecialistsListScreenState extends State<SpecialistsListScreen> {
  final ApiService _apiService = ApiService();
  List<Specialist> _specialists = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSpecialists();
  }

  Future<void> _fetchSpecialists() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final specialists = await _apiService.getSpecialistsData(context);
      setState(() {
        _specialists = specialists;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل جلب الأخصائيين: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    return Scaffold(
      body: _buildBody(),
    );
  }

  // 💡 دالة بناء محتوى الشاشة
  Widget _buildBody() {
    if (_isLoading) {
      return  Center(child: CircularProgressIndicator(color: blue));
    }
    if (_errorMessage.isNotEmpty) {
      return _buildErrorContent();
    }
    if (_specialists.isEmpty) {
      return _buildEmptyContent();
    }
    return _buildSpecialistList();
  }

  // 💡 دالة لبناء واجهة الخطأ مع زر إعادة المحاولة
  Widget _buildErrorContent() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenSize.getWidth(5)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: red, size: ScreenSize.getWidth(12)),
            SizedBox(height: ScreenSize.getHeight(2)),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: red, fontSize: ScreenSize.getWidth(4)),
            ),
            SizedBox(height: ScreenSize.getHeight(2)),
            ElevatedButton.icon(
              onPressed: _fetchSpecialists,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  // 💡 دالة لبناء واجهة عدم وجود بيانات
  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, color: grey, size: ScreenSize.getWidth(12)),
          SizedBox(height: ScreenSize.getHeight(2)),
          Text(
            'لا توجد بيانات أخصائيين لعرضها.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: ScreenSize.getWidth(5), color: darkgrey),
          ),
        ],
      ),
    );
  }

  // 💡 دالة لبناء قائمة الأخصائيين
  Widget _buildSpecialistList() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(1)),
        itemCount: _specialists.length,
        itemBuilder: (context, index) {
          final specialist = _specialists[index];
          return _buildSpecialistTile(context, specialist);
        },
      ),
    );
  }

  // 💡 دالة منفصلة لبناء عنصر القائمة لتحسين قابلية القراءة وإعادة الاستخدام
  Widget _buildSpecialistTile(BuildContext context, Specialist specialist) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: blue,
        child: Icon(Icons.person, color: Colors.white, size: ScreenSize.getWidth(6)),
      ),
      title: Text(
        specialist.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: ScreenSize.getWidth(4.5),
        ),
      ),
      
      trailing: Icon(Icons.arrow_forward_ios, size: ScreenSize.getWidth(4)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SpecialistChildrenScreen(specialistId: specialist.id),
          ),
        ).then((_) => _fetchSpecialists());
      },
    );
  }
}