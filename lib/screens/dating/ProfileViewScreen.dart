import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// Import moderation dialogs
import '../../features/moderation/widgets/block_user_dialog.dart';
import '../../features/moderation/widgets/report_content_dialog.dart';
import '../../models/UserModel.dart';
// Import multi-photo gallery
import '../../widgets/dating/multi_photo_gallery.dart';
import '../shop/screens/shop/chat/chat_screen.dart';

class ProfileViewScreen extends StatefulWidget {
  final UserModel user;

  const ProfileViewScreen(this.user, {Key? key}) : super(key: key);

  @override
  _ProfileViewScreenState createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late AnimationController _heroController;
  late Animation<double> _fabAnimation;
  late Animation<double> _heroAnimation;
  late ScrollController _scrollController;
  bool _isScrolled = false;

  // Enhanced user with dummy data
  late UserModel enhancedUser;

  @override
  void initState() {
    super.initState();

    // Enhance user with comprehensive dummy data
    enhancedUser = _enhanceUserWithDummyData(widget.user);

    _fabController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _heroController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeInOut,
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Start animations
    Future.delayed(Duration(milliseconds: 300), () {
      _fabController.forward();
      _heroController.forward();
    });
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 100 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _fabController.dispose();
    _heroController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Enhance user with comprehensive dummy data for testing
  UserModel _enhanceUserWithDummyData(UserModel originalUser) {
    final enhanced = UserModel();

    // Copy all original user data
    enhanced.id = originalUser.id;
    enhanced.name =
        originalUser.name.isNotEmpty ? originalUser.name : 'Alex Johnson';
    enhanced.first_name =
        originalUser.first_name.isNotEmpty ? originalUser.first_name : 'Alex';
    enhanced.last_name =
        originalUser.last_name.isNotEmpty ? originalUser.last_name : 'Johnson';
    enhanced.avatar = originalUser.avatar;
    enhanced.profile_photos = originalUser.profile_photos;
    enhanced.email = originalUser.email;
    enhanced.phone_number = originalUser.phone_number;

    // Enhanced bio
    enhanced.bio =
        originalUser.bio.isNotEmpty
            ? originalUser.bio
            : 'Adventure seeker and coffee lover ☕️ Looking for someone to explore the world with! Love hiking, photography, and trying new cuisines. Let\'s create amazing memories together! 🌟';

    // Enhanced tagline
    enhanced.tagline =
        originalUser.tagline.isNotEmpty
            ? originalUser.tagline
            : 'Live, Love, Laugh 💫';

    // Age and DOB
    enhanced.dob =
        originalUser.dob.isNotEmpty ? originalUser.dob : '1996-03-15';
    enhanced.sex = originalUser.sex.isNotEmpty ? originalUser.sex : 'Male';

    // Location data
    enhanced.city =
        originalUser.city.isNotEmpty ? originalUser.city : 'New York';
    enhanced.state = originalUser.state.isNotEmpty ? originalUser.state : 'NY';
    enhanced.country =
        originalUser.country.isNotEmpty ? originalUser.country : 'USA';

    // Physical attributes
    enhanced.height_cm =
        originalUser.height_cm.isNotEmpty ? originalUser.height_cm : '175';
    enhanced.body_type =
        originalUser.body_type.isNotEmpty ? originalUser.body_type : 'Athletic';
    enhanced.sexual_orientation =
        originalUser.sexual_orientation.isNotEmpty
            ? originalUser.sexual_orientation
            : 'Straight';

    // Education & Career
    enhanced.education_level =
        originalUser.education_level.isNotEmpty
            ? originalUser.education_level
            : 'Bachelor\'s Degree';
    enhanced.occupation =
        originalUser.occupation.isNotEmpty
            ? originalUser.occupation
            : 'Software Engineer';

    // Dating preferences
    enhanced.looking_for =
        originalUser.looking_for.isNotEmpty
            ? originalUser.looking_for
            : 'Long-term relationship';
    enhanced.interested_in =
        originalUser.interested_in.isNotEmpty
            ? originalUser.interested_in
            : 'Women';
    enhanced.age_range_min =
        originalUser.age_range_min.isNotEmpty
            ? originalUser.age_range_min
            : '22';
    enhanced.age_range_max =
        originalUser.age_range_max.isNotEmpty
            ? originalUser.age_range_max
            : '32';

    // Lifestyle preferences
    enhanced.smoking_habit =
        originalUser.smoking_habit.isNotEmpty
            ? originalUser.smoking_habit
            : 'Never';
    enhanced.drinking_habit =
        originalUser.drinking_habit.isNotEmpty
            ? originalUser.drinking_habit
            : 'Socially';
    enhanced.pet_preference =
        originalUser.pet_preference.isNotEmpty
            ? originalUser.pet_preference
            : 'Love Dogs';
    enhanced.religion =
        originalUser.religion.isNotEmpty ? originalUser.religion : 'Christian';
    enhanced.political_views =
        originalUser.political_views.isNotEmpty
            ? originalUser.political_views
            : 'Moderate';

    // Languages - provide comma-separated string for compatibility
    enhanced.languages_spoken =
        originalUser.languages_spoken.isNotEmpty
            ? originalUser.languages_spoken
            : 'English, Spanish, French';

    // Online status
    enhanced.online_status = 'online';
    enhanced.last_online_at = DateTime.now().toString();

    return enhanced;
  }

  /// Helper method to parse languages safely
  List<String> _parseLanguages(String languagesData) {
    if (languagesData.isEmpty) return [];

    // Parse as comma-separated string (simple and reliable)
    return languagesData
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFF0a0a1a),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 2.0,
                colors: [
                  Colors.red.withOpacity(0.1),
                  Color(0xFF0a0a1a),
                  Colors.black,
                ],
              ),
            ),
          ),
          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildModernAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildHeroSection(),
                    _buildPersonalInfoCards(),
                    _buildAboutSection(),
                    _buildLifestyleGrid(),
                    _buildInterestsSection(),
                    _buildCompatibilitySection(),
                    SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
          // Floating action buttons
          _buildFloatingActionButtons(),
          // Modern app bar overlay
          _buildAppBarOverlay(),
        ],
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 450,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.back();
          },
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(25),
          ),
          child: PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, color: Colors.white),
            color: Color(0xFF1a1a2e),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            onSelected: (value) => _handleMenuAction(value, context),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'report',
                    child: _buildMenuOption(
                      Icons.flag,
                      'Report User',
                      Colors.orange,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'block',
                    child: _buildMenuOption(
                      Icons.block,
                      'Block User',
                      Colors.red,
                    ),
                  ),
                ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Enhanced photo gallery with better transitions
            Hero(
              tag: 'profile_${enhancedUser.id}',
              child: MultiPhotoGallery(
                user: enhancedUser,
                height: 450,
                showIndicators: true,
                allowSwipe: true,
              ),
            ),
            // Premium gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
            // Profile name overlay
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: FadeTransition(
                opacity: _heroAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            enhancedUser.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (enhancedUser.isOnline) _buildOnlineIndicator(),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_calculateAge(enhancedUser.dob)} years old',
                      style: TextStyle(
                        color: Colors.yellow.shade400,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (enhancedUser.tagline.isNotEmpty) ...[
                      SizedBox(height: 6),
                      Text(
                        enhancedUser.tagline,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String value, BuildContext context) {
    switch (value) {
      case 'report':
        showDialog(
          context: context,
          builder:
              (context) => ReportContentDialog(
                contentType: 'User',
                contentPreview: enhancedUser.name,
                contentId: enhancedUser.id.toString(),
                reportedUserId: enhancedUser.id.toString(),
              ),
        );
        break;
      case 'block':
        showDialog(
          context: context,
          builder:
              (context) => BlockUserDialog(
                userName: enhancedUser.name,
                userId: enhancedUser.id.toString(),
                userAvatar: enhancedUser.avatar,
              ),
        );
        break;
    }
  }

  Widget _buildMenuOption(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      transform: Matrix4.translationValues(0, 10, 0),
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 20),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.withOpacity(0.2),
              Colors.redAccent.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.yellow.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.yellow.shade400,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    enhancedUser.city.isNotEmpty
                        ? enhancedUser.city
                        : 'Location private',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (enhancedUser.bio.isNotEmpty) ...[
              Text(
                'About ${enhancedUser.name}',
                style: TextStyle(
                  color: Colors.yellow.shade400,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                enhancedUser.bio,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityBadge() {
    // Calculate compatibility score based on user data
    int compatibilityScore = _calculateCompatibilityScore();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow, Colors.yellow.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCards() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Facts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  Icons.cake,
                  'Age',
                  '${_calculateAge(enhancedUser.dob)}',
                  Colors.pink,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildInfoCard(
                  enhancedUser.sex == 'male' ? Icons.male : Icons.female,
                  'Gender',
                  enhancedUser.sex.capitalizeFirst ?? '',
                  Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  Icons.height,
                  'Height',
                  enhancedUser.height_cm.isNotEmpty
                      ? '${enhancedUser.height_cm} cm'
                      : 'Not set',
                  Colors.green,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildInfoCard(
                  Icons.work,
                  'Work',
                  enhancedUser.occupation.isNotEmpty
                      ? enhancedUser.occupation
                      : 'Not set',
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12), // Reduced from 16
      decoration: BoxDecoration(
        color: Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12), // Reduced from 16
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 6, // Reduced from 8
            offset: Offset(0, 3), // Reduced from 4
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Added to prevent overflow
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6), // Reduced from 8
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8), // Reduced from 10
                ),
                child: Icon(icon, color: color, size: 18), // Reduced from 20
              ),
              SizedBox(width: 6), // Reduced from 8
              Expanded(
                // Changed to Expanded to prevent overflow
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11, // Reduced from 12
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6), // Reduced from 8
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14, // Reduced from 16
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Education & Career',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12),
          _buildDetailCard(
            Icons.school,
            'Education',
            enhancedUser.education_level.isNotEmpty
                ? enhancedUser.education_level
                : 'Not specified',
            Colors.blue,
          ),
          SizedBox(height: 8),
          _buildDetailCard(
            Icons.work_outline,
            'Looking For',
            enhancedUser.looking_for.isNotEmpty
                ? enhancedUser.looking_for
                : 'Not specified',
            Colors.purple,
          ),
          SizedBox(height: 8),
          _buildDetailCard(
            Icons.favorite_outline,
            'Interested In',
            enhancedUser.interested_in.isNotEmpty
                ? enhancedUser.interested_in
                : 'Not specified',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12), // Reduced from 16
      decoration: BoxDecoration(
        color: Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12), // Reduced from 16
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 6, // Reduced from 8
            offset: Offset(0, 3), // Reduced from 4
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8), // Reduced from 10
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10), // Reduced from 12
            ),
            child: Icon(icon, color: color, size: 20), // Reduced from 24
          ),
          SizedBox(width: 12), // Reduced from 16
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Added to prevent overflow
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12, // Reduced from 14
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3), // Reduced from 4
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14, // Reduced from 16
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2, // Added to prevent overflow
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleGrid() {
    final lifestyle = [
      {'icon': '🚭', 'title': 'Smoking', 'value': enhancedUser.smoking_habit},
      {'icon': '🍷', 'title': 'Drinking', 'value': enhancedUser.drinking_habit},
      {'icon': '🐾', 'title': 'Pets', 'value': enhancedUser.pet_preference},
      {'icon': '🙏', 'title': 'Religion', 'value': enhancedUser.religion},
      {
        'icon': '🗳️',
        'title': 'Politics',
        'value': enhancedUser.political_views,
      },
      {'icon': '🏋️', 'title': 'Body Type', 'value': enhancedUser.body_type},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'Lifestyle',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),

          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3.0, // Increased from 2.5 to give more height
            ),
            itemCount: lifestyle.length,
            itemBuilder: (context, index) {
              final item = lifestyle[index];
              return _buildLifestyleCard(
                item['icon']!,
                item['title']!,
                item['value']!.isNotEmpty ? item['value']! : 'Not set',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleCard(String emoji, String title, String value) {
    return Container(
      padding: EdgeInsets.all(5), // Reduced from 12 to 8
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.1),
            Colors.redAccent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12), // Reduced from 16
        border: Border.all(color: Colors.yellow.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Added to prevent overflow
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: TextStyle(fontSize: 15, height: 1),
              ), // Reduced from 20
              SizedBox(width: 6), // Reduced from 8
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.yellow.shade400,
                    fontSize: 11, // Reduced from 12
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 2), // Reduced from 4
          Flexible(
            // Changed from regular Text to Flexible
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12, // Reduced from 14
                fontWeight: FontWeight.w500,
                height: 1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    // Parse languages spoken as interests/skills
    List<String> interests = [];
    if (enhancedUser.languages_spoken.isNotEmpty) {
      interests.addAll(_parseLanguages(enhancedUser.languages_spoken));
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Languages & Skills',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12),
          interests.isNotEmpty
              ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    interests
                        .map((interest) => _buildInterestChip(interest))
                        .toList(),
              )
              : Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1a1a2e),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Text(
                  'No languages specified',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildInterestChip(String interest) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow.shade600, Colors.yellow.shade800],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        interest,
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCompatibilitySection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.red.withOpacity(0.2),
            Colors.redAccent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.yellow.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, color: Colors.red, size: 32),
          SizedBox(height: 8),
          Text(
            'Compatibility Score',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '${_calculateCompatibilityScore()}% Match',
            style: TextStyle(
              color: Colors.yellow.shade400,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Based on shared interests and preferences',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Positioned(
      bottom: 20, // Reduced from 30
      left: 16, // Reduced from 20
      right: 16, // Reduced from 20
      child: ScaleTransition(
        scale: _fabAnimation,
        child: Row(
          children: [
            // Like button
            Expanded(
              flex: 1,
              child: _buildActionButton(
                Icons.favorite,
                'Like',
                LinearGradient(colors: [Colors.red, Colors.redAccent]),
                () => _handleLike(),
              ),
            ),
            SizedBox(width: 8), // Reduced from 12
            // Message button
            Expanded(
              flex: 2,
              child: _buildActionButton(
                Icons.chat_bubble,
                'Send Message',
                LinearGradient(
                  colors: [Colors.yellow.shade600, Colors.yellow.shade800],
                ),
                () => _openChat(),
              ),
            ),
            SizedBox(width: 8), // Reduced from 12
            // Super Like button
            Expanded(
              flex: 1,
              child: _buildActionButton(
                Icons.star,
                'Super',
                LinearGradient(colors: [Colors.purple, Colors.purpleAccent]),
                () => _handleSuperLike(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        onTap();
      },
      child: Container(
        height: 48, // Reduced from 55
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24), // Reduced from 28
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Reduced opacity
              blurRadius: 6, // Reduced blur
              offset: Offset(0, 3), // Reduced offset
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: label == 'Send Message' ? Colors.black : Colors.white,
              size: 18, // Reduced from 22
            ),
            if (label.isNotEmpty) ...[
              SizedBox(width: 6), // Reduced from 8
              Flexible(
                // Added to prevent overflow
                child: Text(
                  label,
                  style: TextStyle(
                    color:
                        label == 'Send Message' ? Colors.black : Colors.white,
                    fontSize: 13, // Reduced from 16
                    fontWeight: FontWeight.w600, // Reduced weight
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleLike() {
    HapticFeedback.mediumImpact();
    Get.snackbar(
      'Liked!',
      'You liked ${enhancedUser.name}',
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(20),
      borderRadius: 10,
    );
  }

  void _handleSuperLike() {
    HapticFeedback.heavyImpact();
    Get.snackbar(
      'Super Liked! ⭐',
      'You super liked ${enhancedUser.name}',
      backgroundColor: Colors.purple.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(20),
      borderRadius: 10,
    );
  }

  void _openChat() {
    HapticFeedback.lightImpact();
    Get.to(
      () => ChatScreen({
        'task': 'START_CHAT',
        'receiver_id': enhancedUser.id.toString(),
        'receiver': enhancedUser,
      }),
      transition: Transition.rightToLeftWithFade,
      duration: Duration(milliseconds: 300),
    );
  }

  // Helper methods
  int _calculateAge(String dob) {
    if (dob.isEmpty) return 25;
    try {
      final birthDate = DateTime.parse(dob);
      final currentDate = DateTime.now();
      int age = currentDate.year - birthDate.year;
      if (currentDate.month < birthDate.month ||
          (currentDate.month == birthDate.month &&
              currentDate.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 25;
    }
  }

  int _calculateCompatibilityScore() {
    int score = 60; // Base compatibility

    // Add points for filled profile fields
    if (enhancedUser.bio.isNotEmpty) score += 10;
    if (enhancedUser.occupation.isNotEmpty) score += 5;
    if (enhancedUser.education_level.isNotEmpty) score += 5;
    if (enhancedUser.height_cm.isNotEmpty) score += 3;
    if (enhancedUser.looking_for.isNotEmpty) score += 5;
    if (enhancedUser.interested_in.isNotEmpty) score += 5;
    if (enhancedUser.languages_spoken.isNotEmpty) score += 7;

    return math.min(score, 99); // Cap at 99%
  }

  Widget _buildOnlineIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            'Online',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarOverlay() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isScrolled ? 100 : 0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
        ),
      ),
    );
  }
}
