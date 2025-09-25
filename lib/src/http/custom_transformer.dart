import 'package:dio/dio.dart';

/// 一个通用的转换器，应用可以根据自己的 BaseResponse 结构来决定是否使用或重写
/// 在这个通用包中，我们保持其简单性，让应用层有更多灵活性
class PhoenixBaseTransformer extends BackgroundTransformer {
  @override
  Future transformResponse(
      RequestOptions options, ResponseBody response) async {
    // 默认行为是使用 Dio 的默认 JSON 解析器
    return super.transformResponse(options, response);
  }
}