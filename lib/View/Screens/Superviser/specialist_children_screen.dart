import 'package:flutter/material.dart';
import 'package:youseuf_app/View/Screens/Superviser/child_details_screen.dart';
import 'package:youseuf_app/View/widget/Sheared/back_leading.dart';
import 'package:youseuf_app/View/widget/Superviser/app_bar.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/icons.dart';
import 'package:youseuf_app/models/child.dart';
import 'package:youseuf_app/models/specialist.dart';
import 'package:youseuf_app/services/api_service.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد

class SpecialistChildrenScreen extends StatefulWidget {
  final String specialistId;

  const SpecialistChildrenScreen({super.key, required this.specialistId});

  @override
  State<SpecialistChildrenScreen> createState() =>
      _SpecialistChildrenScreenState();
}

class _SpecialistChildrenScreenState extends State<SpecialistChildrenScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _errorMessage = '';
  Specialist? _specialist;
  List<Child> _children = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final data =
          await _apiService.getSpecialistChildrenData(widget.specialistId);
      setState(() {
        _specialist = data['specialist'] as Specialist?;
        _children = (data['children'] as List<Child>?) ?? [];
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل جلب البيانات: ${e.toString()}';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: SuperviseAppBar(
          title:
              'الأبناء تحت إشراف ${_specialist?.name ?? 'الأخصائي'}', // 💡 عنوان متجاوب
        ),
        body: _buildBody(),
      ),
    );
  }

  // 💡 دالة بناء محتوى الشاشة
  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: blue));
    }
    if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    }
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            BackLeading(),
          ],
        ),
        _buildProfileCard(),
        _buildChildrenList(),
      ],
    );
  }

  // 💡 دالة بناء واجهة الخطأ مع زر إعادة المحاولة
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: red, size: ScreenSize.getWidth(12)),
          SizedBox(height: ScreenSize.getHeight(2)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenSize.getWidth(5)),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: red, fontSize: ScreenSize.getWidth(4)),
            ),
          ),
          SizedBox(height: ScreenSize.getHeight(2)),
          ElevatedButton.icon(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  // 💡 بطاقة الأخصائي متجاوبة
  Widget _buildProfileCard() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(2)),
      child: Center(
        child: Container(
          width: ScreenSize.getWidth(90),
          padding: EdgeInsets.symmetric(
              horizontal: ScreenSize.getWidth(4),
              vertical: ScreenSize.getHeight(2)),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)),
            border: Border.all(color: grey300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icons/person.png',
                  height: ScreenSize.getHeight(3.5)),
              SizedBox(width: ScreenSize.getWidth(3)),
              Text(
                'الأخصائي: ${_specialist?.name ?? 'غير محدد'}',
                style: TextStyle(
                  fontSize: ScreenSize.getWidth(4.5),
                  fontWeight: FontWeight.bold,
                  color: black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 💡 قائمة الأبناء
  Widget _buildChildrenList() {
    if (_children.isEmpty) {
      return Expanded(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(ScreenSize.getWidth(4)),
            child: Text(
              "لا يوجد أبناء مرتبطون بهذا الأخصائي.",
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: ScreenSize.getWidth(4), color: darkgrey),
            ),
          ),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        itemCount: _children.length,
        itemBuilder: (context, index) {
          final child = _children[index];
          return Padding(
            key: ValueKey(child.id),
            padding: EdgeInsets.symmetric(horizontal: ScreenSize.getWidth(5)),
            child: _buildChildItem(context, child),
          );
        },
      ),
    );
  }

  // 💡 عنصر قائمة الابن
  Widget _buildChildItem(BuildContext context, Child child) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenSize.getHeight(1.5)),
      padding: EdgeInsets.all(ScreenSize.getWidth(3)),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(ScreenSize.getWidth(2.5)),
        border: Border.all(color: grey300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/icons/person.png',
                  height: ScreenSize.getHeight(3.5)),
              SizedBox(width: ScreenSize.getWidth(2.5)),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "الابن: ",
                      style: TextStyle(
                        fontSize: ScreenSize.getWidth(4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: child.name,
                      style: TextStyle(
                        color: blue,
                        fontSize: ScreenSize.getWidth(4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChildDetailsScreen(childId: child.id),
                ),
              );
            },
            icon: Icon(Icons.chevron_right,
                color: blue, size: ScreenSize.getWidth(6)),
          ),
        ],
      ),
    );
  }
}
