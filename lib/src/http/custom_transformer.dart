// phoenix_network_core/lib/src/http/custom_transformer.dart

import 'package:dio/dio.dart';

class PhoenixBaseTransformer extends BackgroundTransformer {
  @override
  Future transformResponse(
      RequestOptions options, ResponseBody response) async {
    final json = await super.transformResponse(options, response);
    
    // 关键修复：如果响应是一个Map并且包含 'data' 键，
    // 我们就假设业务数据在 'data' 里面，并只返回它。
    // 这让 Retrofit 可以直接用干净的业务数据进行解析。
    if (json is Map<String, dynamic> && json.containsKey('data')) {
      return json['data'];
    }
    
    // 否则，直接返回整个JSON体（比如登录接口的响应）。
    return json;
  }
}
