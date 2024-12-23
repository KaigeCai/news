import 'package:flutter/material.dart';
import 'package:news/model/news.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsDetailScreen extends StatefulWidget {
  const NewsDetailScreen({super.key});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final WebViewController _webViewController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {
          debugPrint("Page started: $url");
        },
        onPageFinished: (String url) {
          debugPrint("Page finished: $url");
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint("WebResourceError: ${error.description}");
        },
      ),
    );

  @override
  Widget build(BuildContext context) {
    final news = ModalRoute.of(context)?.settings.arguments as News?;
    debugPrint('😊😊😊😊😊😊${news!.url}');
    _webViewController.loadRequest(Uri.parse(news.url));

    return Scaffold(
      appBar: AppBar(
        title: Text(news.title),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(news.url);
            },
          ),
        ],
      ),
      body: WebViewWidget(controller: _webViewController),
    );
  }
}
