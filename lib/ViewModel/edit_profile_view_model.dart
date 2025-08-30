// import 'package:flutter/material.dart';
// import '../../services/api_service.dart';
// import 'package:youseuf_app/models/specialist.dart';

// class EditProfileViewModel extends ChangeNotifier {
//   final ApiService _apiService = ApiService();

//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();

//   bool isLoading = true;
//   String userRole = ''; // 'specialist' أو 'supervisor'

//   Future<void> fetchUserData() async {
//     isLoading = true;
//     notifyListeners();

//     try {
//       // جلب نوع المستخدم
//       userRole = await _apiService.getUserType() ?? 'unknown';

//       if (userRole == 'specialist') {
//         // جلب بيانات الأخصائي
//         final Specialist? specialist = await _apiService.getSpecialistProfile();

//         if (specialist != null) {
//           nameController.text = specialist.name ?? '';
//           phoneController.text = specialist.phoneNumber ?? '';
//           emailController.text = specialist.email ?? '';
//         }
//       } else {
//         // دعم لاحق للمشرفين إن لزم
//         nameController.text = 'غير مدعوم';
//         phoneController.text = '';
//         emailController.text = '';
//       }
//     } catch (e) {
//       debugPrint('خطأ أثناء تحميل البيانات: $e');
//     }

//     isLoading = false;
//     notifyListeners();
//   }

//   Future<bool> updateUserData() async {
//     try {
//       if (userRole == 'specialist') {
//         final success = await _apiService.updateSpecialistProfile(
//           {
//           'name': nameController.text,
//           'phone_number': phoneController.text,
//           'email': emailController.text,
//         });

//         return success != null;
//       } else {
//         debugPrint('تحديث بيانات المشرف غير مدعوم حالياً.');
//       }
//     } catch (e) {
//       debugPrint('خطأ أثناء تحديث البيانات: $e');
//     }
//     return false;
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     phoneController.dispose();
//     emailController.dispose();
//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:youseuf_app/models/specialist.dart';

class EditProfileViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isLoading = true;
  String? errorMessage; // 💡 تم إضافة متغير الخطأ
  String userRole = '';

  Future<void> fetchUserData() async {
    isLoading = true;
    errorMessage = null; // 💡 مسح أي خطأ سابق
    notifyListeners();

    try {
      userRole = await _apiService.getUserType() ?? 'unknown';

      if (userRole == 'specialist') {
        final Specialist? specialist = await _apiService.getSpecialistProfile();

        if (specialist != null) {
          nameController.text = specialist.name ?? '';
          phoneController.text = specialist.phoneNumber ?? '';
          emailController.text = specialist.email ?? '';
        } else {
          errorMessage = 'لم يتم العثور على بيانات المستخدم.';
        }
      } else {
        nameController.text = 'غير مدعوم';
        phoneController.text = '';
        emailController.text = '';
      }
    } on ApiException catch (e) {
      errorMessage = e.message; // 💡 استخدام رسالة الخطأ من ApiException
    } catch (e) {
      errorMessage = 'حدث خطأ غير متوقع: ${e.toString()}'; // 💡 خطأ عام
      debugPrint('خطأ أثناء تحميل البيانات: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUserData() async {
    try {
      if (userRole == 'specialist') {
        final success = await _apiService.updateSpecialistProfile({
          'name': nameController.text,
          'phone_number': phoneController.text,
          'email': emailController.text,
        });
        errorMessage = null; // 💡 مسح الخطأ عند النجاح
        notifyListeners();
        return success != null;
      } else {
        errorMessage = 'تحديث بيانات المشرف غير مدعوم حالياً.';
        debugPrint(errorMessage);
      }
    } on ApiException catch (e) {
      errorMessage = e.message; // 💡 استخدام رسالة الخطأ من ApiException
      notifyListeners();
    } catch (e) {
      errorMessage = 'حدث خطأ غير متوقع: ${e.toString()}'; // 💡 خطأ عام
      debugPrint('خطأ أثناء تحديث البيانات: $e');
      notifyListeners();
    }
    return false;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}