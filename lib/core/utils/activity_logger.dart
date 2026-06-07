import 'package:cloud_firestore/cloud_firestore.dart';
import '../di/service_locator.dart';
import '../services/business_context_service.dart';

class ActivityLogger {
  static Future<void> log({
    required String action,
    required String targetType,
    required String targetId,
    required String description,
    Map<String, dynamic>? beforeValue,
    Map<String, dynamic>? afterValue,
    String severity = 'info',
  }) async {
    try {
      final contextService = sl<BusinessContextService>();
      final context = await contextService.getCurrentContext();
      final firestore = FirebaseFirestore.instance;

      await firestore
          .collection('businesses')
          .doc(context.businessId)
          .collection('activity_logs')
          .add({
        'businessId': context.businessId,
        'business_id': context.businessId,
        'action': action,
        'targetType': targetType,
        'target_type': targetType,
        'targetId': targetId,
        'target_id': targetId,
        'description': description,
        if (beforeValue != null) 'beforeValue': beforeValue,
        if (beforeValue != null) 'before_value': beforeValue,
        if (afterValue != null) 'afterValue': afterValue,
        if (afterValue != null) 'after_value': afterValue,
        'performedByUserId': context.userId,
        'performed_by_user_id': context.userId,
        'performedByName': context.userName,
        'performed_by_name': context.userName,
        'performedByRole': context.role,
        'performed_by_role': context.role,
        'performedByEmail': context.userEmail,
        'performed_by_email': context.userEmail,
        'severity': severity,
        'createdAt': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Activity log must never block the primary user action.
    }
  }
}
