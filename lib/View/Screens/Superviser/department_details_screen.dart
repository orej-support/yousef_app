import 'package:flutter/material.dart';
import 'package:youseuf_app/View/Screens/Superviser/specialist_children_screen.dart';
import 'package:youseuf_app/View/widget/Sheared/back_leading.dart';
import 'package:youseuf_app/View/widget/Superviser/app_bar.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد
import 'package:youseuf_app/models/department.dart';
import 'package:youseuf_app/models/specialist.dart';
import 'package:youseuf_app/services/api_service.dart';

class DepartmentDetailsScreen extends StatefulWidget {
  final String departmentId;

  const DepartmentDetailsScreen({super.key, required this.departmentId});

  @override
  State<DepartmentDetailsScreen> createState() =>
      _DepartmentDetailsScreenState();
}

class _DepartmentDetailsScreenState extends State<DepartmentDetailsScreen> {
  late Future<Department> _departmentFuture;

  @override
  void initState() {
    super.initState();
    _fetchDepartmentDetails();
  }

  void _fetchDepartmentDetails() {
    _departmentFuture =
        ApiService().getDepartmentDetailsData(context,widget.departmentId);
  }

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد
    ScreenSize.init(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const SuperviseAppBar(title: "تفاصيل القسم"),
        body: FutureBuilder<Department>(
          future: _departmentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: blue));
            } else if (snapshot.hasError) {
              // 💡 عرض رسالة خطأ مع خيار إعادة المحاولة
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 50),
                    SizedBox(height: ScreenSize.getHeight(2)),
                    Text(
                      'خطأ في جلب البيانات: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.red, fontSize: ScreenSize.getWidth(4)),
                    ),
                    SizedBox(height: ScreenSize.getHeight(2)),
                    ElevatedButton(
                      onPressed: _fetchDepartmentDetails,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(child: Text('لا توجد بيانات لهذا القسم.'));
            }

            final department = snapshot.data!;
            return Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BackLeading(),
                  ],
                ),
                _buildDepartmentInfo(department),
                Expanded(
                  child: _buildSpecialistsList(context, department.specialists),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 💡 بطاقة بيانات القسم (متجاوبة)
  Widget _buildDepartmentInfo(Department department) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: ScreenSize.getHeight(2)), // 💡 استخدام نسبة مئوية
      child: Center(
        child: Container(
          width: ScreenSize.getWidth(90), // 💡 استخدام نسبة مئوية
          padding:
              EdgeInsets.all(ScreenSize.getWidth(4)), // 💡 استخدام نسبة مئوية
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(
                ScreenSize.getWidth(3)), // 💡 استخدام نسبة مئوية
            border: Border.all(color: grey300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.apartment,
                      color: blue,
                      size: ScreenSize.getWidth(5.5)), // 💡 استخدام نسبة مئوية
                  SizedBox(
                      width: ScreenSize.getWidth(2)), // 💡 استخدام نسبة مئوية
                  Text(
                    department.name,
                    style: TextStyle(
                      fontSize: ScreenSize.getWidth(5), // 💡 استخدام نسبة مئوية
                      fontWeight: FontWeight.bold,
                      color: black,
                    ),
                  ),
                ],
              ),
              SizedBox(
                  height: ScreenSize.getHeight(1)), // 💡 استخدام نسبة مئوية
              if (department.description != null &&
                  department.description!.isNotEmpty)
                Text(
                  department.description!,
                  style: TextStyle(
                      fontSize: ScreenSize.getWidth(3.5),
                      color: darkgrey), // 💡 استخدام نسبة مئوية
                ),
              if (department.createdAt != null) ...[
                SizedBox(
                    height: ScreenSize.getHeight(1)), // 💡 استخدام نسبة مئوية
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: ScreenSize.getWidth(4),
                        color: Colors.grey), // 💡 استخدام نسبة مئوية
                    SizedBox(
                        width:
                            ScreenSize.getWidth(1.5)), // 💡 استخدام نسبة مئوية
                    Text(
                      'تاريخ الإنشاء: ${department.createdAt.toString().split(" ").first}',
                      style: TextStyle(
                          fontSize: ScreenSize.getWidth(3.2),
                          color: Colors.grey), // 💡 استخدام نسبة مئوية
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 💡 قائمة الأخصائيين (متجاوبة)
  Widget _buildSpecialistsList(
      BuildContext context, List<Specialist> specialists) {
    if (specialists.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد أخصائيون في هذا القسم.',
          style: TextStyle(
              fontSize: ScreenSize.getWidth(4),
              color: Colors.grey), // 💡 استخدام نسبة مئوية
        ),
      );
    }

    return ListView.builder(
      itemCount: specialists.length,
      itemBuilder: (context, index) {
        final specialist = specialists[index];
        return Padding(
          key: ValueKey(specialist.id),
          padding: EdgeInsets.symmetric(
            horizontal: ScreenSize.getWidth(5), // 💡 استخدام نسبة مئوية
            vertical: ScreenSize.getHeight(0.8), // 💡 استخدام نسبة مئوية
          ),
          child: Container(
            padding: EdgeInsets.all(
                ScreenSize.getWidth(3.5)), // 💡 استخدام نسبة مئوية
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(
                  ScreenSize.getWidth(2.5)), // 💡 استخدام نسبة مئوية
              border: Border.all(color: grey300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset('assets/icons/person.png',
                        height:
                            ScreenSize.getHeight(3.5)), // 💡 استخدام نسبة مئوية
                    SizedBox(
                        width:
                            ScreenSize.getWidth(2.5)), // 💡 استخدام نسبة مئوية
                    Text(
                      specialist.name,
                      style: TextStyle(
                        color: blue,
                        fontSize:
                            ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right,
                      color: blue,
                      size: ScreenSize.getWidth(6)), // 💡 استخدام نسبة مئوية
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SpecialistChildrenScreen(
                            specialistId: specialist.id),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
