import 'package:json_annotation/json_annotation.dart';

part 'news.g.dart'; // 生成代码的文件

@JsonSerializable()
class NewsResponse {
  final String reason;
  final Result? result;
  @JsonKey(name: 'error_code')
  final int errorCode;

  NewsResponse({
    required this.reason,
    required this.result,
    required this.errorCode,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) => _$NewsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NewsResponseToJson(this);
}

@JsonSerializable()
class Result {
  final String stat;
  final List<News> data;
  final String page;
  final String pageSize;

  Result({
    required this.stat,
    required this.data,
    required this.page,
    required this.pageSize,
  });

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);

  Map<String, dynamic> toJson() => _$ResultToJson(this);
}

// 定义新闻模型类
@JsonSerializable()
class News {
  final String uniquekey;
  final String title;
  final String date;
  final String category; // 使用枚举来处理类型
  @JsonKey(name: 'author_name')
  final String authorName;
  final String url;
  @JsonKey(name: 'thumbnail_pic_s')
  final String thumbnailPicS;
  @JsonKey(name: 'thumbnail_pic_s02')
  final String? thumbnailPicS02;
  @JsonKey(name: 'thumbnail_pic_s03')
  final String? thumbnailPicS03;

  News({
    required this.uniquekey,
    required this.title,
    required this.date,
    required this.category,
    required this.authorName,
    required this.url,
    required this.thumbnailPicS,
    this.thumbnailPicS02,
    this.thumbnailPicS03,
  });

  // 从JSON创建News对象
  factory News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);

  // 将News对象转换为JSON
  Map<String, dynamic> toJson() => _$NewsToJson(this);
}
