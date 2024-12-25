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

  void _searchNews(String query) async {
    if (query.isEmpty) {
      _page = 1;
      _newsList.clear();
      _loadNews(); // 加载全部新闻
      return;
    }

    // 清空现有新闻列表以准备新的搜索
    setState(() {
      _newsList.clear();
      _newsStreamController.add([]);
    });

    int searchPage = 1;
    bool found = false;
    const int maxPages = 2;

    while (searchPage <= maxPages && !found) {
      try {
        final newsResponse = await _newsService.fetchNews(searchPage, _currentType);

        if (newsResponse.result == null || newsResponse.result!.data.isEmpty) {
          break; // 当前页没有数据
        }

        // 筛选当前页的数据
        final List<News> filteredNews = newsResponse.result!.data.where((news) {
          return news.title.contains(query) || news.date.contains(query);
        }).toList();

        if (filteredNews.isNotEmpty) {
          setState(() {
            _newsList.addAll(filteredNews);
            _newsStreamController.add(_newsList);
          });
          found = true; // 找到匹配结果
        } else {
          searchPage++;
        }
      } catch (e) {
        debugPrint('搜索错误: $e');
        break;
      }
    }

    if (!found) {
      setState(() {
        _newsStreamController.add([]); // 显示没有结果
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            onChanged: (value) {
              _searchNews(value);
            },
            decoration: InputDecoration(
              hintText: '搜索新闻...',
              filled: true,
              prefixIcon: Icon(CupertinoIcons.search),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
            style: TextStyle(fontSize: 16),
            cursorColor: Colors.blue,
          ),
        ),
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

              if (news.isEmpty) {
                return Center(
                  child: Text(
                    '没有搜索到',
                    style: TextStyle(fontSize: 24.0, color: Colors.grey),
                  ),
                );
              }
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
                  failedText: '刷新失败',
                  canTwoLevelText: '松开二级刷新',
                ),
                footer: ClassicFooter(
                  idleText: '上拉加载更多',
                  loadingText: '正在加载中...',
                  canLoadingText: '松开加载',
                  noDataText: '没有更多数据了',
                  failedText: '加载失败，请重试',
                ),
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
              shape: CircleBorder(),
              child: Icon(Icons.arrow_upward, color: Colors.blueAccent),
            )
          : Container(),
    );
  }
}
