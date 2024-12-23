// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsResponse _$NewsResponseFromJson(Map<String, dynamic> json) => NewsResponse(
      reason: json['reason'] as String,
      result: json['result'] == null
          ? null
          : Result.fromJson(json['result'] as Map<String, dynamic>),
      errorCode: (json['error_code'] as num).toInt(),
    );

Map<String, dynamic> _$NewsResponseToJson(NewsResponse instance) =>
    <String, dynamic>{
      'reason': instance.reason,
      'result': instance.result,
      'error_code': instance.errorCode,
    };

Result _$ResultFromJson(Map<String, dynamic> json) => Result(
      stat: json['stat'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => News.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as String,
      pageSize: json['pageSize'] as String,
    );

Map<String, dynamic> _$ResultToJson(Result instance) => <String, dynamic>{
      'stat': instance.stat,
      'data': instance.data,
      'page': instance.page,
      'pageSize': instance.pageSize,
    };

News _$NewsFromJson(Map<String, dynamic> json) => News(
      uniquekey: json['uniquekey'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      category: json['category'] as String,
      authorName: json['author_name'] as String,
      url: json['url'] as String,
      thumbnailPicS: json['thumbnail_pic_s'] as String,
      thumbnailPicS02: json['thumbnail_pic_s02'] as String?,
      thumbnailPicS03: json['thumbnail_pic_s03'] as String?,
    );

Map<String, dynamic> _$NewsToJson(News instance) => <String, dynamic>{
      'uniquekey': instance.uniquekey,
      'title': instance.title,
      'date': instance.date,
      'category': instance.category,
      'author_name': instance.authorName,
      'url': instance.url,
      'thumbnail_pic_s': instance.thumbnailPicS,
      'thumbnail_pic_s02': instance.thumbnailPicS02,
      'thumbnail_pic_s03': instance.thumbnailPicS03,
    };
