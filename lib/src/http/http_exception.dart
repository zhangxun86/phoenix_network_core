/// 自定义网络异常
class AppException implements Exception {
  final String? _message;
  final int? _code;

  AppException([this._code, this._message]);

  @override
  String toString() {
    return "$_code$_message";
  }

  String get message => _message ?? "未知错误";
  int get code => _code ?? -1;
}


/// 客户端请求错误
class BadRequestException extends AppException {
  BadRequestException({int code = 400, String message = '无效的请求'})
      : super(code, message);
}

/// 服务端响应错误
class BadServiceException extends AppException {
  BadServiceException({int code = 500, String message = '服务器开小差了'})
      : super(code, message);
}

/// 未知异常
class UnknownException extends AppException {
  UnknownException([String message = '未知异常']) : super(-1, message);
}

/// 取消请求
class CancelException extends AppException {
  CancelException([String message = '请求已取消']) : super(-2, message);
}

/// 网络异常
class NetworkException extends AppException {
  NetworkException({int code = -3, String message = '网络错误，请稍后重试'})
      : super(code, message);
}

/// 未授权
class UnauthorisedException extends AppException {
  UnauthorisedException({int code = 401, String message = '未授权'})
      : super(code, message);
}

/// 请求被禁止
class BadForbiddenException extends AppException {
  BadForbiddenException({int code = 403, String message = '服务器拒绝执行'})
      : super(code, message);
}