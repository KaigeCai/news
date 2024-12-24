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
        primaryColor: Colors.blue,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.blue,
          onPrimary: Colors.blue,
          secondary: Colors.blue,
          onSecondary: Colors.blue,
          error: Colors.blue,
          onError: Colors.blue,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),
    );
  }
}
