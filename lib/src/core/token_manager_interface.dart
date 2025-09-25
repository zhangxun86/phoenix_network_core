/// Token 管理器的抽象接口。
/// 应用层需要提供这个接口的具体实现，例如使用 SharedPreferences 或 FlutterSecureStorage。
abstract class TokenManagerInterface {
  Future<void> saveAccessToken(String token);
  String? getAccessToken();
  Future<void> clearTokens();
}