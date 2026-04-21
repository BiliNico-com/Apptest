import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/followed_authors_service.dart';

/// 已关注作者页面
class FollowedPage extends StatefulWidget {
  const FollowedPage({super.key});

  @override
  State<FollowedPage> createState() => _FollowedPageState();
}

class _FollowedPageState extends State<FollowedPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final appState = context.watch<AppState>();
    final followedList = appState.followedAuthorsService.followedList;

    return Scaffold(
      appBar: AppBar(
        title: Text('已关注 (${followedList.length})'),
        centerTitle: true,
      ),
      body: followedList.isEmpty
          ? _buildEmptyState()
          : _buildAuthorGrid(followedList, appState),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('暂无关注的作者', style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text('进入作者主页后点击关注按钮即可关注', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAuthorGrid(List<FollowedAuthor> followedList, AppState appState) {
    return RefreshIndicator(
      onRefresh: () async {
        await appState.followedAuthorsService.refresh();
      },
      child: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.75,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: followedList.length,
        itemBuilder: (context, index) => _buildAuthorCard(followedList[index], appState),
      ),
    );
  }

  Widget _buildAuthorCard(FollowedAuthor author, AppState appState) {
    return GestureDetector(
      onTap: () => _enterAuthorPage(author.authorId, author.authorName, appState),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 头像
            Expanded(
              child: Container(
                color: Colors.grey[800],
                child: author.avatarUrl != null && author.avatarUrl!.isNotEmpty
                    ? Image.network(
                        author.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.person, size: 48, color: Colors.grey),
                      )
                    : Icon(Icons.person, size: 48, color: Colors.grey),
              ),
            ),
            // 作者名和取消关注按钮
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      author.authorName,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // 阻止事件冒泡到父级卡片
                      _unfollowAuthor(author, appState);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.favorite, size: 18, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 进入作者主页 - 复用 BatchPage 的作者主页功能
  void _enterAuthorPage(String authorId, String authorName, AppState appState) {
    appState.enterAuthorFromFollowed(authorId, authorName);
  }

  Future<void> _unfollowAuthor(FollowedAuthor author, AppState appState) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('取消关注'),
        content: Text('确定取消关注 ${author.authorName} 吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('确定')),
        ],
      ),
    );

    if (confirmed == true) {
      await appState.followedAuthorsService.unfollow(author.authorId);
    }
  }
}
