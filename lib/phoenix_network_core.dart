library phoenix_network_core;

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'src/core/loading_manager.dart'; // 确保引入 LoadingManager
import 'src/http/http_util.dart';

export 'src/core/loading_manager.dart';
export 'src/core/token_manager_interface.dart';
export 'src/http/http_exception.dart';
export 'src/repository/base_repository.dart';

final GetIt coreLocator = GetIt.instance;

class PhoenixFramework {
  static Future<void> initialize({
    required String baseUrl,
    String apiVersion = 'v1',
    List<Interceptor> customInterceptors = const [],
  }) async {
    // --- 关键修复：在这里注册 LoadingManager ---
    // 检查是否已经注册，避免重复注册
    if (!coreLocator.isRegistered<LoadingManager>()) {
      coreLocator.registerSingleton<LoadingManager>(LoadingManager());
    }
    
    coreLocator.registerSingleton<String>(baseUrl, instanceName: 'baseUrl');
    coreLocator.registerSingleton<String>(apiVersion, instanceName: 'apiVersion');

    final httpUtil = HttpUtil();
    httpUtil.init(
      baseUrl: baseUrl,
      apiVersion: apiVersion,
      customInterceptors: customInterceptors,
    );
    coreLocator.registerSingleton<HttpUtil>(httpUtil);
    coreLocator.registerSingleton<Dio>(httpUtil.dio);
  }
}
