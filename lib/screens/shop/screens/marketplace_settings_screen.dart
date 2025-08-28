import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';

import '../../../utils/AppConfig.dart';
import '../../../utils/CustomTheme.dart';
import '../../../utils/Utilities.dart';

class MarketplaceSettingsScreen extends StatefulWidget {
  const MarketplaceSettingsScreen({Key? key}) : super(key: key);

  @override
  _MarketplaceSettingsScreenState createState() =>
      _MarketplaceSettingsScreenState();
}

class _MarketplaceSettingsScreenState extends State<MarketplaceSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _orderUpdates = true;
  bool _promotionalEmails = false;
  bool _darkMode = true;
  String _language = 'English';
  String _currency = 'CAD';

  final List<String> _languages = ['English', 'French', 'Spanish'];
  final List<String> _currencies = ['CAD', 'USD', 'EUR'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationSettings(),
            const SizedBox(height: 32),
            _buildAppSettings(),
            const SizedBox(height: 32),
            _buildPrivacySettings(),
            const SizedBox(height: 32),
            _buildAccountSettings(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: CustomTheme.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(FeatherIcons.arrowLeft, color: CustomTheme.accent),
        onPressed: () => Navigator.pop(context),
      ),
      title: FxText.titleLarge(
        '${AppConfig.MARKETPLACE_NAME} Settings',
        color: CustomTheme.color,
        fontWeight: 700,
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSection(
      title: 'Notifications',
      icon: FeatherIcons.bell,
      children: [
        _buildSwitchTile(
          title: 'Push Notifications',
          subtitle: 'Receive notifications on your device',
          value: _pushNotifications,
          onChanged: (value) => setState(() => _pushNotifications = value),
        ),
        _buildSwitchTile(
          title: 'Email Notifications',
          subtitle: 'Receive updates via email',
          value: _emailNotifications,
          onChanged: (value) => setState(() => _emailNotifications = value),
        ),
        _buildSwitchTile(
          title: 'SMS Notifications',
          subtitle: 'Receive text messages for important updates',
          value: _smsNotifications,
          onChanged: (value) => setState(() => _smsNotifications = value),
        ),
        _buildSwitchTile(
          title: 'Order Updates',
          subtitle: 'Get notified about order status changes',
          value: _orderUpdates,
          onChanged: (value) => setState(() => _orderUpdates = value),
        ),
        _buildSwitchTile(
          title: 'Promotional Emails',
          subtitle: 'Receive offers and deals',
          value: _promotionalEmails,
          onChanged: (value) => setState(() => _promotionalEmails = value),
        ),
      ],
    );
  }

  Widget _buildAppSettings() {
    return _buildSection(
      title: 'App Settings',
      icon: FeatherIcons.smartphone,
      children: [
        _buildSwitchTile(
          title: 'Dark Mode',
          subtitle: 'Use dark theme throughout the app',
          value: _darkMode,
          onChanged: (value) {
            setState(() => _darkMode = value);
            // TODO: Implement theme switching
            Utils.toast('Theme switching coming soon!');
          },
        ),
        _buildSelectTile(
          title: 'Language',
          subtitle: 'Choose your preferred language',
          value: _language,
          options: _languages,
          onChanged: (value) {
            setState(() => _language = value);
            Utils.toast('Language switching coming soon!');
          },
        ),
        _buildSelectTile(
          title: 'Currency',
          subtitle: 'Display prices in your preferred currency',
          value: _currency,
          options: _currencies,
          onChanged: (value) {
            setState(() => _currency = value);
            Utils.toast('Currency switching coming soon!');
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return _buildSection(
      title: 'Privacy & Security',
      icon: FeatherIcons.shield,
      children: [
        _buildActionTile(
          title: 'Change Password',
          subtitle: 'Update your account password',
          icon: FeatherIcons.lock,
          onTap: () => Utils.toast('Password change coming soon!'),
        ),
        _buildActionTile(
          title: 'Two-Factor Authentication',
          subtitle: 'Add an extra layer of security',
          icon: FeatherIcons.shield,
          onTap: () => Utils.toast('2FA setup coming soon!'),
        ),
        _buildActionTile(
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          icon: FeatherIcons.fileText,
          onTap: () => Utils.toast('Privacy policy coming soon!'),
        ),
        _buildActionTile(
          title: 'Data Export',
          subtitle: 'Download your account data',
          icon: FeatherIcons.download,
          onTap: () => Utils.toast('Data export coming soon!'),
        ),
      ],
    );
  }

  Widget _buildAccountSettings() {
    return _buildSection(
      title: 'Account',
      icon: FeatherIcons.user,
      children: [
        _buildActionTile(
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          icon: FeatherIcons.trash2,
          onTap: _showDeleteAccountDialog,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CustomTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: CustomTheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            FxText.titleMedium(
              title,
              fontWeight: 700,
              color: CustomTheme.colorLight,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: CustomTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CustomTheme.color4),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CustomTheme.color4, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.bodyLarge(
                  title,
                  fontWeight: 600,
                  color: CustomTheme.colorLight,
                ),
                const SizedBox(height: 4),
                FxText.bodySmall(
                  subtitle,
                  color: CustomTheme.color3,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: CustomTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showSelectDialog(title, options, value, onChanged),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: CustomTheme.color4, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FxText.bodyLarge(
                      title,
                      fontWeight: 600,
                      color: CustomTheme.colorLight,
                    ),
                    const SizedBox(height: 4),
                    FxText.bodySmall(
                      subtitle,
                      color: CustomTheme.color3,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FxText.bodyMedium(
                    value,
                    color: CustomTheme.primary,
                    fontWeight: 600,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    FeatherIcons.chevronRight,
                    color: CustomTheme.color3,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: CustomTheme.color4, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      isDestructive
                          ? Colors.red.withValues(alpha: 0.1)
                          : CustomTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? Colors.red : CustomTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FxText.bodyLarge(
                      title,
                      fontWeight: 600,
                      color:
                          isDestructive ? Colors.red : CustomTheme.colorLight,
                    ),
                    const SizedBox(height: 4),
                    FxText.bodySmall(
                      subtitle,
                      color: CustomTheme.color3,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Icon(
                FeatherIcons.chevronRight,
                color: CustomTheme.color3,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSelectDialog(
    String title,
    List<String> options,
    String currentValue,
    ValueChanged<String> onChanged,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: CustomTheme.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: FxText.titleMedium(
              title,
              color: CustomTheme.colorLight,
              fontWeight: 700,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  options.map((option) {
                    return RadioListTile<String>(
                      title: FxText.bodyMedium(
                        option,
                        color: CustomTheme.color,
                      ),
                      value: option,
                      groupValue: currentValue,
                      activeColor: CustomTheme.primary,
                      onChanged: (value) {
                        if (value != null) {
                          onChanged(value);
                          Navigator.pop(context);
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: CustomTheme.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: FxText.titleMedium(
              'Delete Account',
              color: Colors.red,
              fontWeight: 700,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.bodyMedium(
                  'Are you sure you want to delete your account? This action cannot be undone.',
                  color: CustomTheme.color,
                ),
                const SizedBox(height: 16),
                FxText.bodySmall(
                  'All your data including:',
                  color: CustomTheme.color3,
                  fontWeight: 600,
                ),
                const SizedBox(height: 8),
                ...[
                  'Order history',
                  'Personal information',
                  'Saved addresses',
                  'Payment methods',
                ].map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Row(
                      children: [
                        Icon(FeatherIcons.minus, color: Colors.red, size: 12),
                        const SizedBox(width: 8),
                        FxText.bodySmall(item, color: CustomTheme.color3),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FxText.bodySmall(
                  'will be permanently deleted.',
                  color: Colors.red,
                  fontWeight: 600,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: FxText.bodyMedium('Cancel', color: CustomTheme.color3),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Utils.toast('Account deletion coming soon!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: FxText.bodyMedium('Delete Account', fontWeight: 600),
              ),
            ],
          ),
    );
  }
}
