import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/points_repository.dart';

final pointsRepositoryProvider = Provider<PointsRepository>((ref) {
  return PointsRepository();
});
