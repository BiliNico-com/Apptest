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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('设置'),
            Text('保存目录、代理、下载选项',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      body: ListView(
        children: [
          // 站点选择
          _buildSection('当前站点', Icons.language, _buildSiteSelector()),
          
          // 代理设置
          _buildSection('代理设置', Icons.vpn_lock, _buildProxySettings()),
          
          // 下载设置
          _buildSection('下载选项', Icons.download, _buildDownloadOptions()),
          
          // 关于
          _buildSection('关于', Icons.info, _buildAbout()),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildSiteSelector() {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return DropdownButtonFormField<String>(
          value: appState.currentSite,
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
        );
      },
    );
  }

  Widget _buildProxySettings() {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Column(
          children: [
            SwitchListTile(
              title: Text('启用代理'),
              value: appState.proxyEnabled,
              onChanged: (v) => appState.setProxy(enabled: v),
            ),
            if (appState.proxyEnabled) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: appState.proxyHost,
                      decoration: InputDecoration(
                        labelText: '主机',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => appState.setProxy(enabled: true, host: v),
                    ),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      initialValue: appState.proxyPort,
                      decoration: InputDecoration(
                        labelText: '端口',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => appState.setProxy(enabled: true, port: v),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDownloadOptions() {
    return Column(
      children: [
        SwitchListTile(
          title: Text('标题包含上传者'),
          value: true,
          onChanged: (v) {},
        ),
        SwitchListTile(
          title: Text('按日期分类'),
          value: false,
          onChanged: (v) {},
        ),
      ],
    );
  }

  Widget _buildAbout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('91Download Mobile'),
        SizedBox(height: 8),
        Text('版本: 1.0.0', style: TextStyle(color: Colors.grey)),
        SizedBox(height: 16),
        Text(
          '本项目代码由 AI（Claude）辅助编写，仅供学习交流使用。',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
