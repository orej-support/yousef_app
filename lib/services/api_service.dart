import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io'; // For SocketException
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:youseuf_app/core/utils/error.dart';
import 'package:youseuf_app/models/child.dart';
import 'package:youseuf_app/models/conversation.dart';
import 'package:youseuf_app/models/course.dart';
import 'package:youseuf_app/models/department.dart';
import 'package:youseuf_app/models/message.dart';
import 'package:youseuf_app/models/specialist.dart';
import 'package:youseuf_app/models/user.dart';
import 'package:youseuf_app/models/branch.dart';
import 'package:youseuf_app/models/report_family.dart';
import 'package:youseuf_app/View/Screens/Superviser/ChildDetailResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});
  factory ApiException.fromError(String errorMessage, {int? statusCode}) {
    return ApiException(errorMessage, statusCode: statusCode);
  }

  @override
  String toString() {
    return message; // إرجاع الرسالة نفسها بدل Instance of
  }
}

class ApiResponse {
  final bool status; // يمكن أن تكون true/false بناءً على استجابة Laravel
  final String message;
  final dynamic data; // Can be a map, list, or null

  ApiResponse({required this.status, required this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    bool successStatus =
        json['status'] ?? true; // افتراض true إذا لم يكن هناك حقل 'status'
    if (json.containsKey('error') || json.containsKey('errors')) {
      successStatus = false;
    }
    return ApiResponse(
      status: successStatus,
      message: json['message'] ?? 'Unknown message',
      data: json.containsKey('data') ? json['data'] : null,
    );
  }
}

class ApiService {
  final String _baseUrl = "https://mubadarat-youssef.futureti.org/api";
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'authToken');
  }

  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: 'authToken', value: token);
  }

  Future<String?> getUserType() async {
    return await _secureStorage.read(key: 'userType');
  }

  Future<void> _saveUserType(String type) async {
    await _secureStorage.write(key: 'userType', value: type);
  }

  Future<String?> getSpecialistId() async {
    return await _secureStorage.read(key: 'specialistId');
  }

  Future<void> _saveSpecialistId(String id) async {
    await _secureStorage.write(key: 'specialistId', value: id);
  }

  Future<String?> getCurrentUserId() async {
    // 💡 غير نوع الإرجاع إلى String?
    String? idString = await _secureStorage.read(key: 'currentUserId');
    return idString;
  }

  Future<void> _saveCurrentUserId(String id) async {
    await _secureStorage.write(key: 'currentUserId', value: id.toString());
  }

  Future<void> _savePermissions(List<String> permissions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_permissions', permissions);
  }

  Future<List<String>> getPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('user_permissions') ?? [];
  }

  Future<void> _clearAllAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    await FirebaseMessaging.instance.deleteToken();
    await prefs.remove('user_permissions');

    await _secureStorage.delete(key: 'authToken');
    await _secureStorage.delete(key: 'userType');
    await _secureStorage.delete(
        key: 'specialistId'); // May not be present for users
    await _secureStorage.delete(key: 'currentUserId'); // Clear current user ID
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    String deviceId = 'unknown_id';
    String deviceName = 'unknown_device';
    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo =
            await deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.id; // Unique ID for Android
        deviceName = androidInfo.model ?? 'Android Device';
        if (kDebugMode) {
          debugPrint(
              'ApiService: _getDeviceInfo - Android ID: ${androidInfo.id}, Model: ${androidInfo.model}');
        }
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor ??
            'unknown_ios_id'; // Unique ID for iOS
        deviceName = iosInfo.name ?? 'iOS Device';
        if (kDebugMode) {
          debugPrint(
              'ApiService: _getDeviceInfo - iOS Vendor ID: ${iosInfo.identifierForVendor}, Name: ${iosInfo.name}');
        }
      } else if (Platform.isLinux) {
        final LinuxDeviceInfo linuxInfo = await deviceInfoPlugin.linuxInfo;
        deviceId = linuxInfo.id; // Unique ID for Linux
        deviceName = linuxInfo.prettyName ?? 'Linux Device';
        if (kDebugMode) {
          debugPrint(
              'ApiService: _getDeviceInfo - Linux ID: ${linuxInfo.id}, Name: ${linuxInfo.prettyName}');
        }
      } else if (Platform.isMacOS) {
        final MacOsDeviceInfo macOsInfo = await deviceInfoPlugin.macOsInfo;
        deviceId =
            macOsInfo.systemGUID ?? 'unknown_macos_id'; // Unique ID for macOS
        deviceName = macOsInfo.model ?? 'macOs Device';
        if (kDebugMode) {
          debugPrint(
              'ApiService: _getDeviceInfo - macOS GUID: ${macOsInfo.systemGUID}, Model: ${macOsInfo.model}');
        }
      } else if (Platform.isWindows) {
        final WindowsDeviceInfo windowsInfo =
            await deviceInfoPlugin.windowsInfo;
        deviceId = windowsInfo.deviceId; // Unique ID for Windows
        deviceName = windowsInfo.computerName ?? 'Windows Device';
        if (kDebugMode) {
          debugPrint(
              'ApiService: _getDeviceInfo - Windows ID: ${windowsInfo.deviceId}, Name: ${windowsInfo.computerName}');
        }
      } else {
        // Fallback for Web/Unknown, will change on every call, which is a known limitation
        deviceId =
            'web_or_unknown_platform_id_${DateTime.now().millisecondsSinceEpoch}';
        deviceName = 'Web_Browser_or_Unknown_Platform';
        if (kDebugMode) {
          debugPrint(
              'ApiService: _getDeviceInfo - Web/Unknown Platform. Generated ID: $deviceId');
        }
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
      deviceId =
          'device_info_error_fallback_id_${DateTime.now().millisecondsSinceEpoch}';
      deviceName = 'Device_Info_Error_Fallback';
    }
    if (kDebugMode) {
      debugPrint(
          'ApiService: _getDeviceInfo - Final Device ID: $deviceId, Final Device Name: $deviceName');
    }
    return {'id': deviceId, 'name': deviceName};
  }

  dynamic _handleResponse(http.Response response) {
    if (kDebugMode) {
      // استخدام kDebugMode لطباعة الـ debug فقط في وضع التطوير
      debugPrint(
          'ApiService: _handleResponse - Status Code: ${response.statusCode}');
      debugPrint(
          'ApiService: _handleResponse - Response Body: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // إذا كانت الاستجابة ناجحة (2xx)
      // تحقق مما إذا كان الجسم فارغًا أو غير صالح كـ JSON
      if (response.body.isEmpty || response.body == 'null') {
        return {}; // أعد خريطة فارغة إذا كان الجسم فارغًا أو null
      }
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ApiException('Failed to decode JSON response from server.',
            statusCode: response.statusCode);
      }
    } else {
      // إذا كانت هناك أخطاء HTTP (4xx, 5xx)
      return _handleErrorResponse(
          response); // استخدم دالة معالجة الأخطاء الموجودة لديك
    }
  }

  ApiException _handleErrorResponse(http.Response response) {
    try {
      final Map<String, dynamic> errorData = json.decode(response.body);
      String errorMessage =
          errorData['message'] ?? 'An unknown error occurred.';

      // Laravel validation errors often come in an 'errors' field
      if (errorData.containsKey('errors') && errorData['errors'] is Map) {
        (errorData['errors'] as Map).forEach((key, value) {
          if (value is List) {
            errorMessage += '\n${value.join(', ')}';
          } else {
            errorMessage += '\n$value';
          }
        });
      }
      return ApiException(errorMessage, statusCode: response.statusCode);
    } on FormatException {
      return ApiException('Failed to parse error response from server.',
          statusCode: response.statusCode);
    } catch (e) {
      return ApiException(
          'An unexpected error occurred: ${response.statusCode}',
          statusCode: response.statusCode);
    }
  }

  Future<Map<String, dynamic>?> loginSpecialist(
      String email, String password) async {
    if (kDebugMode) {
      debugPrint('ApiService: Attempting login for specialist: $email');
    }
    try {
      final Map<String, String> deviceInfo = await _getDeviceInfo();
      final String deviceName = deviceInfo['name']!;
      final String deviceId = deviceInfo['id']!;

      if (kDebugMode) {
        debugPrint(
            'ApiService: Specialist Login - Device Info - Name: $deviceName, ID: $deviceId');
        debugPrint(
            'ApiService: Sending specialist login request to $_baseUrl/specialists/login');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/specialists/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_name': deviceName,
          'device_id': deviceId,
        }),
      );

      if (kDebugMode) {
        debugPrint(
            'ApiService: Specialist login response status code: ${response.statusCode}');
        debugPrint(
            'ApiService: Specialist login response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (kDebugMode) {
          debugPrint(
              'ApiService: Response data decoded successfully: $responseData');
        }

        // تحقق مما إذا كانت الاستجابة تحتوي على بيانات المستخدم العادي
        if (responseData.containsKey('user') &&
            responseData.containsKey('token')) {
          final String token = responseData['token'];
          final Map<String, dynamic> userData = responseData['user'];
          final String userRole = userData['role'];
          final String currentUserId = userData['id'].toString();

          await _saveToken(token);
          await _saveUserType(userRole);
          await _saveCurrentUserId(currentUserId);

          return {
            'success': true,
            'message': responseData['message'] ??
                'تم تسجيل الدخول بنجاح كمستخدم!' // هنا ممكن تحطي ErrorMessages إذا تبغي توحيد أكثر
          };
        }

        if (responseData.containsKey('specialist') &&
            responseData.containsKey('token')) {
          final String token = responseData['token'];
          final String specialistId = responseData['specialist']['id'];

          await _saveToken(token);
          await _saveUserType('specialist');
          await _saveSpecialistId(specialistId);
          await _saveCurrentUserId(specialistId);

          return responseData;
        } else {
          throw ApiException(
            responseData['message'] ??
                ErrorMessages.loginFailedUnexpectedFormat,
            statusCode: response.statusCode,
          );
        }
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      if (e is SocketException || e is http.ClientException) {
        // فقط لا يوجد اتصال بالإنترنت
        throw ApiException(ErrorMessages.noInternetConnection);
        return null; // أضف هذا السطر لإرجاع null في حالة عدم وجود اتصال بالإنترنت
      } else if (e is ApiException) {
        rethrow;
      } else {
        // أخطاء ثانية غير متوقعة
        throw ApiException(ErrorMessages.unexpectedError);
      }
    }

    // catch (e) {
    //   if (e is SocketException) {
    //     throw ApiException(ErrorMessages.noInternetConnection);
    //   } else if (e is ApiException) {
    //     rethrow;
    //   } else {
    //     throw ApiException(ErrorMessages.unexpectedError);
    //   }
    // }
  }

  // Future<Map<String, dynamic>?> logoutSpecialist(BuildContext context) async {
  //   if (kDebugMode) {
  //     debugPrint('ApiService: Attempting specialist logout...');
  //   }
  //   String? fcmToken;
  //   String? authToken;
  //   String deviceId;
  //   try {
  //     // 1. الحصول على FCM Token ومعلومات الجهاز
  //     fcmToken = await FirebaseMessaging.instance.getToken();
  //     authToken = await getToken();
  //     final Map<String, String> deviceInfo = await _getDeviceInfo();
  //     deviceId = deviceInfo['id']!;

  //     if (kDebugMode) {
  //       debugPrint(
  //           'ApiService: Specialist Logout - FCM Token: $fcmToken, Device ID: $deviceId, Auth Token: $authToken');
  //     }

  //     // 2. حذف FCM Token من الـ Backend
  //     if (fcmToken != null && authToken != null) {
  //       await deleteFcmTokenFromBackend(fcmToken, deviceId, authToken);
  //     }

  //     // 3. إرسال طلب تسجيل الخروج الفعلي
  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/specialists/logout'),
  //       headers: await _getAuthHeaders(),
  //     );

  //     if (response.statusCode == 200) {
  //       if (kDebugMode) {
  //         debugPrint('ApiService: Specialist logout successful from backend.');
  //       }
  //       return {'status': true, 'message': 'تم تسجيل الخروج للأخصائي بنجاح'};
  //     } else {
  //       throw ApiException(
  //         '${ErrorMessages.logoutFailed}${response.statusCode}',
  //       );
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('ApiService: Error during specialist logout: $e');
  //     }

  //     // 👇 هنا نعرض الخطأ في Dialog
  //     showErrorDialog(
  //       context,
  //       'خطأ',
  //       '${ErrorMessages.logoutFailed}${e.toString()}',
  //     );

  //     throw ApiException('${ErrorMessages.logoutFailed}${e.toString()}');
  //   } finally {
  //     // 4. مسح بيانات المصادقة
  //     await _clearAllAuthData();
  //   }
  // }
Future<Map<String, dynamic>?> logoutSpecialist(BuildContext context) async {
  if (kDebugMode) {
    debugPrint('ApiService: Attempting specialist logout...');
  }

  String? fcmToken;
  String? authToken;
  String deviceId;

  try {
    // 1. الحصول على FCM Token ومعلومات الجهاز
    fcmToken = await FirebaseMessaging.instance.getToken();
    authToken = await getToken();
    final Map<String, String> deviceInfo = await _getDeviceInfo();
    deviceId = deviceInfo['id']!;

    if (kDebugMode) {
      debugPrint(
          'ApiService: Specialist Logout - FCM Token: $fcmToken, Device ID: $deviceId, Auth Token: $authToken');
    }

    // 2. حذف FCM Token من الـ Backend
    if (fcmToken != null && authToken != null) {
      await deleteFcmTokenFromBackend(fcmToken, deviceId, authToken);
    }

    // 3. إرسال طلب تسجيل الخروج الفعلي
    final response = await http.post(
      Uri.parse('$_baseUrl/specialists/logout'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        debugPrint('ApiService: Specialist logout successful from backend.');
      }
      return {'status': true, 'message': 'تم تسجيل الخروج للأخصائي بنجاح'};
    } else {
      throw ApiException(
        '${ErrorMessages.logoutFailed}${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  } on SocketException {
    showErrorDialog(context, 'خطأ', ErrorMessages.noInternetConnection);
    throw ApiException(ErrorMessages.noInternetConnection);
  } on ApiException catch (e) {
    showErrorDialog(context, 'خطأ', e.message);
    rethrow;
  } catch (e) {
    showErrorDialog(
      context,
      'خطأ غير متوقع',
      '${ErrorMessages.unexpectedError} $e',
    );
    throw ApiException('${ErrorMessages.unexpectedError} $e');
  } finally {
    // 4. مسح بيانات المصادقة
    await _clearAllAuthData();
  }
}

Future<ApiResponse> forgotPasswordSpecialist(
    BuildContext context, String email) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/specialists/forgot-password'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(jsonDecode(response.body));
    } else {
      throw _handleErrorResponse(response);
    }
  } catch (e) {
    if (e is SocketException) {
      // خطأ انترنت
      showErrorDialog(
        context,
        'خطأ في الاتصال',
        ErrorMessages.noInternetConnection,
      );
      throw ApiException(ErrorMessages.noInternetConnection);
    } else if (e is ApiException) {
      // خطأ API معروف
      showErrorDialog(
        context,
        'خطأ',
        e.toString(),
      );
      rethrow;
    } else {
      // خطأ غير متوقع
      final msg =
          '${ErrorMessages.unexpectedErrorForgotPasswordSpecialist}$e';
      showErrorDialog(
        context,
        'خطأ غير متوقع',
        msg,
      );
      throw ApiException(msg);
    }
  }
}

  // Future<ApiResponse> forgotPasswordSpecialist(String email) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse(
  //           '$_baseUrl/specialists/forgot-password'), // المسار الصحيح للأخصائي
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json'
  //       },
  //       body: jsonEncode({'email': email}),
  //     );

  //     if (response.statusCode == 200) {
  //       return ApiResponse.fromJson(jsonDecode(response.body));
  //     } else {
  //       throw _handleErrorResponse(response);
  //     }
  //   } catch (e) {
  //     if (e is SocketException) {
  //       throw ApiException('لا يوجد اتصال بالإنترنت.');
  //     } else if (e is ApiException) {
  //       rethrow;
  //     } else {
  //       throw ApiException(
  //           'حدث خطأ غير متوقع أثناء طلب إعادة تعيين كلمة المرور للأخصائي: $e');
  //     }
  //   }
  // }

Future<ApiResponse> verifyOtpSpecialist(
    BuildContext context, String email, String otp) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/specialists/verify-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        'email': email,
        'token': otp, // Laravel API expects 'token'
      }),
    );

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(jsonDecode(response.body));
    } else {
      throw _handleErrorResponse(response);
    }
  } catch (e) {
    if (e is SocketException) {
      // خطأ انترنت
      showErrorDialog(
        context,
        'خطأ في الاتصال',
        ErrorMessages.noInternetConnection,
      );
      throw ApiException(ErrorMessages.noInternetConnection);
    } else if (e is ApiException) {
      // خطأ API معروف
      showErrorDialog(
        context,
        'خطأ',
        e.toString(),
      );
      rethrow;
    } else {
      // خطأ غير متوقع
      final msg =
          '${ErrorMessages.unexpectedErrorVerifyOtpSpecialist}${e.toString()}';
      showErrorDialog(
        context,
        'خطأ غير متوقع',
        msg,
      );
      throw ApiException(msg);
    }
  }
}

  // Future<ApiResponse> verifyOtpSpecialist(String email, String otp) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/specialists/verify-otp'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json'
  //       },
  //       body: jsonEncode({
  //         'email': email,
  //         'token': otp, // The 'token' field in Laravel API expects the OTP
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       return ApiResponse.fromJson(jsonDecode(response.body));
  //     } else {
  //       throw _handleErrorResponse(response);
  //     }
  //   } catch (e) {
  //     if (e is SocketException) {
  //       throw ApiException('لا يوجد اتصال بالإنترنت.');
  //     } else if (e is ApiException) {
  //       rethrow;
  //     } else {
  //       throw ApiException(
  //           'حدث خطأ غير متوقع أثناء التحقق من رمز التأكيد للأخصائي: ${e.toString()}');
  //     }
  //   }
  // }

  // Future<ApiResponse> resetPasswordSpecialist(String email, String otp,
  //     String newPassword, String confirmPassword) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse(
  //           '$_baseUrl/specialists/reset-password'), // The correct path for the specialist
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json'
  //       },
  //       body: jsonEncode({
  //         'email': email,
  //         'token': otp, // The OTP is sent again here
  //         'password': newPassword,
  //         'password_confirmation':
  //             confirmPassword, // Important for Laravel's 'confirmed' rule
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       return ApiResponse.fromJson(jsonDecode(response.body));
  //     } else {
  //       throw _handleErrorResponse(response);
  //     }
  //   } catch (e) {
  //     if (e is SocketException) {
  //       throw ApiException('لا يوجد اتصال بالإنترنت.');
  //     } else if (e is ApiException) {
  //       rethrow;
  //     } else {
  //       throw ApiException(
  //           'حدث خطأ غير متوقع أثناء إعادة تعيين كلمة المرور للأخصائي: $e');
  //     }
  //   }
  // }

Future<ApiResponse> resetPasswordSpecialist(
  BuildContext context,
  String email,
  String otp,
  String newPassword,
  String confirmPassword,
) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/specialists/reset-password'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        'email': email,
        'token': otp, // OTP يُرسل مرة ثانية
        'password': newPassword,
        'password_confirmation': confirmPassword, // Laravel confirmed rule
      }),
    );

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(jsonDecode(response.body));
    } else {
      throw _handleErrorResponse(response);
    }
  } catch (e) {
    if (e is SocketException) {
      // خطأ انترنت
      showErrorDialog(
        context,
        'خطأ في الاتصال',
        ErrorMessages.noInternetConnection,
      );
      throw ApiException(ErrorMessages.noInternetConnection);
    } else if (e is ApiException) {
      // خطأ API معروف
      showErrorDialog(
        context,
        'خطأ',
        e.toString(),
      );
      rethrow;
    } else {
      // خطأ غير متوقع
      final msg =
          '${ErrorMessages.unexpectedErrorResetPasswordSpecialist}${e.toString()}';
      showErrorDialog(
        context,
        'خطأ غير متوقع',
        msg,
      );
      throw ApiException(msg);
    }
  }
}
Future<Map<String, dynamic>?> loginUser(String email, String password) async {
  if (kDebugMode) {
    debugPrint('ApiService: Attempting login for user: $email');
  }
  try {
    final Map<String, String> deviceInfo = await _getDeviceInfo();
    final String deviceName = deviceInfo['name']!;
    final String deviceId = deviceInfo['id']!;

    if (kDebugMode) {
      debugPrint(
          'ApiService: Login - Device Info - Name: $deviceName, ID: $deviceId');
      debugPrint('ApiService: Sending login request to $_baseUrl/login');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'device_name': deviceName,
        'device_id': deviceId,
      }),
    );

    if (kDebugMode) {
      debugPrint(
          'ApiService: Login response status code: ${response.statusCode}');
      debugPrint('ApiService: Login response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (kDebugMode) {
        debugPrint('ApiService: Login - Response data decoded successfully.');
      }

      if (responseData.containsKey('user') &&
          responseData.containsKey('token')) {
        final String token = responseData['token'];
        final int userId = responseData['user']['id'];
        final List<String> permissions =
            List<String>.from(responseData['user']['permissions'] ?? []);

        await _saveToken(token);
        await _saveUserType('user');
        await _saveCurrentUserId(userId.toString());
        await _savePermissions(permissions);

        return responseData; // إرجاع الاستجابة الكاملة
      } else {
        throw ApiException(
          responseData['message'] ?? ErrorMessages.loginFailedUnexpectedFormat,
          statusCode: response.statusCode,
        );
      }
    } else {
      throw _handleErrorResponse(response);
    }
  } on SocketException {
    throw ApiException(ErrorMessages.noInternetConnection);
  } on ApiException {
    rethrow; // الرسالة أصلاً مضبوطة من قبل
  } catch (e) {
    throw ApiException('${ErrorMessages.unexpectedError} $e');
  }
}


  // Future<Map<String, dynamic>?> loginUser(String email, String password) async {
  //   if (kDebugMode) {
  //     debugPrint('ApiService: Attempting login for user: $email');
  //   }
  //   try {
  //     final Map<String, String> deviceInfo = await _getDeviceInfo();
  //     final String deviceName = deviceInfo['name']!;
  //     final String deviceId = deviceInfo['id']!;

  //     if (kDebugMode) {
  //       debugPrint(
  //           'ApiService: Login - Device Info - Name: $deviceName, ID: $deviceId');
  //       debugPrint('ApiService: Sending login request to $_baseUrl/login');
  //     }

  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/login'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json'
  //       },
  //       body: jsonEncode({
  //         'email': email,
  //         'password': password,
  //         'device_name': deviceName,
  //         'device_id': deviceId, // <--- إرسال deviceId عند تسجيل الدخول
  //       }),
  //     );

  //     if (kDebugMode) {
  //       debugPrint(
  //           'ApiService: Login response status code: ${response.statusCode}');
  //       debugPrint('ApiService: Login response body: ${response.body}');
  //     }

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = jsonDecode(response.body);
  //       if (kDebugMode) {
  //         debugPrint('ApiService: Login - Response data decoded successfully.');
  //       }

  //       if (responseData.containsKey('user') &&
  //           responseData.containsKey('token')) {
  //         final String token = responseData['token'];
  //         final int userId = responseData['user']['id'];
  //         final List<String> permissions =
  //             List<String>.from(responseData['user']['permissions'] ?? []);

  //         if (kDebugMode) {
  //           debugPrint(
  //               'ApiService: Login successful. Token received, User ID: $userId');
  //           debugPrint('ApiService: Attempting to save auth token...');
  //         }
  //         await _saveToken(token);
  //         if (kDebugMode) {
  //           debugPrint('ApiService: Auth token saved.');
  //           debugPrint('ApiService: Attempting to save user type...');
  //         }
  //         await _saveUserType('user');
  //         if (kDebugMode) {
  //           debugPrint('ApiService: User type saved.');
  //           debugPrint('ApiService: Attempting to save current user ID...');
  //         }
  //         await _saveCurrentUserId(
  //             userId.toString()); // تحويل int إلى String للحفظ
  //         if (kDebugMode) {
  //           debugPrint(
  //               'ApiService: Current user ID saved. Login process completed.');
  //         }

  //         await _savePermissions(permissions);

  //         return responseData; // إرجاع الاستجابة الكاملة
  //       } else {
  //         if (kDebugMode) {
  //           debugPrint(
  //               'ApiService: Login successful (status 200) but missing "user" or "token" in response. Response keys: ${responseData.keys.join(', ')}');
  //         }
  //         throw ApiException(
  //             responseData['message'] ??
  //                 'فشل تسجيل الدخول: تنسيق استجابة غير متوقع.',
  //             statusCode: response.statusCode);
  //       }
  //     } else {
  //       if (kDebugMode) {
  //         debugPrint(
  //             'ApiService: Login failed with non-200 status code. Handling error response.');
  //       }
  //       throw _handleErrorResponse(response);
  //     }
  //   } catch (e) {
  //     if (e is SocketException) {
  //       if (kDebugMode) {
  //         debugPrint('ApiService: Network error during login: $e');
  //       }
  //       throw ApiException('لا يوجد اتصال بالإنترنت.');
  //     } else if (e is ApiException) {
  //       if (kDebugMode) {
  //         debugPrint(
  //             'ApiService: API exception during login: ${e.message}, Status: ${e.statusCode}');
  //       }
  //       rethrow;
  //     } else {
  //       if (kDebugMode) {
  //         debugPrint('ApiService: Unexpected error during login: $e');
  //       }
  //       throw ApiException('حدث خطأ غير متوقع: $e');
  //     }
  //   }
  // }

  // Future<Map<String, dynamic>?> logoutUser() async {
  //   if (kDebugMode) {
  //     debugPrint('ApiService: Attempting user logout...');
  //   }
  //   String? fcmToken;
  //   String? authToken;
  //   String deviceId;
  //   try {
  //     // 1. الحصول على FCM Token ومعلومات الجهاز قبل محاولة تسجيل الخروج
  //     fcmToken = await FirebaseMessaging.instance.getToken();
  //     authToken = await getToken(); // جلب التوكن الحالي
  //     final Map<String, String> deviceInfo = await _getDeviceInfo();
  //     deviceId = deviceInfo['id']!;

  //     if (kDebugMode) {
  //       debugPrint(
  //           'ApiService: User Logout - FCM Token: $fcmToken, Device ID: $deviceId, Auth Token: $authToken');
  //     }

  //     // 🚀🚀🚀 أولاً: حاول حذف FCM Token من الـ Backend 🚀🚀🚀
  //     if (fcmToken != null && authToken != null) {
  //       await deleteFcmTokenFromBackend(fcmToken, deviceId, authToken);
  //     } else {
  //       if (kDebugMode) {
  //         debugPrint(
  //             'ApiService: FCM Token or Auth Token missing for user logout, skipping FCM deletion attempt.');
  //       }
  //     }

  //     // 🚀🚀🚀 ثانياً: أرسل طلب تسجيل الخروج الفعلي إلى الـ Backend 🚀🚀🚀
  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/logout'),
  //       headers:
  //           await _getAuthHeaders(), // لا يزال يستخدم التوكن من SharedPreferences
  //     );

  //     if (response.statusCode == 200) {
  //       if (kDebugMode) {
  //         debugPrint('ApiService: User logout successful from backend.');
  //       }
  //       return {'status': true, 'message': 'تم تسجيل الخروج بنجاح'};
  //     } else {
  //       if (kDebugMode) {
  //         debugPrint(
  //             'ApiService: User logout failed from backend with status: ${response.statusCode}');
  //       }
  //       throw _handleErrorResponse(response);
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('ApiService: Error during user logout: $e');
  //     }
  //     throw ApiException('فشل تسجيل الخروج: ${e.toString()}');
  //   } finally {
  //     // 🚀🚀🚀 ثالثاً: مسح بيانات المصادقة المحلية دائماً 🚀🚀🚀
  //     await _clearAllAuthData();
  //   }
  // }
Future<Map<String, dynamic>?> logoutUser() async {
  if (kDebugMode) {
    debugPrint('ApiService: Attempting user logout...');
  }
  String? fcmToken;
  String? authToken;
  String deviceId;
  try {
    // 1. جلب FCM Token + معلومات الجهاز
    fcmToken = await FirebaseMessaging.instance.getToken();
    authToken = await getToken();
    final Map<String, String> deviceInfo = await _getDeviceInfo();
    deviceId = deviceInfo['id']!;

    if (kDebugMode) {
      debugPrint(
          'ApiService: User Logout - FCM Token: $fcmToken, Device ID: $deviceId, Auth Token: $authToken');
    }

    // 2. حذف FCM Token من الباكند
    if (fcmToken != null && authToken != null) {
      await deleteFcmTokenFromBackend(fcmToken, deviceId, authToken);
    } else {
      if (kDebugMode) {
        debugPrint(
            'ApiService: FCM Token or Auth Token missing, skipping FCM deletion attempt.');
      }
    }

    // 3. إرسال طلب تسجيل الخروج
    final response = await http.post(
      Uri.parse('$_baseUrl/logout'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        debugPrint('ApiService: User logout successful from backend.');
      }
      return {'status': true, 'message': ErrorMessages.logoutSuccess};
    } else {
      if (kDebugMode) {
        debugPrint(
            'ApiService: User logout failed with status: ${response.statusCode}');
      }
      throw _handleErrorResponse(response);
    }
  } on SocketException {
    throw ApiException(ErrorMessages.noInternetConnection);
  } on ApiException {
    rethrow; // الرسالة مضبوطة مسبقًا
  } catch (e) {
    if (kDebugMode) {
      debugPrint('ApiService: Unexpected error during user logout: $e');
    }
    throw ApiException('${ErrorMessages.logoutFailed}$e');
  } finally {
    // 4. مسح بيانات المصادقة دائمًا
    await _clearAllAuthData();
  }
}

  Future<Map<String, dynamic>?> getUserDashboardStats() async {
    final token = await getToken();
    if (token == null) {
      throw ApiException('غير مصرح به', statusCode: 401);
    }

    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/users/dashboard'), // مسار جلب إحصائيات لوحة تحكم المستخدم العادي
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw ApiException('تنسيق استجابة غير متوقع لإحصائيات لوحة التحكم.',
            statusCode: response.statusCode);
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      if (e is SocketException) {
        throw ApiException('لا يوجد اتصال بالإنترنت.');
      } else if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException(
            'حدث خطأ غير متوقع أثناء جلب إحصائيات لوحة التحكم للمستخدم: $e');
      }
    }
  }

  // Future<Conversation> createSupportConversation() async {
  //   try {
  //     final String? token = await getToken();
  //     if (token == null) {
  //       throw ApiException('Authentication token missing.');
  //     }

  //     final Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     };

  //     if (kDebugMode) {
  //       debugPrint('ApiService: Attempting to create support conversation.');
  //     }

  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/chat/conversations/support'), // New API endpoint
  //       headers: headers,
  //       body:
  //           jsonEncode({}), // No specific recipient needed, backend handles it
  //     );

  //     if (kDebugMode) {
  //       debugPrint(
  //           'ApiService: createSupportConversation response status: ${response.statusCode}');
  //       debugPrint(
  //           'ApiService: createSupportConversation response body: ${response.body}');
  //     }

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final Map<String, dynamic> responseData = jsonDecode(response.body);
  //       if (responseData['status'] == true &&
  //           responseData.containsKey('data')) {
  //         if (kDebugMode) {
  //           debugPrint(
  //               'ApiService: Support conversation created/found successfully.');
  //         }
  //         return Conversation.fromJson(responseData['data']);
  //       } else {
  //         throw ApiException(
  //             responseData['message'] ??
  //                 'Failed to create support conversation.',
  //             statusCode: response.statusCode);
  //       }
  //     } else {
  //       throw _handleErrorResponse(response);
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('ApiService: Error in createSupportConversation: $e');
  //     }
  //     rethrow;
  //   }
  // }
Future<Conversation> createSupportConversation() async {
  try {
    final String? token = await getToken();
    if (token == null) {
      throw ApiException(ErrorMessages.unauthorized, statusCode: 401);
    }

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    if (kDebugMode) {
      debugPrint('ApiService: Attempting to create support conversation.');
    }

    final response = await http
        .post(
          Uri.parse('$_baseUrl/chat/conversations/support'),
          headers: headers,
          body: jsonEncode({}),
        )
        .timeout(const Duration(seconds: 15)); // ⏳ إضافة Timeout

    if (kDebugMode) {
      debugPrint(
          'ApiService: createSupportConversation response status: ${response.statusCode}');
      debugPrint(
          'ApiService: createSupportConversation response body: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['status'] == true &&
          responseData.containsKey('data')) {
        if (kDebugMode) {
          debugPrint(
              'ApiService: Support conversation created/found successfully.');
        }
        return Conversation.fromJson(responseData['data']);
      } else {
        throw ApiException(
          responseData['message'] ?? ErrorMessages.unexpectedResponseFormat,
          statusCode: response.statusCode,
        );
      }
    } else {
      throw _handleErrorResponse(response);
    }
  } on SocketException {
    throw ApiException(ErrorMessages.noInternetConnection);
  } on TimeoutException {
    throw ApiException(ErrorMessages.requestTimeout);
  } on ApiException {
    rethrow; // نعيد رميها زي ما هي
  } catch (e) {
    throw ApiException('${ErrorMessages.unexpectedError}: $e');
  }
}

  // Future<List<dynamic>?> getMyChildren() async {
  //   final token = await getToken();
  //   if (token == null) {
  //     throw ApiException('غير مصرح به', statusCode: 401);
  //   }

  //   try {
  //     final response = await http.get(
  //       Uri.parse('$_baseUrl/specialist/children'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       if (data is List) {
  //         return data;
  //       } else if (data is Map<String, dynamic> &&
  //           data.containsKey('children')) {
  //         return data['children'] as List<dynamic>;
  //       }
  //       throw ApiException('تنسيق استجابة غير متوقع.',
  //           statusCode: response.statusCode);
  //     } else {
  //       throw _handleErrorResponse(response);
  //     }
  //   } catch (e) {
  //     if (e is SocketException) {
  //       throw ApiException('لا يوجد اتصال بالإنترنت.');
  //     } else if (e is ApiException) {
  //       rethrow;
  //     } else {
  //       throw ApiException('حدث خطأ غير متوقع: $e');
  //     }
  //   }
  // }
Future<List<dynamic>?> getMyChildren() async {
  final token = await getToken();
  if (token == null) {
    throw ApiException(ErrorMessages.unauthorized, statusCode: 401);
  }

  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/specialist/children'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data;
      } else if (data is Map<String, dynamic> && data.containsKey('children')) {
        return data['children'] as List<dynamic>;
      }
      throw ApiException(ErrorMessages.unexpectedResponseFormatGetMyChildren,
          statusCode: response.statusCode);
    } else {
      throw _handleErrorResponse(response);
    }
  } catch (e) {
    if (e is SocketException) {
      throw ApiException(ErrorMessages.noInternetConnection);
    } else if (e is ApiException) {
      rethrow;
    } else {
      throw ApiException(ErrorMessages.unexpectedError + e.toString());
    }
  }
}

  // Future<List<ReportFamily>> getFamilyReports() async {
  //   final token = await getToken();
  //   if (token == null) {
  //     throw ApiException('Unauthenticated.', statusCode: 401);
  //   }
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$_baseUrl/reports/family'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       if (data is Map<String, dynamic> && data.containsKey('data')) {
  //         final List<dynamic> reportsJson = data['data'] as List<dynamic>;
  //         final List<ReportFamily> reports = reportsJson
  //             .map(
  //                 (json) => ReportFamily.fromJson(json as Map<String, dynamic>))
  //             .toList();
  //         return reports;
  //       }
  //       throw ApiException('Unexpected response format.',
  //           statusCode: response.statusCode);
  //     } else {
  //       throw _handleErrorResponse(response);
  //     }
  //   } catch (e) {
  //     if (e is SocketException) {
  //       throw ApiException('No Internet connection.', statusCode: 503);
  //     } else if (e is ApiException) {
  //       rethrow;
  //     } else {
  //       throw ApiException('An unexpected error occurred: $e');
  //     }
  //   }
  // }
Future<List<ReportFamily>> getFamilyReports() async {
  final token = await getToken();
  if (token == null) {
    throw ApiException(ErrorMessages.unauthorized, statusCode: 401);
  }

  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/reports/family'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic> && data.containsKey('data')) {
        final List<dynamic> reportsJson = data['data'] as List<dynamic>;
        final List<ReportFamily> reports = reportsJson
            .map((json) => ReportFamily.fromJson(json as Map<String, dynamic>))
            .toList();
        return reports;
      }

      throw ApiException(
        ErrorMessages.unexpectedResponseFormatReportsAndNotes,
        statusCode: response.statusCode,
      );
    } else {
      throw _handleErrorResponse(response);
    }
  } catch (e) {
    if (e is SocketException) {
      throw ApiException(ErrorMessages.noInternetConnection, statusCode: 503);
    } else if (e is ApiException) {
      rethrow;
    } else {
      throw ApiException(ErrorMessages.unexpectedErrorGetReportFamilies + e.toString());
    }
  }
}
Future<int> fetchUnreadNotificationsCount(BuildContext context) async {
  final authToken = await getToken();
  if (authToken == null) {
    throw ApiException(ErrorMessages.unauthorized, statusCode: 401);
  }

  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/notifications/unread-count'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    debugPrint('حالة جلب عدد الإشعارات غير المقروءة: ${response.statusCode}');
    debugPrint('محتوى جلب عدد الإشعارات غير المقروءة: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data.containsKey('unread_count')) {
        return data['unread_count'] as int;
      } else {
        throw ApiException(
          ErrorMessages.unexpectedResponseFormat +
              ' (unread_count غير موجود)',
          statusCode: response.statusCode,
        );
      }
    } else {
      throw _handleErrorResponse(response);
    }
  } catch (e) {
    if (e is SocketException) {
      throw ApiException(ErrorMessages.noInternetConnection, statusCode: 503);
    } else if (e is ApiException) {
      rethrow;
    } else {
      throw ApiException(ErrorMessages.unexpectedError + e.toString());
    }
  }
}


  // Future<int> fetchUnreadNotificationsCount() async {
  //   final authToken = await getToken();
  //   if (authToken == null) {
  //     debugPrint(
  //         'ApiService: لا يوجد رمز مصادقة (Auth Token) لجلب عدد الإشعارات غير المقروءة.');
  //     return 0; // لا يوجد توكن، لذا لا يمكن جلب العدد
  //   }

  //   try {
  //     final response = await http.get(
  //       Uri.parse(
  //           '$_baseUrl/notifications/unread-count'), // يجب أن يتطابق مع مسار API في Laravel
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $authToken',
  //       },
  //     );

  //     debugPrint('حالة جلب عدد الإشعارات غير المقروءة: ${response.statusCode}');
  //     debugPrint('محتوى جلب عدد الإشعارات غير المقروءة: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = jsonDecode(response.body);
  //       // تأكد أن المفتاح 'unread_count' موجود وأن قيمته يمكن تحويلها إلى int
  //       if (data.containsKey('unread_count')) {
  //         return data['unread_count'] as int;
  //       } else {
  //         debugPrint(
  //             'ApiService: الاستجابة لا تحتوي على مفتاح "unread_count".');
  //         return 0;
  //       }
  //     } else {
  //       debugPrint(
  //           'ApiService: فشل في جلب عدد الإشعارات غير المقروءة: ${response.statusCode}');
  //       return 0; // فشل الطلب، ارجع 0
  //     }
  //   } catch (e) {
  //     debugPrint('ApiService: خطأ في جلب عدد الإشعارات غير المقروءة: $e');
  //     return 0; // خطأ في الاتصال، ارجع 0
  //   }
  // }

  // Future<Map<String, dynamic>?> getChildReportsAndNotes(String childId) async {
  //   print('--- بدأت دالة getChildReportsAndNotes ---');

  //   final token = await getToken();
  //   print(
  //       'Flutter Debug: الرمز المميز الذي تم استرداده: ${token != null ? "موجود (${token.length} حرف)" : "مفقود (null)"}');

  //   if (token == null) {
  //     print('Flutter Error: الرمز المميز مفقود. لا يمكن المتابعة.');
  //     throw ApiException('غير مصرح به', statusCode: 401);
  //   }

  //   final url = Uri.parse('$_baseUrl/child/$childId/reports-notes');
  //   print('Flutter Debug: المسار الكامل للطلب: $url');

  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     print(
  //         'Flutter Debug: حالة استجابة الخادم (Status Code): ${response.statusCode}');
  //     print(
  //         'Flutter Debug: نص استجابة الخادم (Response Body): ${response.body}');

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       if (data is Map<String, dynamic> && data.containsKey('child_data')) {
  //         print('Flutter Debug: تم جلب بيانات الطفل والتقارير بنجاح.');
  //         return data['child_data'];
  //       } else {
  //         print('Flutter Error: تنسيق استجابة غير متوقع من الخادم.');
  //         throw ApiException('تنسيق استجابة غير متوقع.',
  //             statusCode: response.statusCode);
  //       }
  //     } else {
  //       print('Flutter Error: فشل الطلب بحالة: ${response.statusCode}');
  //       throw _handleErrorResponse(response);
  //     }
  //   } catch (e) {
  //     if (e is SocketException) {
  //       print('Flutter Network Error: لا يوجد اتصال بالإنترنت: $e');
  //       throw ApiException('لا يوجد اتصال بالإنترنت.');
  //     } else if (e is ApiException) {
  //       print(
  //           'Flutter API Error: حدث خطأ في API: ${e.message} (الحالة: ${e.statusCode})');
  //       rethrow;
  //     } else {
  //       print('Flutter Generic Error: حدث خطأ غير متوقع: $e');
  //       throw ApiException('حدث خطأ غير متوقع: $e');
  //     }
  //   } finally {
  //     print('--- انتهت دالة getChildReportsAndNotes ---');
  //   }
  // }

  Future<Map<String, dynamic>?> getChildReportsAndNotes(String childId) async {
  print('--- بدأت دالة getChildReportsAndNotes ---');

  final token = await getToken();
  print(
      'Flutter Debug: الرمز المميز الذي تم استرداده: ${token != null ? "موجود (${token.length} حرف)" : "مفقود (null)"}');

  if (token == null) {
    print('Flutter Error: الرمز المميز مفقود. لا يمكن المتابعة.');
    throw ApiException(ErrorMessages.unauthorized, statusCode: 401);
  }

  final url = Uri.parse('$_baseUrl/child/$childId/reports-notes');
  print('Flutter Debug: المسار الكامل للطلب: $url');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Flutter Debug: حالة استجابة الخادم: ${response.statusCode}');
    print('Flutter Debug: نص استجابة الخادم: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic> && data.containsKey('child_data')) {
        print('Flutter Debug: تم جلب بيانات الطفل والتقارير بنجاح.');
        return data['child_data'];
      } else {
        print('Flutter Error: ${ErrorMessages.unexpectedResponseFormatReportsAndNotes}');
        throw ApiException(
          ErrorMessages.unexpectedResponseFormatReportsAndNotes,
          statusCode: response.statusCode,
        );
      }
    } else {
      print('Flutter Error: فشل الطلب بحالة: ${response.statusCode}');
      throw _handleErrorResponse(response);
    }
  } catch (e) {
    if (e is SocketException) {
      print('Flutter Network Error: ${ErrorMessages.noInternetConnection}');
      throw ApiException(ErrorMessages.noInternetConnection);
    } else if (e is ApiException) {
      print(
          'Flutter API Error: حدث خطأ في API: ${e.message} (الحالة: ${e.statusCode})');
      rethrow;
    } else {
      print('Flutter Generic Error: ${ErrorMessages.unexpectedErrorGetChildReportsAndNotes} $e');
      throw ApiException(ErrorMessages.unexpectedErrorGetChildReportsAndNotes + e.toString());
    }
  } finally {
    print('--- انتهت دالة getChildReportsAndNotes ---');
  }
}

Future<Map<String, dynamic>?> createReport(
  String childId,
  String title,
  String content,
  String status,
  List<File> files,
) async {
  final token = await getToken();
  if (token == null) {
    throw ApiException(ErrorMessages.unauthorized, statusCode: 401);
  }

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/reports'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['child_id'] = childId;
    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['status'] = status;

    for (var i = 0; i < files.length; i++) {
      request.files.add(await http.MultipartFile.fromPath(
        'files[]',
        files[i].path,
        filename: files[i].path.split('/').last,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw _handleErrorResponse(response);
    }
  } catch (e) {
    if (e is SocketException) {
      throw ApiException(ErrorMessages.noInternetConnection);
    } else if (e is ApiException) {
      rethrow;
    } else {
      throw ApiException(ErrorMessages.unexpectedErrorCreateReport + e.toString());
    }
  }
}

  // Future<Map<String, dynamic>?> createReport(String childId, String title,
  //     String content, String status, List<File> files) async {
  //   final token = await getToken();
  //   if (token == null) {
  //     throw ApiException('غير مصرح به', statusCode: 401);
  //   }

  //   try {
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('$_baseUrl/reports'),
  //     );

  //     request.headers['Authorization'] = 'Bearer $token';
  //     request.headers['Accept'] = 'application/json';

  //     request.fields['child_id'] = childId;
  //     request.fields['title'] = title;
  //     request.fields['content'] = content;
  //     request.fields['status'] = status;

  //     for (var i = 0; i < files.length; i++) {
  //       request.files.add(await http.MultipartFile.fromPath(
  //         'files[]',
  //         files[i].path,
  //         filename: files[i].path.split('/').last,
  //       ));
  //     }

  //     final streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(streamedResponse);

  //     if (response.statusCode >= 200 && response.statusCode < 300) {
  //       return jsonDecode(response.body);
  //     } else {
  //       throw _handleErrorResponse(response);
  //     }
  //   } catch (e) {
  //     if (e is SocketException) {
  //       throw ApiException('لا يوجد اتصال بالإنترنت.');
  //     } else if (e is ApiException) {
  //       rethrow;
  //     } else {
  //       throw ApiException('حدث خطأ غير متوقع: $e');
  //     }
  //   }
  // }

  // Future<Map<String, dynamic>?> getReportFamilyDetails(String reportId) async {
  //   final token = await getToken();
  //   if (token == null) {
  //     throw ApiException('غير مصرح به', statusCode: 401);
  //   }

  //   final url = Uri.parse('$_baseUrl/reports-family/$reportId');
  //   if (kDebugMode) {
  //     debugPrint('Fetching report details from: $url');
  //   }
  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (kDebugMode) {
  //       debugPrint('Report details response status: ${response.statusCode}');
  //       debugPrint('Report details response body: ${response.body}');
  //     }

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       if (data is Map<String, dynamic> && data.containsKey('data')) {
  //         return data['data'];
  //       }
  //       throw ApiException('تنسيق استجابة غير متوقع.',
  //           statusCode: response.statusCode);
  //     } else {
  //       throw _handleErrorResponse(response);
  //     }
  //   } catch (e) {
  //     if (e is SocketException) {
  //       throw ApiException('لا يوجد اتصال بالإنترنت.');
  //     } else if (e is ApiException) {
  //       rethrow;
  //     } else {
  //       throw ApiException('حدث خطأ غير متوقع أثناء جلب تفاصيل التقرير: $e');
  //     }
  //   }
  // }

Future<Map<String, dynamic>?> getReportFamilyDetails(String reportId) async {
  final token = await getToken();
  if (token == null) {
    throw ApiException(ErrorMessages.unauthorized, statusCode: 401);
  }

  final url = Uri.parse('$_baseUrl/reports-family/$reportId');
  if (kDebugMode) {
    debugPrint('Fetching report details from: $url');
  }

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (kDebugMode) {
      debugPrint('Report details response status: ${response.statusCode}');
      debugPrint('Report details response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        return data['data'];
      }
      throw ApiException(
        ErrorMessages.unexpectedResponseFormat,
        statusCode: response.statusCode,
      );
    } else {
      throw _handleErrorResponse(response);
    }
  } catch (e) {
    if (e is SocketException) {
      throw ApiException(ErrorMessages.noInternetConnection);
    } else if (e is ApiException) {
      rethrow;
    } else {
      throw ApiException(
        ErrorMessages.unexpectedErrorGetReportFamilies + e.toString(),
      );
    }
  }
}

  // Future<List<Course>> getCourses() async {
  //   final token = await getToken();
  //   if (token == null) {
  //     throw ApiException('غير مصرح به', statusCode: 401);
  //   }

  //   final url = Uri.parse('$_baseUrl/courses');
  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //     if (kDebugMode) {
  //       debugPrint('Courses response status: ${response.statusCode}');
  //       debugPrint('Courses response body: ${response.body}');
  //     }

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = json.decode(response.body);
  //       if (responseData['status'] == true && responseData['data'] is List) {
  //         List<dynamic> coursesJson = responseData['data'];
  //         return coursesJson
  //             .map((json) => Course.fromJson(json as Map<String, dynamic>))
  //             .toList();
  //       } else {
  //         if (kDebugMode) {
  //           debugPrint(
  //               'API returned an error or unexpected data format for courses: ${responseData['message']}');
  //         }
  //         throw ApiException(
  //             responseData['message'] ?? 'تنسيق استجابة غير متوقع للدورات.',
  //             statusCode: response.statusCode);
  //       }
  //     } else {
  //       if (kDebugMode) {
  //         debugPrint('Failed to load courses: ${response.statusCode}');
  //       }
  //       throw _handleErrorResponse(response);
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('Error fetching courses: $e');
  //     }
  //     if (e is SocketException) {
  //       throw ApiException('لا يوجد اتصال بالإنترنت أثناء جلب الدورات.');
  //     } else if (e is ApiException) {
  //       rethrow;
  //     } else {
  //       throw ApiException('حدث خطأ غير متوقع أثناء جلب الدورات: $e');
  //     }
  //   }
  // }

Future<List<Course>> getCourses() async {
  final token = await getToken();
  if (token == null) {
    throw ApiException(ErrorMessages.unauthorized, statusCode: 401);
  }

  final url = Uri.parse('$_baseUrl/courses');
  try {
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (kDebugMode) {
      debugPrint('Courses response status: ${response.statusCode}');
      debugPrint('Courses response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['status'] == true && responseData['data'] is List) {
        List<dynamic> coursesJson = responseData['data'];
        return coursesJson
            .map((json) => Course.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        if (kDebugMode) {
          debugPrint(
            'API returned an error or unexpected data format for courses: ${responseData['message']}',
          );
        }
        throw ApiException(
          responseData['message'] ??
              ErrorMessages.unexpectedResponseFormat + ' (الدورات)',
          statusCode: response.statusCode,
        );
      }
    } else {
      if (kDebugMode) {
        debugPrint('Failed to load courses: ${response.statusCode}');
      }
      throw _handleErrorResponse(response);
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Error fetching courses: $e');
    }
    if (e is SocketException) {
      throw ApiException(ErrorMessages.noInternetConnection);
    } else if (e is ApiException) {
      rethrow;
    } else {
      throw ApiException(
        ErrorMessages.unexpectedError + ' أثناء جلب الدورات: $e',
      );
    }
  }
}

Future<Map<String, dynamic>?> createNote(
    String childId, String title, String content) async {
  final token = await getToken();
  if (token == null) {
    throw ApiException(ErrorMessages.unauthorized, statusCode: 401);
  }

  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/specialist-notes'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'child_id': childId,
        'title': title,
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw _handleErrorResponse(response);
    }
  } catch (e) {
    if (e is SocketException) {
      throw ApiException(ErrorMessages.noInternetConnection);
    } else if (e is ApiException) {
      rethrow;
    } else {
      throw ApiException('${ErrorMessages.unexpectedError}: $e');
    }
  }
}

  // Future<Map<String, dynamic>?> createNote(
  //     String childId, String title, String content) async {
  //   final token = await getToken();
  //   if (token == null) {
  //     throw ApiException('غير مصرح به', statusCode: 401);
  //   }

  //   try {
  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/specialist-notes'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: jsonEncode({
  //         'child_id': childId,
  //         'title': title,
  //         'content': content,
  //       }),
  //     );

  //     if (response.statusCode == 201) {
  //       return jsonDecode(response.body);
  //     } else {
  //       throw _handleErrorResponse(response);
  //     }
  //   } catch (e) {
  //     if (e is SocketException) {
  //       throw ApiException('لا يوجد اتصال بالإنترنت.');
  //     } else if (e is ApiException) {
  //       rethrow;
  //     } else {
  //       throw ApiException('حدث خطأ غير متوقع: $e');
  //     }
  //   }
  // }

  // Future<List<dynamic>?> getReportFamilies() async {
  //   final token = await getToken();
  //   if (token == null) {
  //     throw ApiException('غير مصرح به', statusCode: 401);
  //   }

  //   try {
  //     final response = await http.get(
  //       Uri.parse('$_baseUrl/reports-family'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       if (data is Map<String, dynamic> &&
  //           data.containsKey('data') &&
  //           data['data'] is List) {
  //         return data['data'] as List<dynamic>;
  //       }
  //       throw ApiException('تنسيق استجابة غير متوقع.',
  //           statusCode: response.statusCode);
  //     } else {
  //       throw _handleErrorResponse(response);
  //     }
  //   } catch (e) {
  //     if (e is SocketException) {
  //       throw ApiException('لا يوجد اتصال بالإنترنت.');
  //     } else if (e is ApiException) {
  //       rethrow;
  //     } else {
  //       throw ApiException('حدث خطأ غير متوقع: $e');
  //     }
  //   }
  // }

Future<List<dynamic>?> getReportFamilies() async {
  final token = await getToken();
  if (token == null) {
    throw ApiException(ErrorMessages.unauthorized, statusCode: 401);
  }

  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/reports-family'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> &&
          data.containsKey('data') &&
          data['data'] is List) {
        return data['data'] as List<dynamic>;
      }
      throw ApiException(
        ErrorMessages.unexpectedResponseFormat,
        statusCode: response.statusCode,
      );
    } else {
      throw _handleErrorResponse(response);
    }
  } catch (e) {
    if (e is SocketException) {
      throw ApiException(ErrorMessages.noInternetConnection);
    } else if (e is ApiException) {
      rethrow;
    } else {
      throw ApiException('${ErrorMessages.unexpectedError}: $e');
    }
  }
}
Future<List<Specialist>> getSpecialistsData(BuildContext context) async {
  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/data/specialists'),
      headers: await _getAuthHeaders(),
    );

    final data = _handleResponse(response);

    if (data is List) {
      return data
          .map((json) => Specialist.fromJson(json as Map<String, dynamic>))
          .toList();
    } else if (data is Map &&
        data['specialists'] != null &&
        data['specialists'] is List) {
      return (data['specialists'] as List)
          .map((json) => Specialist.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    // لو التنسيق غير متوقع نرمي خطأ
    throw ApiException(ErrorMessages.failedToParseSpecialistData);

  } on SocketException {
    // خطأ انقطاع الإنترنت
    showErrorDialog(context, 'خطأ في الاتصال', ErrorMessages.noInternetConnection);
    return [];
  } on TimeoutException {
    // مهلة الطلب انتهت
    showErrorDialog(context, 'انتهت المهلة', ErrorMessages.requestTimeout);
    return [];
  } on ApiException catch (e) {
    // خطأ API
    showErrorDialog(context, 'خطأ في الخادم', e.message);
    return [];
  } catch (e) {
    // أي خطأ غير متوقع
    debugPrint('Error in getSpecialistsData: $e');
    showErrorDialog(context, 'خطأ غير متوقع', ErrorMessages.unexpectedError + e.toString());
    return [];
  }
}


  // Future<List<Specialist>> getSpecialistsData() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$_baseUrl/data/specialists'),
  //       headers: await _getAuthHeaders(),
  //     );

  //     final data = _handleResponse(response);

  //     if (data is List) {
  //       return data
  //           .map((json) => Specialist.fromJson(json as Map<String, dynamic>))
  //           .toList();
  //     } else if (data is Map &&
  //         data['specialists'] != null &&
  //         data['specialists'] is List) {
  //       return (data['specialists'] as List)
  //           .map((json) => Specialist.fromJson(json as Map<String, dynamic>))
  //           .toList();
  //     }
  //     throw ApiException(
  //         'Failed to parse specialists data: Expected a list or map with "specialists" key.');
  //   } catch (e) {
  //     debugPrint('Error in getSpecialistsData: $e');
  //     rethrow;
  //   }
  // }

  // Future<Map<String, dynamic>> getReportDetailsData(int reportId) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$_baseUrl/data/reports/$reportId'),
  //       headers: await _getAuthHeaders(),
  //     );

  //     final data = _handleResponse(response);
  //     if (data['report'] != null) {
  //       return data['report'] as Map<String, dynamic>;
  //     }
  //     throw ApiException(
  //         'Failed to parse report details: Missing "report" key.');
  //   } catch (e) {
  //     debugPrint('Error in getReportDetailsData for ID $reportId: $e');
  //     rethrow;
  //   }
  // }

Future<Map<String, dynamic>> getReportDetailsData(
    BuildContext context, int reportId) async {
  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/data/reports/$reportId'),
      headers: await _getAuthHeaders(),
    );

    final data = _handleResponse(response);

    if (data['report'] != null) {
      return data['report'] as Map<String, dynamic>;
    }

    // لو المفتاح "report" مش موجود
    throw ApiException(ErrorMessages.unexpectedResponseFormatChildData);

  } on SocketException {
    // خطأ انقطاع الإنترنت
    showErrorDialog(context, 'خطأ في الاتصال', ErrorMessages.noInternetConnection);
    return {};
  } on TimeoutException {
    // خطأ مهلة
    showErrorDialog(context, 'انتهت المهلة', ErrorMessages.requestTimeout);
    return {};
  } on ApiException catch (e) {
    // خطأ API
    showErrorDialog(context, 'خطأ في الخادم', e.message);
    return {};
  } catch (e) {
    // أي خطأ غير متوقع
    debugPrint('Error in getReportDetailsData for ID $reportId: $e');
    showErrorDialog(context, 'خطأ غير متوقع',
        ErrorMessages.unexpectedError + e.toString());
    return {};
  }
}
Future<Department> getDepartmentDetailsData(
    BuildContext context, String departmentId) async {
  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/data/departments/$departmentId/details'),
      headers: await _getAuthHeaders(),
    );

    final dynamic data = _handleResponse(response); // قد تكون Map أو null

    if (data != null && data is Map && data.containsKey('department')) {
      // تحويل البيانات إلى Department
      return Department.fromJson(data['department'] as Map<String, dynamic>);
    } else {
      // لا توجد بيانات صالحة
      showErrorDialog(
        context,
        'بيانات غير متوفرة',
        ErrorMessages.unexpectedResponseFormatChildData,
      );

      return Department(
        id: departmentId,
        name: 'قسم غير متاح',
        branchId: 'N/A',
        departmentNumber: 'N/A',
        specialists: [],
        description: 'لا توجد تفاصيل لهذا القسم حاليًا.',
      );
    }
  } on SocketException {
    showErrorDialog(context, 'خطأ في الاتصال', ErrorMessages.noInternetConnection);
    return Department(
      id: departmentId,
      name: 'مشكلة اتصال',
      branchId: 'N/A',
      departmentNumber: 'N/A',
      specialists: [],
      description: 'لا يوجد اتصال بالإنترنت.',
    );
  } on TimeoutException {
    showErrorDialog(context, 'انتهت المهلة', ErrorMessages.requestTimeout);
    return Department(
      id: departmentId,
      name: 'انتهت المهلة',
      branchId: 'N/A',
      departmentNumber: 'N/A',
      specialists: [],
      description: 'انتهت مهلة الطلب، حاول مرة أخرى.',
    );
  } catch (e) {
    debugPrint(
        'ApiService: getDepartmentDetailsData - Unexpected error for ID $departmentId: $e');

    showErrorDialog(
      context,
      'خطأ غير متوقع',
      ErrorMessages.unexpectedError + e.toString(),
    );

    return Department(
      id: departmentId,
      name: 'خطأ',
      branchId: 'N/A',
      departmentNumber: 'N/A',
      specialists: [],
      description: 'حدث خطأ أثناء محاولة جلب تفاصيل القسم.',
    );
  }
}

  // Future<Department> getDepartmentDetailsData(String departmentId) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$_baseUrl/data/departments/$departmentId/details'),
  //       headers: await _getAuthHeaders(),
  //     );
  //     final dynamic data = _handleResponse(response); // قد تكون Map أو null

  //     if (data != null && data.containsKey('department')) {
  //       // إذا كانت البيانات صالحة، قم بالتحويل إلى Department
  //       return Department.fromJson(data as Map<String, dynamic>);
  //     } else {
  //       debugPrint(
  //           'ApiService: getDepartmentDetailsData - No valid department data found for ID: $departmentId');
  //       // في حالة عدم وجود بيانات صالحة، يمكنك إرجاع Department افتراضي أو إلقاء خطأ
  //       // بما أنك لا تريد رمي استثناءات، سأعيد Department بقيم افتراضية
  //       return Department(
  //         id: departmentId,
  //         name: 'قسم غير متاح',
  //         branchId: 'N/A',
  //         departmentNumber: 'N/A',
  //         specialists: [],
  //         description: 'لا توجد تفاصيل لهذا القسم حاليًا.',
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint(
  //         'ApiService: getDepartmentDetailsData - An unexpected error occurred for ID $departmentId: $e');
  //     // عند حدوث أي خطأ، ارجع Department بقيم افتراضية
  //     return Department(
  //       id: departmentId,
  //       name: 'خطأ في جلب القسم',
  //       branchId: 'N/A',
  //       departmentNumber: 'N/A',
  //       specialists: [],
  //       description: 'حدث خطأ أثناء محاولة جلب تفاصيل القسم.',
  //     );
  //   }
  // }

  Future<Map<String, dynamic>> getSpecialistChildrenData(
      String specialistId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/data/specialists/$specialistId/children'),
        headers: await _getAuthHeaders(),
      );

      final data = _handleResponse(response);

      // تحليل قائمة الأبناء إلى Child models
      final List<dynamic> associatedChildrenJson =
          data['associated_children'] ?? [];
      final List<Child> children = associatedChildrenJson
          .map((jsonItem) => Child.fromJson(jsonItem as Map<String, dynamic>))
          .toList();

      return {
        'specialist': Specialist.fromJson(data['specialist']
            as Map<String, dynamic>), // الأخصائي كـ Specialist model
        'children': children, // الأبناء كـ List<Child>
      };
    } catch (e) {
      debugPrint('Error in getSpecialistChildrenData: $e');
      rethrow;
    }
  }

  Future<Specialist?> fetchSpecialistById(String specialistId) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/specialists/$specialistId'));

      if (response.statusCode == 200) {
        // إذا نجح الطلب، قم بتحليل JSON
        return Specialist.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        // إذا كان الأخصائي غير موجود (404 Not Found)، أعد null
        print('Specialist with ID $specialistId not found. Status: 404');
        return null;
      } else {
        // للتعامل مع أي أخطاء أخرى
        print('Failed to load specialist. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // التعامل مع أخطاء الاتصال بالإنترنت أو أي استثناءات أخرى
      print('Error fetching specialist: $e');
      return null;
    }
  }

  // Future<List<dynamic>> getDepartmentsData() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$_baseUrl/data/departments'),
  //       headers: await _getAuthHeaders(),
  //     );

  //     final data = _handleResponse(response);
  //     if (data['departments'] != null) {
  //       return data['departments'] as List<dynamic>;
  //     }
  //     throw ApiException(
  //         'Failed to parse departments data: Missing "departments" key.');
  //   } catch (e) {
  //     debugPrint('Error in getDepartmentsData: $e');
  //     rethrow;
  //   }
  // }
Future<List<dynamic>> getDepartmentsData(BuildContext context) async {
  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/data/departments'),
      headers: await _getAuthHeaders(),
    );

    final data = _handleResponse(response);

    if (data['departments'] != null) {
      return data['departments'] as List<dynamic>;
    }

    // لو المفتاح مفقود
    throw ApiException(ErrorMessages.unexpectedResponseFormatGetMyChildren);

  } on SocketException {
    showErrorDialog(context, 'خطأ في الاتصال', ErrorMessages.noInternetConnection);
    return [];
  } on TimeoutException {
    showErrorDialog(context, 'انتهت المهلة', ErrorMessages.requestTimeout);
    return [];
  } on ApiException catch (e) {
    showErrorDialog(context, 'خطأ في الخادم', e.message);
    return [];
  } catch (e) {
    debugPrint('Error in getDepartmentsData: $e');
    showErrorDialog(context, 'خطأ غير متوقع', ErrorMessages.unexpectedError + e.toString());
    return [];
  }
}
Future<Map<String, dynamic>> getDepartmentCreationData(BuildContext context) async {
  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/data/departments/creation-options'),
      headers: await _getAuthHeaders(),
    );

    final data = _handleResponse(response);

    if (data['departments'] != null &&
        data['specialists'] != null &&
        data['children'] != null) {
      return {
        'departments': data['departments'] as List<dynamic>,
        'specialists': data['specialists'] as List<dynamic>,
        'children': data['children'] as List<dynamic>,
      };
    }

    // لو المفاتيح المطلوبة ناقصة
    throw ApiException(ErrorMessages.unexpectedResponseFormat);

  } on SocketException {
    showErrorDialog(context, 'خطأ في الاتصال', ErrorMessages.noInternetConnection);
    return {
      'departments': [],
      'specialists': [],
      'children': [],
    };
  } on TimeoutException {
    showErrorDialog(context, 'انتهت المهلة', ErrorMessages.requestTimeout);
    return {
      'departments': [],
      'specialists': [],
      'children': [],
    };
  } on ApiException catch (e) {
    showErrorDialog(context, 'خطأ في الخادم', e.message);
    return {
      'departments': [],
      'specialists': [],
      'children': [],
    };
  } catch (e) {
    debugPrint('Error in getDepartmentCreationData: $e');
    showErrorDialog(
      context,
      'خطأ غير متوقع',
      ErrorMessages.unexpectedError + e.toString(),
    );
    return {
      'departments': [],
      'specialists': [],
      'children': [],
    };
  }
}

  // Future<Map<String, dynamic>> getDepartmentCreationData() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$_baseUrl/data/departments/creation-options'),
  //       headers: await _getAuthHeaders(),
  //     );

  //     final data = _handleResponse(response);
  //     if (data['departments'] != null &&
  //         data['specialists'] != null &&
  //         data['children'] != null) {
  //       return {
  //         'departments': data['departments'] as List<dynamic>,
  //         'specialists': data['specialists'] as List<dynamic>,
  //         'children': data['children'] as List<dynamic>,
  //       };
  //     }
  //     throw ApiException(
  //         'Failed to parse department creation data: Missing required keys.');
  //   } catch (e) {
  //     debugPrint('Error in getDepartmentCreationData: $e');
  //     rethrow;
  //   }
  // }

  // Future<List<dynamic>> getSpecialistsByDepartmentIdData(
  //     int departmentId) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse(
  //           '$_baseUrl/data/departments/specialists-by-department?department_id=$departmentId'),
  //       headers: await _getAuthHeaders(),
  //     );

  //     final data = _handleResponse(response);
  //     if (data is List) {
  //       return data; // هذا يعيد القائمة مباشرة
  //     }
  //     throw ApiException(
  //         'Failed to parse specialists by department data: Expected a list.');
  //   } catch (e) {
  //     debugPrint(
  //         'Error in getSpecialistsByDepartmentIdData for ID $departmentId: $e');
  //     rethrow;
  //   }
  // }
Future<List<dynamic>> getSpecialistsByDepartmentIdData(
    BuildContext context, int departmentId) async {
  try {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/data/departments/specialists-by-department?department_id=$departmentId'),
      headers: await _getAuthHeaders(),
    );

    final data = _handleResponse(response);

    if (data is List) {
      return data; // يرجع القائمة مباشرة
    }

    // لو مش قائمة → خطأ في التنسيق
    throw ApiException(ErrorMessages.failedToParseSpecialistData);

  } on SocketException {
    showErrorDialog(context, 'خطأ في الاتصال', ErrorMessages.noInternetConnection);
    return [];
  } on TimeoutException {
    showErrorDialog(context, 'انتهت المهلة', ErrorMessages.requestTimeout);
    return [];
  } on ApiException catch (e) {
    showErrorDialog(context, 'خطأ في الخادم', e.message);
    return [];
  } catch (e) {
    debugPrint(
        'Error in getSpecialistsByDepartmentIdData for ID $departmentId: $e');
    showErrorDialog(
      context,
      'خطأ غير متوقع',
      ErrorMessages.unexpectedError + e.toString(),
    );
    return [];
  }
}
Future<Map<String, dynamic>?> createReportFamily(
  BuildContext context,
  String title,
  String category,
  String description,
  List<File> files,
) async {
  final token = await getToken();
  if (token == null) {
    showErrorDialog(context, 'غير مصرح', ErrorMessages.unauthorized);
    return null;
  }

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/reports-family'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['title'] = title;
    request.fields['category'] = category;
    request.fields['description'] = description;

    for (var i = 0; i < files.length; i++) {
      request.files.add(await http.MultipartFile.fromPath(
        'files[]',
        files[i].path,
        filename: files[i].path.split('/').last,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      // لو رجع السيرفر بخطأ
      final apiError = _handleErrorResponse(response);
      showErrorDialog(context, 'خطأ في الخادم', apiError.message);
      return null;
    }
  } on SocketException {
    showErrorDialog(context, 'خطأ في الاتصال', ErrorMessages.noInternetConnection);
    return null;
  } on TimeoutException {
    showErrorDialog(context, 'انتهت المهلة', ErrorMessages.requestTimeout);
    return null;
  } catch (e) {
    debugPrint('Error in createReportFamily: $e');
    showErrorDialog(context, 'خطأ غير متوقع', ErrorMessages.unexpectedError + e.toString());
    return null;
  }
}

  // Future<Map<String, dynamic>?> createReportFamily(String title,
  //     String category, String description, List<File> files) async {
  //   final token = await getToken();
  //   if (token == null) {
  //     throw ApiException('غير مصرح به', statusCode: 401);
  //   }

  //   try {
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('$_baseUrl/reports-family'),
  //     );

  //     request.headers['Authorization'] = 'Bearer $token';
  //     request.headers['Accept'] = 'application/json';

  //     request.fields['title'] = title;
  //     request.fields['category'] = category;
  //     request.fields['description'] = description;

  //     for (var i = 0; i < files.length; i++) {
  //       request.files.add(await http.MultipartFile.fromPath(
  //         'files[]',
  //         files[i].path,
  //         filename: files[i].path.split('/').last,
  //       ));
  //     }

  //     final streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(streamedResponse);

  //     if (response.statusCode >= 200 && response.statusCode < 300) {
  //       return jsonDecode(response.body);
  //     } else {
  //       throw _handleErrorResponse(response);
  //     }
  //   } catch (e) {
  //     if (e is SocketException) {
  //       throw ApiException('لا يوجد اتصال بالإنترنت.');
  //     } else if (e is ApiException) {
  //       rethrow;
  //     } else {
  //       throw ApiException('حدث خطأ غير متوقع: $e');
  //     }
  //   }
  // }

  // Future<Specialist?> getSpecialistProfile() async {
  //   if (kDebugMode) {
  //     debugPrint('ApiService: Attempting to fetch specialist profile.');
  //   }
  //   try {
  //     final headers = await _getAuthHeaders();
  //     final response = await http.get(
  //       Uri.parse('$_baseUrl/specialist/profile'),
  //       headers: headers,
  //     );

  //     if (kDebugMode) {
  //       debugPrint(
  //           'ApiService: Specialist profile response status code: ${response.statusCode}');
  //       debugPrint(
  //           'ApiService: Specialist profile response body: ${response.body}');
  //     }

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = jsonDecode(response.body);
  //       if (kDebugMode) {
  //         debugPrint(
  //             'ApiService: Specialist profile data decoded successfully.');
  //       }
  //       // Assuming your Laravel API returns the specialist data directly at the root
  //       // If it's nested (e.g., {'specialist': {...}}), adjust this.
  //       return Specialist.fromJson(
  //           responseData); // Assuming Specialist.fromJson exists
  //     } else {
  //       if (kDebugMode) {
  //         debugPrint(
  //             'ApiService: Failed to fetch specialist profile with non-200 status code. Handling error response.');
  //       }
  //       throw _handleErrorResponse(response);
  //     }
  //   } catch (e) {
  //     if (e is SocketException) {
  //       if (kDebugMode) {
  //         debugPrint(
  //             'ApiService: Network error during fetching specialist profile: $e');
  //       }
  //       throw ApiException('لا يوجد اتصال بالإنترنت.');
  //     } else if (e is ApiException) {
  //       if (kDebugMode) {
  //         debugPrint(
  //             'ApiService: API exception during fetching specialist profile: ${e.message}, Status: ${e.statusCode}');
  //       }
  //       rethrow;
  //     } else {
  //       if (kDebugMode) {
  //         debugPrint(
  //             'ApiService: Unexpected error during fetching specialist profile: $e');
  //       }
  //       throw ApiException(
  //           'حدث خطأ غير متوقع أثناء جلب الملف الشخصي للأخصائي: $e');
  //     }
  //   }
  // }

Future<Specialist?> getSpecialistProfile() async {
  if (kDebugMode) {
    debugPrint('ApiService: Attempting to fetch specialist profile.');
  }

  try {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/specialist/profile'),
      headers: headers,
    );

    if (kDebugMode) {
      debugPrint('ApiService: Specialist profile response code: ${response.statusCode}');
      debugPrint('ApiService: Specialist profile body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final specialistData = responseData['specialist'] ?? responseData;

      return Specialist.fromJson(specialistData);
    } else if (response.statusCode == 401) {
      throw ApiException('انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مجددًا', statusCode: 401);
    } else {
      throw _handleErrorResponse(response);
    }
  } catch (e) {
    if (e is SocketException) {
      throw ApiException('لا يوجد اتصال بالإنترنت.');
    } else if (e is ApiException) {
      rethrow;
    } else {
      throw ApiException('حدث خطأ غير متوقع أثناء جلب الملف الشخصي للأخصائي: $e');
    }
  }
}

  Future<String?> getCurrentUserName() async {
    try {
      final type = await getUserType();

      if (type == 'specialist') {
        final specialist = await getSpecialistProfile();
        return specialist?.name;
      } else {
        final response = await getUserDashboardStats();
        final data = response?['data'] as Map<String, dynamic>?;
        return data?['user_name'];
      }
    } catch (e) {
      debugPrint('Error in getCurrentUserName: $e');
      return null;
    }
  }

  Future<String?> getSpecialistName() async {
    final profile = await getSpecialistProfile();
    return profile?.name; // يفترض أن `name` موجود داخل model Specialist
  }

  Future<String?> getUserName() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/user/profile'), // تأكد من وجود هذا المسار في Laravel
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('name')) {
          return data['name'];
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Specialist?> updateSpecialistProfile(Map<String, dynamic> data) async {
    if (kDebugMode) {
      debugPrint(
          'ApiService: Attempting to update specialist profile with data: $data');
    }
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        // Using POST as per your Laravel route suggestion
        Uri.parse('$_baseUrl/specialist/profile'),
        headers: headers,
        body: jsonEncode(data),
      );

      if (kDebugMode) {
        debugPrint(
            'ApiService: Specialist profile update response status code: ${response.statusCode}');
        debugPrint(
            'ApiService: Specialist profile update response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (kDebugMode) {
          debugPrint(
              'ApiService: Specialist profile update successful. Response data: $responseData');
        }
        // Assuming your Laravel API returns the updated specialist data under a 'specialist' key
        if (responseData.containsKey('specialist')) {
          return Specialist.fromJson(responseData['specialist']);
        } else {
          // If the API doesn't return the specialist object directly,
          // you might need to re-fetch it or return a success message.
          // For now, throwing an error if the 'specialist' key is missing.
          throw ApiException(
              'تنسيق استجابة غير متوقع بعد تحديث الملف الشخصي. المفتاح "specialist" مفقود.',
              statusCode: response.statusCode);
        }
      } else {
        if (kDebugMode) {
          debugPrint(
              'ApiService: Failed to update specialist profile with non-200 status code. Handling error response.');
        }
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      if (e is SocketException) {
        if (kDebugMode) {
          debugPrint(
              'ApiService: Network error during updating specialist profile: $e');
        }
        throw ApiException('لا يوجد اتصال بالإنترنت.');
      } else if (e is ApiException) {
        if (kDebugMode) {
          debugPrint(
              'ApiService: API exception during updating specialist profile: ${e.message}, Status: ${e.statusCode}');
        }
        rethrow;
      } else {
        if (kDebugMode) {
          debugPrint(
              'ApiService: Unexpected error during updating specialist profile: $e');
        }
        throw ApiException(
            'حدث خطأ غير متوقع أثناء تحديث الملف الشخصي للأخصائي: $e');
      }
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await getToken();
    if (token == null) {
      throw ApiException('Authentication token is missing.', statusCode: 401);
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Conversation>> getUserConversations({String? type}) async {
    try {
      final String? token = await getToken();
      if (token == null) {
        throw ApiException('Authentication token missing.');
      }

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      Uri uri = Uri.parse('$_baseUrl/chat/conversations');
      if (type != null) {
        uri = uri.replace(queryParameters: {'type': type});
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == true &&
            responseData.containsKey('data')) {
          final List<dynamic> conversationsJson = responseData['data'];
          return conversationsJson
              .map((json) => Conversation.fromJson(json))
              .toList();
        } else {
          throw ApiException(
              responseData['message'] ?? 'Failed to fetch conversations.',
              statusCode: response.statusCode);
        }
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ApiService: Error in getUserConversations: $e');
      }
      rethrow;
    }
  }

  Future<List<Message>> getConversationMessages(int conversationId,
      {int page = 1, int limit = 20}) async {
    try {
      // 🚀 تأكد من بناء الـ URL بشكل صحيح مع الـ pagination
      final url = Uri.parse(
          '$_baseUrl/chat/conversations/$conversationId/messages?page=$page&limit=$limit');

      final response = await http.get(url, headers: await _getAuthHeaders());

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['status'] == true) {
          // 🚀 المسار هنا يعتمد على بنية الـ JSON اللي بترجعها من الباك إند.
          // بناءً على الكود اللي فات من Laravel، أنت بترجع 'data' على طول،
          // وداخلها هتلاقي قائمة الـ formattedMessages اللي كانت اسمها 'data' في الـ Laravel response.
          // الـ Pagination هتكون في 'data' الأساسية مش داخلها 'messages'.
          // لذا، المسار الأرجح هو responseData['data'] مباشرةً لو كانت بترجع الـ List بتاعة الرسائل

          // مثال بناءً على آخر استجابة Laravel (data['data'] هي الـ formattedMessages)
          // لكن لو الـ pagination كانت على الرسائل مباشرة (responseData['data']['data'])
          // هنا محتاجين نكون دقيقين جداً في المسار الصحيح
          List<dynamic> messagesJson;
          if (responseData['data'] is List) {
            // لو الـ 'data' مباشرة هي قائمة الرسائل
            messagesJson = responseData['data'];
          } else if (responseData['data'] is Map &&
              responseData['data'].containsKey('data')) {
            // لو الـ pagination موجودة
            messagesJson = responseData['data'][
                'data']; // ده المسار لو بتستخدم pagination في Laravel وبترجع 'data' داخل الـ 'data' الرئيسية
          } else {
            throw ApiException(
                'فشل تحليل بيانات الرسائل من الخادم. بنية غير متوقعة.',
                statusCode: response.statusCode);
          }

          List<Message> messages = messagesJson
              .map((json) => Message.fromJson(json as Map<String, dynamic>))
              .toList();
          return messages;
        } else {
          throw ApiException(responseData['message'] ?? 'فشل تحميل الرسائل',
              statusCode: response.statusCode);
        }
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      if (e is SocketException) {
        throw ApiException('لا يوجد اتصال بالإنترنت أثناء جلب الرسائل.');
      } else if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException('حدث خطأ غير متوقع أثناء جلب الرسائل: $e');
      }
    }
  }

  Future<Message> sendMessage({
    required int conversationId,
    required String content,
    String? messageType = 'text', // Default to 'text', but allows other types
    List<String>? attachmentUrls, // Optional list of URLs for attachments
  }) async {
    try {
      final url =
          Uri.parse('$_baseUrl/chat/conversations/$conversationId/messages');
      final Map<String, dynamic> requestBody = {
        'content': content,
        'message_type': messageType,
        if (attachmentUrls != null && attachmentUrls.isNotEmpty)
          'attachments': attachmentUrls,
      };

      final response = await http.post(
        url,
        headers: await _getAuthHeaders(),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == true &&
            responseData.containsKey('data')) {
          return Message.fromJson(responseData['data']);
        } else {
          throw ApiException(
              responseData['message'] ??
                  'Failed to parse message from response',
              statusCode: response.statusCode);
        }
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      if (e is SocketException) {
        throw ApiException('لا يوجد اتصال بالإنترنت أثناء إرسال الرسالة.');
      } else if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException('حدث خطأ غير متوقع أثناء إرسال الرسالة: $e');
      }
    }
  }

  Future<void> markConversationAsRead(int conversationId) async {
    try {
      final url = Uri.parse(
          '$_baseUrl/chat/conversations/$conversationId/mark-as-read');
      final response = await http.post(url, headers: await _getAuthHeaders());

      if (response.statusCode != 200) {
        throw _handleErrorResponse(response);
      }
      // Success, no specific data to return
    } catch (e) {
      if (e is SocketException) {
        throw ApiException(
            'لا يوجد اتصال بالإنترنت أثناء وسم المحادثة كمقروءة.');
      } else if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException('حدث خطأ غير متوقع أثناء وسم المحادثة كمقروءة: $e');
      }
    }
  }

  Future<List<dynamic>> getAvailableChatRecipients() async {
    try {
      final url = Uri.parse('$_baseUrl/chat/available-recipients');
      final response = await http.get(url, headers: await _getAuthHeaders());

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          final List<dynamic> recipientsJson =
              responseData['data']; // Expecting a 'data' key here
          // Map each item to either User or Specialist based on a 'type' field
          return recipientsJson
              .map((jsonItem) {
                // Assuming your API returns a 'type' field like 'user' or 'specialist'
                if (jsonItem['type'] == 'user') {
                  return User.fromJson(jsonItem);
                } else if (jsonItem['type'] == 'specialist') {
                  return Specialist.fromJson(jsonItem);
                }
                return null; // Ignore unknown types
              })
              .where((item) => item != null)
              .toList()
              .cast<dynamic>();
        } else {
          throw ApiException(
              responseData['message'] ?? 'Failed to get available recipients',
              statusCode: response.statusCode);
        }
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      if (e is SocketException) {
        throw ApiException(
            'لا يوجد اتصال بالإنترنت أثناء جلب المستلمين المتاحين.');
      } else if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException(
            'حدث خطأ غير متوقع أثناء جلب المستلمين المتاحين: $e');
      }
    }
  }

  Future<Conversation> createPrivateConversation({
    required dynamic recipientId,
    required String
        recipientType, // e.g., 'App\\Models\\User', 'App\\Models\\Specialist'
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/chat/conversations/private');
      final Map<String, dynamic> requestBody = {
        'recipient_id': recipientId,
        'recipient_type': recipientType,
      };

      final response = await http.post(
        url,
        headers: await _getAuthHeaders(),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == true &&
            responseData.containsKey('data')) {
          return Conversation.fromJson(responseData['data']);
        } else {
          throw ApiException(
              responseData['message'] ??
                  'Failed to create private conversation',
              statusCode: response.statusCode);
        }
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      if (e is SocketException) {
        throw ApiException(
            'لا يوجد اتصال بالإنترنت أثناء إنشاء المحادثة الخاصة.');
      } else if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException('حدث خطأ غير متوقع أثناء إنشاء المحادثة الخاصة: $e');
      }
    }
  }

  Future<void> sendFcmTokenToBackend(
      String fcmToken, String userId, String authToken) async {
    final Map<String, String> deviceInfo =
        await _getDeviceInfo(); // جلب معلومات الجهاز
    final String deviceId = deviceInfo['id']!;
    final String deviceName = deviceInfo['name']!;

    if (kDebugMode) {
      debugPrint(
          'ApiService: sendFcmTokenToBackend - Preparing to send FCM Token.');
      debugPrint('ApiService: sendFcmTokenToBackend - User ID: $userId');
      debugPrint('ApiService: sendFcmTokenToBackend - FCM Token: $fcmToken');
      debugPrint('ApiService: sendFcmTokenToBackend - Device ID: $deviceId');
      debugPrint(
          'ApiService: sendFcmTokenToBackend - Device Name: $deviceName');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/store-fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'user_id': userId,
          'fcm_token': fcmToken,
          'device_id': deviceId, // <--- إرسال Device ID
          'device_name': deviceName, // إرسال Device Name (للتشخيص)
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('FCM Token sent to backend successfully!');
      } else {
        debugPrint(
            'Failed to send FCM Token to backend: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending FCM Token to backend: $e');
    }
  }

  Future<void> deleteFcmTokenFromBackend(
      String fcmToken, String deviceId, String authToken) async {
    if (kDebugMode) {
      debugPrint(
          'ApiService: Attempting to delete FCM token from backend on logout.');
      debugPrint('FCM Token: $fcmToken, Device ID: $deviceId');
    }
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/fcm-token/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken', // 🚀 إرسال رمز المصادقة
        },
        body: jsonEncode({
          'fcm_token': fcmToken,
          'device_id': deviceId,
        }),
      );

      if (kDebugMode) {
        debugPrint(
            'ApiService: FCM token deletion response status: ${response.statusCode}');
        debugPrint(
            'ApiService: FCM token deletion response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint(
              'ApiService: FCM token deleted successfully from backend.');
        }
      } else {
        if (kDebugMode) {
          debugPrint('ApiService: Failed to delete FCM token from backend.');
        }
        // يمكنك التعامل مع الأخطاء هنا بشكل أفضل إذا أردت
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ApiService: Error deleting FCM token from backend: $e');
      }
    }
  }

  Future<Conversation> createGroupConversation({
    required String name,
    required List<Map<String, dynamic>> participants,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/chat/conversations/group');
      final Map<String, dynamic> requestBody = {
        'name': name,
        'participants': participants,
      };

      // 💡 رسالة لتتبع ما يتم إرساله
      debugPrint('Creating group conversation request:');
      debugPrint('URL: $url');
      debugPrint('Headers: ${await _getAuthHeaders()}');
      debugPrint(
          'Request Body: ${jsonEncode(requestBody)}'); // استخدم jsonEncode لعرض الجسم بشكل صحيح

      final response = await http.post(
        url,
        headers: await _getAuthHeaders(),
        body: jsonEncode(requestBody),
      );

      // 💡 رسالة لتتبع الاستجابة الأولية
      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // 💡 رسالة لتتبع بيانات الاستجابة بعد التحليل
        debugPrint('Parsed Response Data: $responseData');

        if (responseData['status'] == true &&
            responseData.containsKey('data')) {
          return Conversation.fromJson(responseData['data']);
        } else {
          // 💡 رسالة خطأ محددة من الخادم
          debugPrint(
              'API Error: ${responseData['message'] ?? 'Failed to create group conversation'}');
          throw ApiException(
              responseData['message'] ?? 'Failed to create group conversation',
              statusCode: response.statusCode);
        }
      } else {
        // 💡 رسالة لتتبع الخطأ في حالة عدم نجاح الاستجابة
        debugPrint(
            'HTTP Error: Status ${response.statusCode}, Body: ${response.body}');
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      // 💡 رسائل لتتبع أنواع الأخطاء المختلفة
      if (e is SocketException) {
        debugPrint(
            'Network Error: No internet connection for creating group chat.');
        throw ApiException(
            'لا يوجد اتصال بالإنترنت أثناء إنشاء المحادثة الجماعية.');
      } else if (e is ApiException) {
        debugPrint('Caught ApiException: ${e.message}');
        rethrow;
      } else {
        debugPrint('Unexpected Error during group chat creation: $e');
        throw ApiException(
            'حدث خطأ غير متوقع أثناء إنشاء المحادثة الجماعية: $e');
      }
    }
  }

  Future<Map<String, dynamic>?> fetchNotifications({int page = 1}) async {
    final authToken = await getToken();
    if (authToken == null) {
      debugPrint('ApiService: لا يوجد رمز مصادقة (Auth Token) لجلب الإشعارات.');
      return {'message': 'غير مصادق. الرجاء تسجيل الدخول.'};
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/notifications?page=$page', // أضف معامل الصفحة هنا
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      debugPrint('حالة جلب الإشعارات: ${response.statusCode}');
      debugPrint('محتوى جلب الإشعارات: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // تعامل مع أخطاء الـ API بلطف
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('خطأ في جلب الإشعارات: $e');
      return {'message': ErrorMessages.noInternetConnection};
    }
  }

  Future<bool> markNotificationAsRead(int notificationId) async {
    final authToken = await getToken();
    if (authToken == null) {
      debugPrint(
          'ApiService: لا يوجد رمز مصادقة (Auth Token) لتحديد الإشعار كمقروء.');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(
            '$_baseUrl/notifications/$notificationId/mark-as-read'), // يجب أن يتطابق مع مسار API في Laravel
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({}), // جسم فارغ لطلب POST حيث المعرف موجود في الـ URL
      );

      debugPrint('حالة تحديد الإشعار كمقروء: ${response.statusCode}');
      debugPrint('محتوى تحديد الإشعار كمقروء: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('خطأ في تحديد الإشعار كمقروء: $e');
      return false;
    }
  }

  Future<ChildDetailResponse> getChildDetails(String childId) async {
    try {
      final url = Uri.parse(
          '$_baseUrl/children/$childId'); // تأكد من هذا المسار في API الخاص بك
      final response = await http.get(url, headers: await _getAuthHeaders());

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // هنا يتم إرجاع كائن ChildDetailResponse بالكامل
        // ChildDetailResponse.fromJson ستستخدم تعريفات DetailedChild و DetailedSpecialist الداخلية الخاصة بها
        return ChildDetailResponse.fromJson(responseData);
      } else {
        // معالجة الأخطاء لغير 200 status codes
        throw _handleErrorResponse(response);
      }
    } on SocketException {
      throw ApiException('لا يوجد اتصال بالإنترنت أثناء جلب تفاصيل الابن.');
    } on ApiException {
      rethrow; // أعد إلقاء أخطاء ApiException المخصصة
    } catch (e) {
      // لأي أخطاء أخرى غير متوقعة
      throw ApiException('حدث خطأ غير متوقع أثناء جلب تفاصيل الابن: $e');
    }
  }

  // دالة جلب الفروع من Laravel API - تم تصحيح نوع الإرجاع والتحليل
  Future<List<Branch>> fetchBranches() async {
    debugPrint("Fetching branches from Laravel API...");
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/branches'),
        headers:
            await _getAuthHeaders(), // أضف رؤوس المصادقة إذا كان الـ API يتطلبها
      );

      debugPrint('Response status for fetchBranches: ${response.statusCode}');
      debugPrint('Response body for fetchBranches: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decodedResponse =
            jsonDecode(response.body); // <--- تغيير هنا

        if (decodedResponse is List) {
          // <--- التحقق أولاً إذا كانت قائمة مباشرة
          return decodedResponse
              .map((branchJson) =>
                  Branch.fromJson(branchJson as Map<String, dynamic>))
              .toList();
        } else if (decodedResponse is Map<String, dynamic> &&
            decodedResponse.containsKey('data') &&
            decodedResponse['data'] is List) {
          // إذا كانت الاستجابة هي كائن JSON يحتوي على مفتاح 'data' وهو قائمة
          return (decodedResponse['data'] as List)
              .map((branchJson) =>
                  Branch.fromJson(branchJson as Map<String, dynamic>))
              .toList();
        } else {
          throw ApiException('هيكل استجابة الفروع غير متوقع.');
        }
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      debugPrint('Error fetching branches: $e');
      if (e is SocketException) {
        throw ApiException('لا يوجد اتصال بالإنترنت أثناء جلب الفروع.');
      } else if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException(
            'حدث خطأ غير متوقع أثناء جلب الفروع: ${e.toString()}');
      }
    }
  }

  Future<String> setUserBranch({
    required String branchId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/user/set-branch');
      final Map<String, dynamic> requestBody = {
        'branch_id': branchId,
      };

      // 💡 رسالة لتتبع ما يتم إرساله
      debugPrint('Setting user branch request:');
      debugPrint('URL: $url');
      debugPrint('Headers: ${await _getAuthHeaders()}');
      debugPrint('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: await _getAuthHeaders(),
        body: jsonEncode(requestBody),
      );

      // 💡 رسالة لتتبع الاستجابة الأولية
      debugPrint(
          'Response Status Code for setUserBranch: ${response.statusCode}');
      debugPrint('Response Body for setUserBranch: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // 💡 رسالة لتتبع بيانات الاستجابة بعد التحليل
        debugPrint('Parsed Response Data for setUserBranch: $responseData');

        if (responseData['success'] == true) {
          return responseData['message'] ?? 'تم تحديث الفرع بنجاح!';
        } else {
          // 💡 رسالة خطأ محددة من الخادم (إذا كان success: false)
          debugPrint(
              'API Error (setUserBranch): ${responseData['message'] ?? 'Failed to set user branch'}');
          throw ApiException(
              responseData['message'] ?? 'Failed to set user branch',
              statusCode: response.statusCode);
        }
      } else {
        // 💡 رسالة لتتبع الخطأ في حالة عدم نجاح الاستجابة
        debugPrint(
            'HTTP Error (setUserBranch): Status ${response.statusCode}, Body: ${response.body}');
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      // 💡 رسائل لتتبع أنواع الأخطاء المختلفة
      if (e is SocketException) {
        debugPrint(
            'Network Error: No internet connection for setting user branch.');
        throw ApiException('لا يوجد اتصال بالإنترنت أثناء تحديث الفرع.');
      } else if (e is ApiException) {
        debugPrint('Caught ApiException (setUserBranch): ${e.message}');
        rethrow; // إعادة إطلاق ApiException الذي تم التقاطه بالفعل
      } else {
        debugPrint('Unexpected Error during setting user branch: $e');
        throw ApiException(
            'حدث خطأ غير متوقع أثناء تحديث الفرع: ${e.toString()}');
      }
    }
  }
}
