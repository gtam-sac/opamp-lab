import '../models/experiment_session.dart';
import 'api_client.dart';

class ExperimentService {
  final ApiClient _apiClient;

  ExperimentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? const ApiClient();

  Future<ExperimentSession> saveSession({
    required String token,
    required ExperimentSession session,
  }) async {
    final data = await _apiClient.post(
      '/experiments',
      session.toRequestJson(),
      token: token,
    );
    return ExperimentSession.fromJson(
      data['session'] as Map<String, dynamic>,
    );
  }

  Future<List<ExperimentSession>> listSessions(String token) async {
    final data = await _apiClient.get(
      '/experiments',
      token: token,
    );
    final sessions = data['sessions'];
    if (sessions is! List) return [];

    return sessions
        .map(
          (item) => ExperimentSession.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> deleteSession(String token, int id) async {
    await _apiClient.delete(
      '/experiments/$id',
      token: token,
    );
  }
}
