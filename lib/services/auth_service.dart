import '../models/subscriber.dart';
import 'api_client.dart';
import 'token_storage.dart';

class LoginResult {
  final String token;
  final Subscriber subscriber;
  LoginResult({required this.token, required this.subscriber});
}

class AuthService {
  final ApiClient api;
  final TokenStorage tokenStorage;

  AuthService({required this.api, required this.tokenStorage});

  Future<LoginResult> loginSubscriber({
    required String serialNumber,
    required String password,
  }) async {
    final data = await api.postJson(
      "/api/v1/sessions",
      body: {"serial_number": serialNumber, "password": password},
    );

    final token = (data["token"] ?? "").toString();
    if (token.isEmpty) throw ApiException(500, "Missing token in response.");

    final subscriberJson = data["subscriber"];
    if (subscriberJson is! Map<String, dynamic>) {
      throw ApiException(500, "Missing subscriber in response.");
    }

    final subscriber = Subscriber.fromJson(subscriberJson);
    await tokenStorage.saveToken(token);

    return LoginResult(token: token, subscriber: subscriber);
  }

  Future<Map<String, dynamic>> me() async {
    return api.getJson("/api/v1/session/me", auth: true);
  }

  Future<void> logout() async {
    await tokenStorage.clearToken();
  }
}
