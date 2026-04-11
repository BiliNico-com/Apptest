import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../crawler/crawler_core.dart';
import '../models/video_info.dart';

class AppState extends ChangeNotifier {
  // 站点配置 - 默认为空，用户必须选择
  String? currentSite;
  
  // 下载目录
  String downloadDir = '';
  bool permissionGranted = false;
  
  // 主题
  bool isDarkMode = true;
  
  // 爬虫实例
  CrawlerCore? _crawler;
  
  CrawlerCore? get crawler {
    if (currentSite == null) return null;
    _crawler ??= CrawlerCore(baseUrl: currentSite!);
    return _crawler;
  }
  
  // 初始化 - 请求权限并设置默认下载目录
  Future<void> init() async {
    await requestPermissions();
    await initDownloadDir();
  }
  
  // 请求存储权限
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ 不需要 WRITE_EXTERNAL_STORAGE
      final status = await Permission.storage.request();
      permissionGranted = status.isGranted;
      
      // 如果是 Android 11+，还需要管理外部存储权限
      if (!permissionGranted) {
        final manageStatus = await Permission.manageExternalStorage.request();
        permissionGranted = manageStatus.isGranted;
      }
    } else {
      permissionGranted = true;
    }
    notifyListeners();
    return permissionGranted;
  }
  
  // 初始化下载目录
  Future<void> initDownloadDir() async {
    if (downloadDir.isEmpty) {
      if (Platform.isAndroid) {
        // Android: 使用外部存储的 Download 目录
        final dir = Directory('/storage/emulated/0/Download/91Download');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        downloadDir = dir.path;
      } else {
        // iOS: 使用应用文档目录
        final appDir = await getApplicationDocumentsDirectory();
        downloadDir = '${appDir.path}/91Download';
      }
    }
    notifyListeners();
  }
  
  // 检查站点是否已选择
  bool get isSiteSelected => currentSite != null && currentSite!.isNotEmpty;
  
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
  
  // 设置下载目录
  void setDownloadDir(String dir) {
    downloadDir = dir;
    notifyListeners();
  }
}
