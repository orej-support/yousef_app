
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/widget/Sheared/app_bar.dart';
import 'package:youseuf_app/View/widget/Specialist/course_card_widget.dart';
import 'package:youseuf_app/ViewModel/courses_viewmodel.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart';
import 'package:youseuf_app/services/api_service.dart'; // للوصول إلى getBaseUrl

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     ScreenSize.init(context);
    return ChangeNotifierProvider(
      create: (_) => CoursesViewModel()..loadCourses(), // تحميل الدورات
      child: Scaffold(
        appBar: const CustomAppBar(title: 'الدورات'),
        body: Consumer<CoursesViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: blue),
              );
            }
        
            if (viewModel.courses.isEmpty) {
              return Center(
                child: Text(
                  "لا توجد دورات حالياً",
                  style: TextStyle(fontSize: ScreenSize.getWidth(4.5)), // 💡 استخدام نسبة مئوية
                ),
              );
            }
        
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                textDirection: TextDirection.rtl,
                children: [
                  SizedBox(height: ScreenSize.getHeight(2)),
                  ...viewModel.courses.map((course) {
                  
                    return Padding(
                      padding: EdgeInsets.only(bottom: ScreenSize.getHeight(1.3)),
                      child: CourseCardWidget(
                        image: course.imageUrl.startsWith('http')
                            ? course.imageUrl
                            : 'https://mubadarat-youssef.futureti.org${course.imageUrl}',
                        title: course.title,
                        link: course.link,
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
