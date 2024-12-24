import 'package:flutter/material.dart';
import 'package:news/screen/news_detail_screen.dart';

import 'screen/news_list_screen.dart';

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatefulWidget {
  const NewsApp({super.key});

  @override
  State<NewsApp> createState() => _NewsAppState();
}

class _NewsAppState extends State<NewsApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      initialRoute: '/',
      routes: {
        '/': (context) => NewsListScreen(),
        '/news_detail_screen': (context) => NewsDetailScreen(),
      },
    );
  }
}
