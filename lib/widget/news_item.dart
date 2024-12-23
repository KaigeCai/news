import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../model/news.dart';

class NewsItem extends StatelessWidget {
  const NewsItem({super.key, required this.news});

  final News news;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/news_detail_screen', arguments: news);
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                news.title,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            if (news.thumbnailPicS.isNotEmpty || news.thumbnailPicS02 != null || news.thumbnailPicS03 != null)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (news.thumbnailPicS.isNotEmpty) ImageWidget(picUrl: news.thumbnailPicS),
                    if (news.thumbnailPicS02 != null) ImageWidget(picUrl: news.thumbnailPicS02!),
                    if (news.thumbnailPicS03 != null) ImageWidget(picUrl: news.thumbnailPicS03!),
                  ],
                ),
              ),
            Row(
              children: [
                Container(
                  width: 240.0,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    news.authorName,
                    style: TextStyle(fontSize: 14, color: Colors.red),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    news.date,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ImageWidget extends StatelessWidget {
  const ImageWidget({super.key, required this.picUrl});

  final String picUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: picUrl,
      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => Icon(Icons.error),
      width: 380.0,
      height: 230.0,
      fit: BoxFit.cover,
    );
  }
}
