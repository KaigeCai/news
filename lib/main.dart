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
      initialRoute: '/',
      routes: {
        '/': (context) => NewsListScreen(),
        '/news_detail_screen': (context) => NewsDetailScreen(),
      },
      theme: ThemeData(
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: Colors.blue,
        ),
        tabBarTheme: TabBarTheme(
          indicatorColor: Colors.blue,
          unselectedLabelColor: Colors.black,
          labelColor: Colors.lightBlue,
          dividerColor: Colors.transparent,
        ),
        colorScheme: ColorScheme.light(
          primary: Colors.white,
        ),
      ),
    );
  }
}
