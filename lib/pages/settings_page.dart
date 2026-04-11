import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../crawler/config.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AppState>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('设置'),
            Text('站点、下载目录',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          return ListView(
            children: [
              // 站点选择 - 必须先选择
              _buildSiteSection(appState),
              
              // 下载目录
              _buildDownloadDirSection(appState),
              
              // 权限状态
              _buildPermissionSection(appState),
              
              // 关于
              _buildAboutSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSiteSection(AppState appState) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language, size: 20, color: Colors.blue),
                SizedBox(width: 8),
                Text('当前站点', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (!appState.isSiteSelected) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('请选择', style: TextStyle(color: Colors.orange, fontSize: 12)),
                  ),
                ],
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: appState.currentSite,
              hint: Text('请选择站点', style: TextStyle(color: Colors.grey)),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: CrawlerConfig.availableSites.map((site) {
                return DropdownMenuItem(
                  value: site,
                  child: Text(site),
                );
              }).toList(),
              onChanged: (site) {
                if (site != null) {
                  appState.changeSite(site);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已切换到 $site')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadDirSection(AppState appState) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder, size: 20, color: Colors.amber),
                SizedBox(width: 8),
                Text('下载目录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      appState.downloadDir.isEmpty 
                        ? '正在初始化...' 
                        : appState.downloadDir,
                      style: TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.copy, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSection(AppState appState) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, size: 20, color: Colors.green),
                SizedBox(width: 8),
                Text('权限状态', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                appState.permissionGranted ? Icons.check_circle : Icons.error,
                color: appState.permissionGranted ? Colors.green : Colors.red,
              ),
              title: Text('存储权限'),
              subtitle: Text(appState.permissionGranted ? '已授权' : '未授权'),
              trailing: !appState.permissionGranted
                ? TextButton(
                    onPressed: () => appState.requestPermissions(),
                    child: Text('授权'),
                  )
                : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, size: 20, color: Colors.purple),
                SizedBox(width: 8),
                Text('关于', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            Text('91Download 移动端', style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text('版本: v1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey)),
            SizedBox(height: 8),
            Text('视频下载工具移动端版本', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
