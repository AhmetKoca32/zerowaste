import 'package:cloud_functions/cloud_functions.dart';

/// Calls admin-deployed `leaveContest` (europe-west1) to hard-wipe contest data.
///
/// Deletes `user_stats`, that nickname's posts (+ Storage best-effort), and
/// removes the nick from the leaderboard. Not a ban — nickname can be reclaimed.
class LeaveContestService {
  LeaveContestService({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: _region);

  static const String _region = 'europe-west1';
  static const String _callableName = 'leaveContest';

  final FirebaseFunctions _functions;

  /// Wipes contest identity for [nickname]. Caller must be signed in as owner.
  ///
  /// Returns `alreadyGone: true` when stats were already missing.
  Future<LeaveContestResult> leaveContest(String nickname) async {
    final callable = _functions.httpsCallable(_callableName);
    try {
      final response = await callable.call<Map<String, dynamic>>({
        'nickname': nickname,
      });
      final data = response.data;
      final alreadyGone = data['alreadyGone'] == true;
      return LeaveContestResult(alreadyGone: alreadyGone);
    } on FirebaseFunctionsException catch (e) {
      throw LeaveContestException(
        code: e.code,
        message: e.message ?? e.code,
      );
    }
  }
}

class LeaveContestResult {
  const LeaveContestResult({this.alreadyGone = false});

  final bool alreadyGone;
}

class LeaveContestException implements Exception {
  const LeaveContestException({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;

  bool get isPermissionDenied => code == 'permission-denied';
  bool get isBannedNickname => code == 'failed-precondition';

  @override
  String toString() => 'LeaveContestException($code): $message';
}
