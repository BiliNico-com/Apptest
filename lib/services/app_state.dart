import 'package:flutter/material.dart';
import '../crawler/crawler_core.dart';
import '../models/video_info.dart';

class AppState extends ChangeNotifier {
  // 站点配置
  String currentSite = 'https://91porn.com';
  
  // 下载配置
  String downloadDir = '';
  bool proxyEnabled = false;
  String proxyHost = '127.0.0.1';
  String proxyPort = '1080';
  
  // 主题
  bool isDarkMode = true;
  
  // 爬虫实例
  CrawlerCore? _crawler;
  
  CrawlerCore get crawler {
    _crawler ??= CrawlerCore(baseUrl: currentSite);
    return _crawler!;
  }
  
  // 切换站点
  void changeSite(String site) {
    currentSite = site;
    _crawler?.changeSite(site);
    notifyListeners();
  }
  
  // 切换主题
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
  
  // 设置代理
  void setProxy({
    required bool enabled,
    String? host,
    String? port,
  }) {
    proxyEnabled = enabled;
    if (host != null) proxyHost = host;
    if (port != null) proxyPort = port;
    notifyListeners();
  }
  
  // 设置下载目录
  void setDownloadDir(String dir) {
    downloadDir = dir;
    notifyListeners();
  }
}
