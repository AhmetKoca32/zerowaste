import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/anonymous_auth_service.dart';
import '../services/deep_seek_service.dart';
import '../services/leave_contest_service.dart';
import '../services/post_image_storage_service.dart';

/// Global [DeepSeekService] for recipe generation and mascot chat.
final deepSeekServiceProvider = Provider<DeepSeekService>((ref) {
  return DeepSeekService();
});

final anonymousAuthServiceProvider = Provider<AnonymousAuthService>((ref) {
  return AnonymousAuthService();
});

final postImageStorageServiceProvider = Provider<PostImageStorageService>((
  ref,
) {
  return PostImageStorageService();
});

final leaveContestServiceProvider = Provider<LeaveContestService>((ref) {
  return LeaveContestService();
});
