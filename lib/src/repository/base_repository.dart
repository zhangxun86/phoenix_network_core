import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:phoenix_network_core/phoenix_network_core.dart';

/// Repository 的基类，提供对核心组件的便捷访问。
/// 应用层的 Repository 可以继承此类来减少模板代码。
abstract class BaseRepository {
  /// 从 DI 容器获取 Dio 实例，用于执行网络请求。
  @protected
  Dio get dioClient => coreLocator<Dio>();
}