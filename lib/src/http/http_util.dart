import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart'; // 引入 Dio v5 兼容的缓存库
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:phoenix_network_core/phoenix_network_core.dart';
import 'custom_transformer.dart';

class HttpUtil {
  late Dio _dio;
  Dio get dio => _dio;

  void init({
    required String baseUrl,
    required String apiVersion,
    List<Interceptor> customInterceptors = const [],
  }) {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );

    _dio = Dio(options);
    _dio.transformer = PhoenixBaseTransformer();

    // 配置新的缓存拦截器
    final cacheOptions = CacheOptions(
      store: MemCacheStore(), // 使用内存作为缓存存储 (可替换为 HiveCacheStore 进行文件持久化缓存)
      policy: CachePolicy.request, // 默认缓存策略：优先网络，失败或缓存有效时读缓存
      hitCacheOnErrorExcept: [401, 403], // 发生特定HTTP错误时，不使用缓存
      maxStale: const Duration(days: 7), // 缓存最长有效期
      priority: CachePriority.normal,
    );

    _dio.interceptors.addAll([
      // 新的缓存拦截器
      DioCacheInterceptor(options: cacheOptions),

      // 重试拦截器
      RetryInterceptor(
        dio: _dio,
        logPrint: kDebugMode ? print : null,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
      // 核心 API 拦截器
      ApiInterceptor(apiVersion),
      // 应用层自定义拦截器
      ...customInterceptors,
    ]);

    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ));
    }
  }
}

/// 核心 API 拦截器，使用 Dio v5 的正确实现方式
class ApiInterceptor extends Interceptor {
  final String apiVersion;
  ApiInterceptor(this.apiVersion);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final loadingManager = coreLocator.get<LoadingManager>();
    final tokenManager = coreLocator.get<TokenManagerInterface>();

    loadingManager.addRequest();
    options.headers['Api-Version'] = apiVersion;

    final token = tokenManager.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 显式调用 next 将请求传递下去
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    coreLocator.get<LoadingManager>().removeRequest();

    // 显式调用 next 将响应传递下去
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    coreLocator.get<LoadingManager>().removeRequest();

    if (err.response?.statusCode == 401) {
      // 触发 Token 失效逻辑
      coreLocator.get<TokenManagerInterface>().clearTokens();
    }

    // 1. 将原始的 DioException 转换为我们自定义的 AppException
    final AppException appException = _handleError(err);

    // 2. 使用 copyWith 创建一个新的 DioException，并将它的 error 字段设置为我们的自定义异常
    final newErr = err.copyWith(error: appException);

    // 3. 显式调用 next，将这个包含了我们自定义异常的新 DioException 实例传递下去
    handler.next(newErr);
  }

  /// 将 DioException 转换为自定义的 AppException
  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: '网络连接超时');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400: return BadRequestException(code: statusCode!, message: '请求语法错误');
          case 401: return UnauthorisedException(code: statusCode!, message: '认证失败，请重新登录');
          case 403: return BadForbiddenException(code: statusCode!, message: '服务器拒绝执行');
          case 404: return BadRequestException(code: statusCode!, message: '请求的资源不存在');
          case 500:
          case 502:
          case 503:
            return BadServiceException(code: statusCode!, message: '服务器发生错误');
          default:
            return AppException(statusCode, error.response?.statusMessage ?? '未知服务器错误');
        }
      case DioExceptionType.cancel:
        return CancelException('请求已取消');
      default: // 包括 DioExceptionType.unknown, connectionError 等
        return NetworkException(message: '网络连接不可用，请检查网络设置');
    }
  }
}