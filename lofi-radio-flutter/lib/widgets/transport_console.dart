import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'volume_slider.dart';

class TransportConsole extends StatelessWidget {
  final bool isPlaying;
  final bool compact;
  final double volume;
  final VoidCallback onPrevious;
  final VoidCallback onTogglePlayback;
  final VoidCallback onNext;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onMuteToggle;

  const TransportConsole({
    super.key,
    required this.isPlaying,
    required this.compact,
    required this.volume,
    required this.onPrevious,
    required this.onTogglePlayback,
    required this.onNext,
    required this.onVolumeChanged,
    required this.onMuteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 30 : 36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            compact ? 22 : 24,
            compact ? 26 : 30,
            compact ? 22 : 24,
            compact ? 22 : 24,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 30 : 36),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.028),
                Colors.white.withValues(alpha: 0.02),
                Colors.black.withValues(alpha: 0.06),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _SectionTitle(text: 'TRANSPORT', compact: compact),
              SizedBox(height: compact ? 14 : 16),
              Row(
                children: [
                  Expanded(
                    child: _MoldedButton(
                      compact: compact,
                      icon: Icons.skip_previous_rounded,
                      label: 'PREV',
                      onTap: onPrevious,
                    ),
                  ),
                  SizedBox(width: compact ? 14 : 18),
                  Expanded(
                    child: _MoldedButton(
                      compact: compact,
                      icon: isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      label: isPlaying ? 'PAUSE' : 'PLAY',
                      active: isPlaying,
                      onTap: onTogglePlayback,
                    ),
                  ),
                  SizedBox(width: compact ? 14 : 18),
                  Expanded(
                    child: _MoldedButton(
                      compact: compact,
                      icon: Icons.skip_next_rounded,
                      label: 'NEXT',
                      onTap: onNext,
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 28 : 34),
              VolumeSlider(
                volume: volume,
                compact: compact,
                onChanged: onVolumeChanged,
                onMuteToggle: onMuteToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final bool compact;

  const _SectionTitle({required this.text, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: compact ? 10 : 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.4,
        color: AppColors.textTertiary.withValues(alpha: 0.78),
      ),
    );
  }
}

class _MoldedButton extends StatefulWidget {
  final bool compact;
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _MoldedButton({
    required this.compact,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  State<_MoldedButton> createState() => _MoldedButtonState();
}

class _MoldedButtonState extends State<_MoldedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final height = widget.compact ? 74.0 : 82.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.985 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.active
                  ? [
                      Colors.black.withValues(alpha: 0.18),
                      Colors.black.withValues(alpha: 0.12),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.015),
                      Colors.white.withValues(alpha: 0.006),
                    ],
            ),
            boxShadow: widget.active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.34),
                      blurRadius: 14,
                      offset: const Offset(5, 6),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(-3, -3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 18,
                      offset: const Offset(8, 8),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(-4, -4),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 13,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.active
                          ? AppColors.signalPeak
                          : Colors.white.withValues(alpha: 0.14),
                      boxShadow: widget.active
                          ? [
                              BoxShadow(
                                color: AppColors.signalPeak.withValues(
                                  alpha: 0.7,
                                ),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      size: widget.compact ? 20 : 22,
                      color: widget.active
                          ? AppColors.textPrimary
                          : AppColors.textPrimary.withValues(alpha: 0.55),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: widget.active
                            ? AppColors.textTertiary.withValues(alpha: 0.9)
                            : AppColors.textTertiary.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
