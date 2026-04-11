import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_info.dart';
import '../services/app_state.dart';

class BatchPage extends StatefulWidget {
  const BatchPage({super.key});

  @override
  State<BatchPage> createState() => _BatchPageState();
}

class _BatchPageState extends State<BatchPage> {
  String _selectedType = 'list';
  int _pageStart = 1;
  int _pageEnd = 3;
  List<VideoInfo> _videos = [];
  Set<String> _selectedIds = {};
  bool _isLoading = false;
  String _status = '就绪';
  double _progress = 0.0;
  String _progressText = '';
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        // 检查是否已选择站点
        if (!appState.isSiteSelected) {
          return _buildNoSiteSelected();
        }
        
        return _buildMainContent();
      },
    );
  }
  
  Widget _buildNoSiteSelected() {
    return Scaffold(
      appBar: AppBar(
        title: Text('批量爬取'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.language, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('请先选择站点', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('在设置页面选择要使用的站点', style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 24),
            Text('← 左滑到设置页面选择站点', 
              style: TextStyle(fontSize: 14, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMainContent() {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('批量爬取'),
            Text('按页面范围批量下载视频资源', 
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(_status, style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSettings(),
          if (_progress > 0) _buildProgress(),
          Expanded(child: _buildVideoGrid()),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text('列表: '),
                Expanded(
                  child: DropdownButtonFormField(
                    value: _selectedType,
                    items: [
                    DropdownMenuItem(value: 'list', child: Text('视频')),
                    DropdownMenuItem(value: 'hot', child: Text('当前最热')),
                    DropdownMenuItem(value: 'topm', child: Text('本月最热')),
                    DropdownMenuItem(value: 'ori', child: Text('91原创')),
                  ],
                    onChanged: (v) => setState(() => _selectedType = v!),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('页码: '),
                SizedBox(width: 50, child: TextFormField(initialValue: '1', onChanged: (v) => _pageStart = int.tryParse(v) ?? 1)),
                Text(' ~ '),
                SizedBox(width: 50, child: TextFormField(initialValue: '3', onChanged: (v) => _pageEnd = int.tryParse(v) ?? 3)),
                Spacer(),
                FilledButton(
                  onPressed: _isLoading ? null : _loadVideos,
                  child: _isLoading 
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('加载'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          LinearProgressIndicator(value: _progress),
          SizedBox(height: 4),
          Text(_progressText, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildVideoGrid() {
    if (_isLoading && _videos.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (_videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('点击加载获取视频列表', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        final isSelected = _selectedIds.contains(video.id);
        
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedIds.remove(video.id);
              } else {
                _selectedIds.add(video.id);
              }
            });
          },
          child: Card(
            color: isSelected ? Colors.blue.withOpacity(0.2) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Center(
                      child: Icon(Icons.play_circle, size: 48, color: Colors.white54),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: _videos.isEmpty ? null : () {
              setState(() {
                if (_selectedIds.length == _videos.length) {
                  _selectedIds.clear();
                } else {
                  _selectedIds = _videos.map((v) => v.id).toSet();
                }
              });
            },
            child: Text(_selectedIds.length == _videos.length ? '取消全选' : '全选'),
          ),
          Spacer(),
          FilledButton(
            onPressed: _selectedIds.isEmpty ? null : _startDownload,
            child: Text('下载 (${_selectedIds.length})'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _status = '加载中...';
      _videos.clear();
    });
    
    final appState = context.read<AppState>();
    final crawler = appState.crawler;
    
    if (crawler == null) {
      setState(() {
        _isLoading = false;
        _status = '请先选择站点';
      });
      return;
    }
    
    final videos = <VideoInfo>[];
    for (var p = _pageStart; p <= _pageEnd; p++) {
      final list = await crawler.getVideoList(_selectedType, p);
      videos.addAll(list);
    }
    
    setState(() {
      _videos = videos;
      _selectedIds = videos.map((v) => v.id).toSet();
      _isLoading = false;
      _status = '就绪';
    });
  }

  void _startDownload() {
    // TODO: 实现下载逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('开始下载 ${_selectedIds.length} 个视频')),
    );
  }
}
