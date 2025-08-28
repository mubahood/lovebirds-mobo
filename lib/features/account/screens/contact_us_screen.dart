import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx/flutx.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/CustomTheme.dart';
import '../../../utils/Utilities.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: FxText.titleLarge('Contact Us', color: Colors.white),
        backgroundColor: CustomTheme.primary,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: CustomTheme.primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      backgroundColor: CustomTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Card(
              color: Colors.blue[50],
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.support_agent,
                      color: Colors.blue[700],
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    FxText.titleLarge(
                      'We\'re Here to Help',
                      fontWeight: 700,
                      color: Colors.blue[800],
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FxText.bodyMedium(
                      'Have questions, feedback, or need assistance? We\'d love to hear from you!',
                      color: Colors.blue[700],
                      textAlign: TextAlign.center,
                      height: 1.5,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Contact Methods
            _buildContactMethod(
              icon: Icons.email,
              title: 'Email Support',
              subtitle: 'Send us an email',
              description: 'ugflixtranslatedmovies@gmail.com',
              color: Colors.blue,
              onTap: () => _launchEmail('ugflixtranslatedmovies@gmail.com'),
            ),

            _buildContactMethod(
              icon: Icons.phone,
              title: 'Phone Support',
              subtitle: 'Call us during business hours',
              description: '+1 (647) 968-6445',
              color: Colors.green,
              onTap: () => _launchPhone('+1 (647) 968-6445'),
            ),

            _buildContactMethod(
              icon: Icons.chat,
              title: 'WhatsApp',
              subtitle: 'Chat with us on WhatsApp',
              description: '+1 (647) 968-6445',
              color: Colors.green[600]!,
              onTap: () => _launchWhatsApp('+1 (647) 968-6445'),
            ),

            _buildContactMethod(
              icon: Icons.location_on,
              title: 'Visit Our Office',
              subtitle: 'Come see us in person',
              description: 'Kampala, Uganda\nPlot 4321, Buganda Road',
              color: Colors.red,
              onTap: () => _launchMaps(),
            ),

            const SizedBox(height: 24),

            // Business Hours
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: CustomTheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        FxText.titleMedium(
                          'Business Hours',
                          fontWeight: 700,
                          color: CustomTheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildBusinessHour('Monday - Friday', '8:00 AM - 6:00 PM'),
                    _buildBusinessHour('Saturday', '9:00 AM - 4:00 PM'),
                    _buildBusinessHour('Sunday', 'Closed'),

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber[700],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FxText.bodySmall(
                              'Response time: Within 24 hours',
                              color: Colors.amber[700],
                              fontWeight: 600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // FAQ Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: CustomTheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        FxText.titleMedium(
                          'Quick Help',
                          fontWeight: 700,
                          color: CustomTheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    FxText.bodySmall(
                      'Common questions we can help with:\n\n'
                      '• Account setup and login issues\n'
                      '• Download and streaming problems\n'
                      '• Payment and subscription questions\n'
                      '• Content reporting and moderation\n'
                      '• Technical support and bug reports\n'
                      '• Feature requests and feedback\n'
                      '• Privacy and data protection inquiries',
                      color: Colors.grey[600],
                      height: 1.8,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Social Media
            Card(
              color: Colors.purple[50],
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.share, color: Colors.purple[700], size: 24),
                        const SizedBox(width: 12),
                        FxText.titleMedium(
                          'Follow Us',
                          fontWeight: 700,
                          color: Colors.purple[800],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    FxText.bodySmall(
                      'Stay updated with the latest movies and news:\n\n'
                      '• Facebook: @UGFlixUganda\n'
                      '• Twitter: @UGFlix_UG\n'
                      '• Instagram: @ugflix_official\n'
                      '• YouTube: UGFlix Uganda',
                      color: Colors.purple[700],
                      height: 1.8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FxText.titleSmall(
                      title,
                      fontWeight: 700,
                      color: Colors.grey[800],
                    ),
                    const SizedBox(height: 4),
                    FxText.bodySmall(subtitle, color: Colors.grey[600]),
                    const SizedBox(height: 8),
                    FxText.bodyMedium(
                      description,
                      fontWeight: 600,
                      color: color,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessHour(String day, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FxText.bodyMedium(day, color: Colors.grey[700], fontWeight: 500),
          FxText.bodyMedium(time, color: Colors.grey[800], fontWeight: 600),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=UGFlix Support Request',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        Utils.toast('Email app not available');
      }
    } catch (e) {
      Utils.toast('Could not open email app');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Utils.toast('Phone app not available');
      }
    } catch (e) {
      Utils.toast('Could not make phone call');
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phone');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        Utils.toast('WhatsApp not available');
      }
    } catch (e) {
      Utils.toast('Could not open WhatsApp');
    }
  }

  Future<void> _launchMaps() async {
    final Uri mapsUri = Uri.parse('https://maps.google.com/?q=Kampala,Uganda');

    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        Utils.toast('Maps app not available');
      }
    } catch (e) {
      Utils.toast('Could not open maps');
    }
  }
}
