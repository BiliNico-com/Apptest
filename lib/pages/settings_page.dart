import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/app_state.dart';
import '../crawler/config.dart';
import '../utils/logger.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _logContent = '';
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AppState>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
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
          body: ListView(
            children: [
              // 站点选择 - 必须先选择
              _buildSiteSection(appState),
              
              // 下载目录
              _buildDownloadDirSection(appState),
              
              // 权限状态
              _buildPermissionSection(appState),
              
              // Debug设置
              _buildDebugSection(appState),
              
              // 关于
              _buildAboutSection(),
            ],
          ),
        );
      },
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
              onChanged: (site) async {
                if (site != null) {
                  appState.changeSite(site);
                  await logger.i('Settings', 'UI操作: 切换站点 -> $site');
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
                    onPressed: () async {
                      await logger.i('Settings', 'UI操作: 点击授权按钮');
                      await appState.requestPermissions();
                    },
                    child: Text('授权'),
                  )
                : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugSection(AppState appState) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report, size: 20, color: Colors.purple),
                SizedBox(width: 8),
                Text('调试设置', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Debug模式'),
              subtitle: Text('开启后将记录运行日志'),
              value: appState.debugMode,
              onChanged: (v) async {
                await logger.i('Settings', 'UI操作: 切换Debug模式 -> $v');
                await appState.toggleDebug(v);
              },
            ),
            if (appState.debugMode) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _loadLog,
                      icon: Icon(Icons.visibility, size: 18),
                      label: Text('查看日志'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _exportLog,
                      icon: Icon(Icons.share, size: 18),
                      label: Text('分享日志'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _saveLog(appState.downloadDir),
                      icon: Icon(Icons.save, size: 18),
                      label: Text('保存日志'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clearLog,
                      icon: Icon(Icons.delete, size: 18, color: Colors.red),
                      label: Text('清空日志', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              if (_logContent.isNotEmpty) ...[
                SizedBox(height: 12),
                Container(
                  height: 200,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _logContent,
                      style: TextStyle(fontSize: 10, color: Colors.green, fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, size: 20, color: Colors.cyan),
                SizedBox(width: 8),
                Text('关于', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            Text('91Download 移动端', style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text('版本: v1.0.2', style: TextStyle(fontSize: 12, color: Colors.grey)),
            SizedBox(height: 8),
            Text('视频下载工具移动端版本', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  
  Future<void> _loadLog() async {
    await logger.i('Settings', 'UI操作: 点击查看日志');
    final content = await logger.getLogContent();
    setState(() {
      _logContent = content;
    });
  }
  
  Future<void> _exportLog() async {
    await logger.i('Settings', 'UI操作: 点击分享日志');
    final content = await logger.getLogContent();
    if (content.isEmpty || content == '暂无日志') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('暂无日志可导出')),
      );
      return;
    }
    
    await Share.share(content, subject: '91Download Debug Log');
  }
  
  Future<void> _saveLog(String downloadDir) async {
    await logger.i('Settings', 'UI操作: 点击保存日志');
    if (downloadDir.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('下载目录未初始化')),
      );
      return;
    }
    
    final savedPath = await logger.saveToDirectory(downloadDir);
    if (savedPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('日志已保存到: $savedPath')),
      );
      await logger.i('Settings', '日志已保存: $savedPath');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存日志失败')),
      );
    }
  }
  
  Future<void> _clearLog() async {
    await logger.i('Settings', 'UI操作: 点击清空日志');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认清空'),
        content: Text('确定要清空所有日志吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await logger.clearLogs();
      setState(() {
        _logContent = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('日志已清空')),
      );
    }
  }
}
