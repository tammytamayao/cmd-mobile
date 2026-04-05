import '../models/issue.dart';
import 'api_client.dart';
import 'token_storage.dart';

class SupportService {
  final ApiClient _apiClient;

  SupportService({required TokenStorage tokenStorage})
      : _apiClient = ApiClient(tokenStorage: tokenStorage);

  Future<List<IssueModel>> fetchIssues({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.getJson(
      '/api/v1/issues?page=$page&per_page=$perPage',
      auth: true,
    );

    final dynamic data = response['data'];

    if (data is List) {
      return data
          .map((item) => IssueModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return [];
  }

  Future<IssueModel> createIssue(CreateIssuePayload payload) async {
    final response = await _apiClient.postJson(
      '/api/v1/issues',
      body: payload.toJson(),
      auth: true,
    );

    final dynamic data = response['data'] ?? response;

    return IssueModel.fromJson(Map<String, dynamic>.from(data));
  }
}