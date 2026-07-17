import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/network_service.dart';
import '../services/anonymous_auth_service.dart';
import '../services/deep_seek_service.dart';
import '../services/post_image_storage_service.dart';

/// Global [NetworkService] (Dio) for API calls.
final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});

/// Global [DeepSeekService] for recipe generation and mascot chat.
final deepSeekServiceProvider = Provider<DeepSeekService>((ref) {
  final network = ref.watch(networkServiceProvider);
  return DeepSeekService(network.dio);
});

final anonymousAuthServiceProvider = Provider<AnonymousAuthService>((ref) {
  return AnonymousAuthService();
});

final postImageStorageServiceProvider = Provider<PostImageStorageService>((ref) {
  return PostImageStorageService();
});
