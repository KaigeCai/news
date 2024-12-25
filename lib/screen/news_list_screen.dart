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

class _NewsListScreenState extends State<NewsListScreen> with SingleTickerProviderStateMixin {
  final NewsService _newsService = NewsService();
  final List<News> _newsList = [];
  int _page = 1;
  bool _isLoading = false;
  final Map<String, RefreshController> _refreshControllers = {};
  final StreamController<List<News>> _newsStreamController = StreamController<List<News>>.broadcast();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;
  late TabController _tabController;
  String _currentType = 'top';

  final List<Map<String, String>> _categories = [
    {'type': 'top', 'label': '推荐'},
    {'type': 'guonei', 'label': '国内'},
    {'type': 'guoji', 'label': '国际'},
    {'type': 'yule', 'label': '娱乐'},
    {'type': 'tiyu', 'label': '体育'},
    {'type': 'junshi', 'label': '军事'},
    {'type': 'keji', 'label': '科技'},
    {'type': 'caijing', 'label': '财经'},
    {'type': 'youxi', 'label': '游戏'},
    {'type': 'qiche', 'label': '汽车'},
    {'type': 'jiankang', 'label': '健康'},
  ];

  @override
  void initState() {
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentType = _categories[_tabController.index]['type']!;
          _page = 1;
          _newsList.clear(); // 清空当前列表
          _newsStreamController.add([]); // 通知UI更新为空状态
        });
        _loadNews();
      }
    });

    // 监听 TabController 的动画，处理滑动切换的逻辑
    _tabController.animation?.addListener(() {
      final int targetIndex = _tabController.animation!.value.round();
      if (targetIndex != _tabController.index) {
        setState(() {
          _currentType = _categories[targetIndex]['type']!;
          _page = 1;
          _newsList.clear(); // 清空当前列表
          _newsStreamController.add([]); // 通知UI更新为空状态
        });
        _loadNews();
      }
    });

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
    _refreshControllers.forEach((key, controller) => controller.dispose());
    _scrollController.dispose();
    super.dispose();
  }

  void _loadNews() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newsResponse = await _newsService.fetchNews(_page, _currentType);

      if (!mounted) return; // 避免组件被销毁时调用 setState

      setState(() {
        if (_page == 1) {
          _newsList.clear();
        }
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新闻'),
        bottom: TabBar(
          tabAlignment: TabAlignment.start,
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((category) => Tab(text: category['label'])).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((category) {
          final String type = category['type']!;
          if (!_refreshControllers.containsKey(type)) {
            _refreshControllers[type] = RefreshController(initialRefresh: false);
          }
          return StreamBuilder<List<News>>(
            stream: _newsStreamController.stream,
            builder: (BuildContext context, AsyncSnapshot<List<News>> snapshot) {
              final RefreshController refreshController = _refreshControllers[type]!;
              if (_newsList.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('加载错误: ${snapshot.error}'));
              }

              final List<News> news = snapshot.data ?? [];

              return SmartRefresher(
                controller: refreshController,
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: () {
                  _onRefresh();
                  refreshController.refreshCompleted();
                },
                onLoading: () {
                  _loadNews();
                  refreshController.loadComplete();
                },
                header: ClassicHeader(
                  idleText: '下拉刷新',
                  releaseText: '松开刷新',
                  refreshingText: '正在刷新...',
                  completeText: '刷新完成',
                ),
                footer: PullUpFooter(),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: news.length,
                  itemBuilder: (context, index) {
                    return NewsItem(news: news[index]);
                  },
                ),
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: _showScrollToTopButton
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 10),
                  curve: Curves.easeInOut,
                );
              },
              mini: true,
              child: Icon(Icons.arrow_upward, color: Colors.blueAccent),
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
