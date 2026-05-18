import 'package:flutter_overlay_window/flutter_overlay_window.dart';

/// 悬浮窗服务 — 管理悬浮窗的显示/隐藏/权限
///
/// Android 12+: 前台服务启动限制，需要通知权限
/// Android 13+: 需要 POST_NOTIFICATIONS 运行时权限
class OverlayService {
  OverlayService._();
  static final OverlayService instance = OverlayService._();

  bool get isShowing => _isShowing;
  bool _isShowing = false;

  /// 检查悬浮窗权限
  Future<bool> hasPermission() async {
    return await FlutterOverlayWindow.isPermissionGranted();
  }

  /// 请求悬浮窗权限
  Future<bool> requestPermission() async {
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    if (!granted) {
      await FlutterOverlayWindow.requestPermission();
      await Future.delayed(const Duration(milliseconds: 500));
      return await FlutterOverlayWindow.isPermissionGranted();
    }
    return true;
  }

  /// 显示悬浮窗
  Future<void> show() async {
    final granted = await hasPermission();
    if (!granted) {
      final result = await requestPermission();
      if (!result) return;
    }

    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      height: 56,
      width: WindowSize.matchParent,
      alignment: OverlayAlignment.centerRight,
      positionGravity: PositionGravity.auto,
      flag: OverlayFlag.defaultFlag,
    );

    _isShowing = true;
  }

  /// 隐藏悬浮窗
  Future<void> hide() async {
    if (!_isShowing) return;
    await FlutterOverlayWindow.closeOverlay();
    _isShowing = false;
  }

  /// 标记为已关闭
  void markClosed() {
    _isShowing = false;
  }

  /// 切换悬浮窗
  Future<void> toggle() async {
    if (_isShowing) {
      await hide();
    } else {
      await show();
    }
  }
}
