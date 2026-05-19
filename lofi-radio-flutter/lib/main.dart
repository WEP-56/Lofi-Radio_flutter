import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'pages/home_page.dart';
import 'services/audio_service.dart';
import 'services/focus_timer_service.dart';
import 'overlay/overlay_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 沉浸式状态栏 + 导航栏
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.backgroundDeep,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // 竖屏锁定
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 异步初始化服务
  unawaited(AudioPlayerService.instance.init());
  FocusTimerService.instance.init();

  runApp(const LofiRadioApp());
}

/// 悬浮窗入口点 — 必须是顶层函数且带 @pragma
/// flutter_overlay_window 会通过此函数启动 overlay 的 Flutter engine
@pragma("vm:entry-point")
void overlayMain() {
  overlayEntry();
}

class LofiRadioApp extends StatelessWidget {
  const LofiRadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lofi Radio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomePage(),
    );
  }
}
