import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import '../../services/accessibility_service.dart';
import '../../utils/CustomTheme.dart';

/// Accessibility Settings Screen for User Customization
class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends State<AccessibilitySettingsScreen> {
  final AccessibilityService _accessibilityService = AccessibilityService();

  bool _screenReaderEnabled = false;
  bool _highContrastEnabled = false;
  bool _largeTextEnabled = false;
  bool _reducedMotionEnabled = false;
  bool _voiceAnnouncementsEnabled = true;
  double _textScaleFactor = 1.0;
  double _buttonSizeMultiplier = 1.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
    _accessibilityService.announceScreenChange('Accessibility Settings');
  }

  void _loadCurrentSettings() {
    setState(() {
      _screenReaderEnabled = _accessibilityService.screenReaderEnabled;
      _highContrastEnabled = _accessibilityService.highContrastEnabled;
      _largeTextEnabled = _accessibilityService.largeTextEnabled;
      _reducedMotionEnabled = _accessibilityService.reducedMotionEnabled;
      _voiceAnnouncementsEnabled =
          _accessibilityService.voiceAnnouncementsEnabled;
      _textScaleFactor = _accessibilityService.textScaleFactor;
      _buttonSizeMultiplier = _accessibilityService.buttonSizeMultiplier;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _highContrastEnabled ? Colors.black : CustomTheme.background,
      appBar: AppBar(
        backgroundColor:
            _highContrastEnabled ? Colors.black : CustomTheme.cardDark,
        elevation: 0,
        title: FxText.titleLarge(
          'Accessibility',
          color: _accessibilityService.getContrastColor(
            Colors.white,
            CustomTheme.background,
          ),
          fontWeight: 600,
        ).withSemantics(label: 'Accessibility Settings', isHeader: true),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: _accessibilityService.getContrastColor(
              Colors.white,
              CustomTheme.background,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ).withSemantics(
          label: 'Back button',
          hint: 'Double tap to go back to previous screen',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    _highContrastEnabled
                        ? Colors.white.withValues(alpha: 0.1)
                        : CustomTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    _highContrastEnabled
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.accessibility,
                    color: _accessibilityService.getContrastColor(
                      CustomTheme.primary,
                      CustomTheme.background,
                    ),
                    size: 32,
                  ).withSemantics(label: 'Accessibility icon'),
                  const SizedBox(height: 12),
                  FxText.titleMedium(
                    'Make Lovebirds work better for you',
                    color: _accessibilityService.getContrastColor(
                      Colors.white,
                      CustomTheme.background,
                    ),
                    fontWeight: 600,
                  ).withSemantics(
                    label: 'Make Lovebirds work better for you',
                    isHeader: true,
                  ),
                  const SizedBox(height: 8),
                  FxText.bodyMedium(
                    'Customize accessibility features to enhance your dating experience',
                    color: _accessibilityService.getContrastColor(
                      Colors.white70,
                      CustomTheme.background,
                    ),
                    height: 1.4,
                  ).withSemantics(
                    label:
                        'Customize accessibility features to enhance your dating experience',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Visual Settings Section
            _buildSection(
              'Visual Settings',
              'Adjust visual appearance for better visibility',
              [
                _buildToggleSetting(
                  title: 'High Contrast',
                  description: 'Increase contrast for better text readability',
                  value: _highContrastEnabled,
                  onChanged: (value) async {
                    setState(() => _highContrastEnabled = value);
                    await _accessibilityService.setHighContrast(value);
                  },
                  semanticLabel: 'High contrast mode',
                  semanticHint:
                      'Toggle to increase contrast for better readability',
                ),
                _buildToggleSetting(
                  title: 'Large Text',
                  description: 'Increase text size throughout the app',
                  value: _largeTextEnabled,
                  onChanged: (value) async {
                    setState(() => _largeTextEnabled = value);
                    await _accessibilityService.setLargeText(value);
                  },
                  semanticLabel: 'Large text mode',
                  semanticHint: 'Toggle to increase text size',
                ),
                _buildSliderSetting(
                  title: 'Text Size',
                  description: 'Adjust text size from 80% to 200%',
                  value: _textScaleFactor,
                  min: 0.8,
                  max: 2.0,
                  divisions: 12,
                  onChanged: (value) async {
                    setState(() => _textScaleFactor = value);
                    await _accessibilityService.setTextScaleFactor(value);
                  },
                  semanticLabel: 'Text size adjustment',
                  semanticHint: 'Slide to adjust text size from 80% to 200%',
                ),
                _buildSliderSetting(
                  title: 'Button Size',
                  description: 'Make buttons larger for easier tapping',
                  value: _buttonSizeMultiplier,
                  min: 1.0,
                  max: 1.5,
                  divisions: 5,
                  onChanged: (value) async {
                    setState(() => _buttonSizeMultiplier = value);
                    await _accessibilityService.setButtonSizeMultiplier(value);
                  },
                  semanticLabel: 'Button size adjustment',
                  semanticHint:
                      'Slide to make buttons larger for easier tapping',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Motion Settings Section
            _buildSection(
              'Motion Settings',
              'Control animations and motion effects',
              [
                _buildToggleSetting(
                  title: 'Reduced Motion',
                  description: 'Minimize animations and motion effects',
                  value: _reducedMotionEnabled,
                  onChanged: (value) async {
                    setState(() => _reducedMotionEnabled = value);
                    await _accessibilityService.setReducedMotion(value);
                  },
                  semanticLabel: 'Reduced motion mode',
                  semanticHint:
                      'Toggle to minimize animations and motion effects',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Screen Reader Settings Section
            _buildSection(
              'Screen Reader Support',
              'Enable features for screen reader users',
              [
                _buildToggleSetting(
                  title: 'Screen Reader Support',
                  description: 'Optimize interface for screen readers',
                  value: _screenReaderEnabled,
                  onChanged: (value) async {
                    setState(() => _screenReaderEnabled = value);
                    await _accessibilityService.setScreenReader(value);
                  },
                  semanticLabel: 'Screen reader support',
                  semanticHint:
                      'Toggle to optimize interface for screen readers',
                ),
                _buildToggleSetting(
                  title: 'Voice Announcements',
                  description: 'Hear audio feedback for actions',
                  value: _voiceAnnouncementsEnabled,
                  onChanged: (value) async {
                    setState(() => _voiceAnnouncementsEnabled = value);
                    await _accessibilityService.setVoiceAnnouncements(value);
                  },
                  semanticLabel: 'Voice announcements',
                  semanticHint: 'Toggle to hear audio feedback for actions',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Reset button
            Center(
              child: GestureDetector(
                onTap: () async {
                  await _accessibilityService.resetToDefaults();
                  _loadCurrentSettings();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _highContrastEnabled
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                    border:
                        _highContrastEnabled
                            ? Border.all(color: Colors.white, width: 2)
                            : Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        color: _highContrastEnabled ? Colors.white : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      FxText.bodyMedium(
                        'Reset to Defaults',
                        color: _highContrastEnabled ? Colors.white : Colors.red,
                        fontWeight: 600,
                      ),
                    ],
                  ),
                ),
              ).withSemantics(
                label: 'Reset accessibility settings to defaults',
                hint:
                    'Double tap to reset all accessibility settings to their default values',
                isButton: true,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String description,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FxText.titleMedium(
          title,
          color: _accessibilityService.getContrastColor(
            Colors.white,
            CustomTheme.background,
          ),
          fontWeight: 600,
        ).withSemantics(label: title, isHeader: true),
        const SizedBox(height: 4),
        FxText.bodySmall(
          description,
          color: _accessibilityService.getContrastColor(
            Colors.white60,
            CustomTheme.background,
          ),
        ).withSemantics(label: description),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildToggleSetting({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    required String semanticLabel,
    required String semanticHint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            _highContrastEnabled
                ? Colors.white.withValues(alpha: 0.05)
                : CustomTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border:
            _highContrastEnabled
                ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1)
                : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.bodyLarge(
                  title,
                  color: _accessibilityService.getContrastColor(
                    Colors.white,
                    CustomTheme.background,
                  ),
                  fontWeight: 600,
                ).withSemantics(label: title),
                const SizedBox(height: 4),
                FxText.bodySmall(
                  description,
                  color: _accessibilityService.getContrastColor(
                    Colors.white70,
                    CustomTheme.background,
                  ),
                  height: 1.3,
                ).withSemantics(label: description),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor:
                _highContrastEnabled ? Colors.white : CustomTheme.primary,
            inactiveThumbColor: _highContrastEnabled ? Colors.grey[300] : null,
          ).withSemantics(
            label: semanticLabel,
            hint: semanticHint,
            value: value ? 'On' : 'Off',
          ),
        ],
      ),
    ).withSemantics(
      label: '$semanticLabel. Currently ${value ? 'enabled' : 'disabled'}',
      hint: semanticHint,
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required String description,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String semanticLabel,
    required String semanticHint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            _highContrastEnabled
                ? Colors.white.withValues(alpha: 0.05)
                : CustomTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border:
            _highContrastEnabled
                ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1)
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FxText.bodyLarge(
                      title,
                      color: _accessibilityService.getContrastColor(
                        Colors.white,
                        CustomTheme.background,
                      ),
                      fontWeight: 600,
                    ).withSemantics(label: title),
                    const SizedBox(height: 4),
                    FxText.bodySmall(
                      description,
                      color: _accessibilityService.getContrastColor(
                        Colors.white70,
                        CustomTheme.background,
                      ),
                      height: 1.3,
                    ).withSemantics(label: description),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      _highContrastEnabled
                          ? Colors.white.withValues(alpha: 0.1)
                          : CustomTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FxText.bodySmall(
                  '${(value * 100).round()}%',
                  color: _accessibilityService.getContrastColor(
                    _highContrastEnabled ? Colors.white : CustomTheme.primary,
                    CustomTheme.background,
                  ),
                  fontWeight: 600,
                ).withSemantics(
                  label: 'Current value: ${(value * 100).round()} percent',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor:
                  _highContrastEnabled ? Colors.white : CustomTheme.primary,
              inactiveTrackColor:
                  _highContrastEnabled
                      ? Colors.white30
                      : CustomTheme.primary.withValues(alpha: 0.3),
              thumbColor:
                  _highContrastEnabled ? Colors.white : CustomTheme.primary,
              overlayColor: (_highContrastEnabled
                      ? Colors.white
                      : CustomTheme.primary)
                  .withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ).withSemantics(
              label: semanticLabel,
              hint: semanticHint,
              value: '${(value * 100).round()} percent',
            ),
          ),
        ],
      ),
    );
  }
}
