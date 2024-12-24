import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../model/news.dart';
import '../service/news_service.dart';
import '../widget/news_item.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final NewsService _newsService = NewsService();
  final List<News> _newsList = [];
  int _page = 1;
  bool _isLoading = false;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final StreamController<List<News>> _newsStreamController = StreamController<List<News>>();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    _loadNews();
    // 监听滚动事件，显示或隐藏悬浮按钮
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showScrollToTopButton) {
        setState(() {
          _showScrollToTopButton = true;
        });
      } else if (_scrollController.offset <= 300 && _showScrollToTopButton) {
        setState(() {
          _showScrollToTopButton = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _newsStreamController.close();
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadNews() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newsResponse = await _newsService.fetchNews(_page, 'keji');
      setState(() {
        _newsList.addAll(newsResponse.result!.data);
        _page++;
        _newsStreamController.add(_newsList);
      });
    } catch (e) {
      // 处理异常
      if (mounted) {
        debugPrint('错误日志:$e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载失败, $e'),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onRefresh() async {
    _page = 1;
    _newsList.clear();
    _loadNews();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _loadNews();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('新闻')),
      body: StreamBuilder<List<News>>(
          stream: _newsStreamController.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _newsList.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('加载错误: ${snapshot.error}'));
            }

            final List<News> news = snapshot.data ?? [];

            return SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: true,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              footer: PullUpFooter(),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: news.length,
                itemBuilder: (context, index) {
                  return NewsItem(news: news[index]);
                },
              ),
            );
          }),
      floatingActionButton: _showScrollToTopButton
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              mini: true,
              child: Icon(
                Icons.arrow_upward,
                color: Colors.blueAccent,
              ),
            )
          : Container(),
    );
  }
}

class PullUpFooter extends StatelessWidget {
  const PullUpFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus? mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.up_arrow),
              Text('上拉加载更多'),
            ],
          );
        } else if (mode == LoadStatus.loading) {
          body = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 2),
              SizedBox(width: 10),
              Text('正在加载中...'),
            ],
          );
        } else if (mode == LoadStatus.failed) {
          body = Text('加载失败！点击重试！');
        } else if (mode == LoadStatus.canLoading) {
          body = Text('释放加载更多');
        } else {
          body = Text('没有更多数据了');
        }
        return SizedBox(
          height: 55.0,
          child: Center(child: body),
        );
      },
    );
  }
}
