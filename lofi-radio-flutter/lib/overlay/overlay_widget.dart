import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 悬浮窗 UI — 紧凑胶囊播放器，靠右显示
@pragma("vm:entry-point")
void overlayEntry() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OverlayWidget(),
  ));
}

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key});

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  bool _isPlaying = true;
  String _stationName = 'Lofi Radio';

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((data) {
      if (data is Map) {
        setState(() {
          if (data.containsKey('playing')) _isPlaying = data['playing'] as bool;
          if (data.containsKey('station')) _stationName = data['station'] as String;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xE61E2A3B), Color(0xF20F1729)],
                  ),
                  border: Border.all(color: const Color(0x2694A3B8), width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 播放/暂停
                    _btn(
                      icon: _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      onTap: _doTogglePlay,
                      accent: true,
                    ),
                    const SizedBox(width: 6),
                    // 电台名
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 80),
                      child: Text(
                        _stationName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xCCF8FAFC),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 下一首
                    _btn(icon: Icons.skip_next_rounded, onTap: _doNext),
                    const SizedBox(width: 2),
                    // 关闭
                    _btn(icon: Icons.close_rounded, onTap: _doClose),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _btn({required IconData icon, required VoidCallback onTap, bool accent = false}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent
              ? const Color(0xFFFFDAB9).withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
        ),
        child: Icon(
          icon,
          size: 14,
          color: accent ? const Color(0xFFFFDAB9) : const Color(0x99F1F5F9),
        ),
      ),
    );
  }

  void _doTogglePlay() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('overlay_action', 'togglePlay');
    await prefs.setInt('overlay_action_ts', DateTime.now().millisecondsSinceEpoch);
    setState(() => _isPlaying = !_isPlaying);
  }

  void _doNext() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('overlay_action', 'next');
    await prefs.setInt('overlay_action_ts', DateTime.now().millisecondsSinceEpoch);
  }

  void _doClose() {
    FlutterOverlayWindow.closeOverlay();
  }
}
