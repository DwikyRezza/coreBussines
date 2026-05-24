import 'package:cloud_firestore/cloud_firestore.dart';
import '../di/service_locator.dart';
import '../services/business_context_service.dart';

class ActivityLogger {
  static Future<void> log({
    required String action,
    required String targetType,
    required String targetId,
    required String description,
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
        'action': action,
        'targetType': targetType,
        'targetId': targetId,
        'description': description,
        'performedByUserId': context.userId,
        'performedByName': context.userName,
        'performedByRole': context.role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Activity log must never block the primary user action.
    }
  }
}
