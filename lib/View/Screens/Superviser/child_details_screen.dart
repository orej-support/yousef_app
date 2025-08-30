
import 'package:flutter/material.dart';
import 'package:youseuf_app/View/widget/Superviser/app_bar.dart';
import 'package:youseuf_app/services/api_service.dart' hide ChildDetailResponse;
import 'package:youseuf_app/View/Screens/Superviser/ChildDetailResponse.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد
import 'package:youseuf_app/View/widget/Sheared/back_leading.dart';

class ChildDetailsScreen extends StatefulWidget {
  final String childId;

  const ChildDetailsScreen({super.key, required this.childId});

  @override
  State<ChildDetailsScreen> createState() => _ChildDetailsScreenState();
}

class _ChildDetailsScreenState extends State<ChildDetailsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _errorMessage = '';
  ChildDetailResponse? _childDetails;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchChildDetails();
  }

  Future<void> _fetchChildDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await _apiService.getChildDetails(widget.childId);
      setState(() {
        _childDetails = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل جلب تفاصيل الابن: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _translateGender(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'male':
        return 'ذكر';
      case 'female':
        return 'أنثى';
      default:
        return 'غير معروف';
    }
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(ScreenSize.getWidth(4.5)), // 💡 استخدام نسبة مئوية
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)), // 💡 استخدام نسبة مئوية
        border: Border.all(color: grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: ScreenSize.getWidth(4.5), fontWeight: FontWeight.bold), // 💡 استخدام نسبة مئوية
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(0.5)), // 💡 استخدام نسبة مئوية
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: ScreenSize.getWidth(3.5), fontWeight: FontWeight.bold), // 💡 استخدام نسبة مئوية
              ),
              SizedBox(width: ScreenSize.getWidth(2)), // 💡 استخدام نسبة مئوية
              Text(
                value ?? 'غير متاح',
                style: TextStyle(
                  fontSize: ScreenSize.getWidth(3.5), // 💡 استخدام نسبة مئوية
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

  Widget _buildTabButton(int index, String title) {
    final selected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية
              fontWeight: FontWeight.bold,
              color: selected ? blue : Colors.black54,
            ),
          ),
          SizedBox(height: ScreenSize.getHeight(0.8)), // 💡 استخدام نسبة مئوية
          Container(
            width: ScreenSize.getWidth(23), // 💡 استخدام نسبة مئوية
            height: 3,
            decoration: BoxDecoration(
              color: selected ? blue : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    return Scaffold(
      appBar: SuperviseAppBar(
        title: _childDetails?.data?.child?.name != null
            ? 'تفاصيل الابن: ${_childDetails!.data!.child!.name}'
            : 'تفاصيل الابن',
      ),
      body: _isLoading
          ?  Center(child: CircularProgressIndicator(color: blue))
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: TextStyle(color: red)))
              : Directionality(
                  textDirection: TextDirection.rtl,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: ScreenSize.getWidth(4)), // 💡 استخدام نسبة مئوية
                    child: Column(
                    
                      children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          BackLeading(),
                        ],
                      ),
                        SizedBox(height: ScreenSize.getHeight(2)), // 💡 استخدام نسبة مئوية
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildTabButton(0, "معلومات"),
                            _buildTabButton(1, "الأقسام"),
                          ],
                        ),
                        SizedBox(height: ScreenSize.getHeight(1.8)), // 💡 استخدام نسبة مئوية
                        Expanded(
                          child: IndexedStack(
                            index: _selectedIndex,
                            children: [
                              SingleChildScrollView(
                                child: _buildSectionCard(
                                  title: 'معلومات عن الابن',
                                  children: [
                                    _buildDetailRow('الاسم', _childDetails?.data?.child?.name),
                                    _buildDetailRow('العمر',
                                        '${_childDetails?.data?.child?.age ?? ''} سنوات'),
                                    _buildDetailRow('الجنس',
                                        _translateGender(_childDetails?.data?.child?.gender)),
                                    // _buildDetailRow('المشاكل الصحية',
                                    //     _childDetails?.data?.child?.healthIssues ?? 'لا يوجد'),
                                    // _buildDetailRow('جهة الاتصال الطارئة',
                                    //     _childDetails?.data?.child?.emergencyContact ?? 'لا يوجد'),
                                    _buildDetailRow('ملاحظات عامة',
                                        _childDetails?.data?.child?.notes ?? 'لا يوجد'),
                                  ],
                                ),
                              ),
                              SingleChildScrollView(
                                child: _buildSectionCard(
                                  title: 'الأقسام والأخصائيون',
                                  children: _childDetails?.data?.uniqueDepartmentsWithSpecialists
                                          ?.expand((dept) => [
                                                Text('${dept.name} (${dept.departmentNumber ?? ''})',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية
                                                        color: Colors.teal)),
                                                SizedBox(height: ScreenSize.getHeight(0.5)), // 💡 استخدام نسبة مئوية
                                                ...dept.associatedSpecialists.map(
                                                  (spec) => Text(
                                                    ' - ${spec.name} (منذ: ${spec.relationCreatedAt?.toLocal().toIso8601String().substring(0, 10) ?? 'غير معروف'})',
                                                    style: TextStyle(
                                                      fontSize: ScreenSize.getWidth(3.2), // 💡 استخدام نسبة مئوية
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                                const Divider(),
                                              ])
                                          .toList() ??
                                      [],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}