import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:news/config/config.dart';

import '../model/news.dart';

class NewsService {
  final Dio dio = Dio();

  Future<NewsResponse> fetchNews(int page, String type) async {
    for (final key in keys) {
      final String url = 'https://v.juhe.cn/toutiao/index?key=$key&type=$type&page=$page&pageSize=30&is_filter=1';

      try {
        // 打印请求URL和参数，查看是否正确
        debugPrint('请求接口: $url');
        final Response<dynamic> response = await dio.get(url);
        // 打印响应数据，查看是否正确返回
        debugPrint('返回数据: ${response.data}');
        if (response.statusCode == 200) {
          final newsResponse = NewsResponse.fromJson(response.data);
          if (newsResponse.result != null) {
            return newsResponse;
          } else {
            continue; // 继续尝试下一个 key
          }
        } else {
          debugPrint('Key: $key 请求失败, 状态码: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Key: $key 请求错误: $e');
      }
    }

    throw Exception('所有key请求均失败, 无法获取新闻数据');
  }
}
