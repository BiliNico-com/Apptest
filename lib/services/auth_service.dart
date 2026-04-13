import 'dart:io';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// 生物识别认证服务
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  /// 检查设备是否支持生物识别
  Future<bool> isDeviceSupported() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      return isSupported;
    } on PlatformException {
      return false;
    }
  }
  
  /// 检查是否有可用的生物识别（指纹/面容）
  Future<bool> canCheckBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      return canCheck;
    } on PlatformException {
      return false;
    }
  }
  
  /// 获取可用的生物识别类型
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics;
    } on PlatformException {
      return [];
    }
  }
  
  /// 进行生物识别认证
  /// 返回 true 表示认证成功
  Future<bool> authenticate() async {
    try {
      // 根据平台设置不同的提示信息
      String cancelButton = '取消';
      String goToSettingsButton = '去设置';
      String goToSettingsDescription = Platform.isIOS 
          ? '请在设置中开启面容ID或触控ID' 
          : '请在设置中开启生物识别';
      
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: '请验证身份以继续使用应用',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,  // 只允许生物识别，不允许PIN码
        ),
      );
      return didAuthenticate;
    } on PlatformException {
      return false;
    }
  }
  
  /// 停止认证
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } on PlatformException {
      // 忽略
    }
  }
}
