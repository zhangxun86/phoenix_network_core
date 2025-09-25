library phoenix_network_core;

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'src/http/http_util.dart';

// 导出所有公共组件，供应用层使用
export 'src/core/loading_manager.dart';
export 'src/core/token_manager_interface.dart';
export 'src/http/http_exception.dart';
export 'src/repository/base_repository.dart';

// 全局的 DI 容器实例
final GetIt coreLocator = GetIt.instance;

/// 框架初始化器
class PhoenixFramework {
  /// 初始化核心网络服务
  /// 
  /// [baseUrl] API 的基础 URL
  /// [apiVersion] API 的版本号，会添加到请求头
  /// [customInterceptors] 应用层可以传入额外的 Dio 拦截器
  static Future<void> initialize({
    required String baseUrl,
    String apiVersion = 'v1',
    List<Interceptor> customInterceptors = const [],
  }) async {
    // 注册配置信息，方便框架内部其他地方使用
    coreLocator.registerSingleton<String>(baseUrl, instanceName: 'baseUrl');
    coreLocator.registerSingleton<String>(apiVersion, instanceName: 'apiVersion');

    // 注册核心服务
    final httpUtil = HttpUtil();
    httpUtil.init(
      baseUrl: baseUrl,
      apiVersion: apiVersion,
      customInterceptors: customInterceptors,
    );
    coreLocator.registerSingleton<HttpUtil>(httpUtil);
    coreLocator.registerSingleton<Dio>(httpUtil.dio); // 同时暴露底层的 Dio 实例
  }
}