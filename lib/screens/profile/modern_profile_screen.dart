import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/MainController.dart';
import '../../models/UserModel.dart';
import '../../models/RespondModel.dart';
import '../../utils/dating_theme.dart';
import '../../utils/Utilities.dart';
import '../subscription/subscription_selection_screen.dart';
import '../dating/SwipeScreen.dart';

class ModernProfileScreen extends StatefulWidget {
  const ModernProfileScreen({Key? key}) : super(key: key);

  @override
  _ModernProfileScreenState createState() => _ModernProfileScreenState();
}

class _ModernProfileScreenState extends State<ModernProfileScreen> {
  final MainController _mainController = Get.find<MainController>();
  final ImagePicker _imagePicker = ImagePicker();

  List<String> _userPhotos = [];
  List<UserModel> _suggestedProfiles = [];
  List<UserModel> _likedByUsers = [];
  List<UserModel> _likedUsers = [];
  List<UserModel> _matchedUsers = [];
  List<UserModel> _chatUsers = [];
  List<UserModel> _blockedUsers = [];
  List<UserModel> _reportedUsers = [];

  bool _isLoading = true;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      // Load user photos
      await _loadUserPhotos();

      // Load suggested profiles
      await _loadSuggestedProfiles();

      // Load interaction data
      await _loadUserInteractions();
    } catch (e) {
      Utils.toast('Error loading profile data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserPhotos() async {
    try {
      final response = await Utils.http_get('user-photos', {});
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        final photosData = resp.data['photos'] as List? ?? [];
        _userPhotos =
            photosData.map((photo) => photo['url'].toString()).toList();
      }
    } catch (e) {
      print('Error loading photos: $e');
    }
  }

  Future<void> _loadSuggestedProfiles() async {
    try {
      final response = await Utils.http_get('suggested-profiles', {
        'limit': '6',
      });
      final resp = RespondModel(response);

      if (resp.code == 1 && resp.data != null) {
        final profilesData = resp.data['profiles'] as List? ?? [];
        _suggestedProfiles =
            profilesData.map((data) => UserModel.fromJson(data)).toList();
      }
    } catch (e) {
      print('Error loading suggested profiles: $e');
    }
  }

  Future<void> _loadUserInteractions() async {
    try {
      // Load users who liked me
      final likedByResponse = await Utils.http_get('users-who-liked-me', {});
      final likedByResp = RespondModel(likedByResponse);
      if (likedByResp.code == 1 && likedByResp.data != null) {
        final usersData = likedByResp.data['users'] as List? ?? [];
        _likedByUsers =
            usersData.map((data) => UserModel.fromJson(data)).toList();
      }

      // Load users I liked
      final likedResponse = await Utils.http_get('users-i-liked', {});
      final likedResp = RespondModel(likedResponse);
      if (likedResp.code == 1 && likedResp.data != null) {
        final usersData = likedResp.data['users'] as List? ?? [];
        _likedUsers =
            usersData.map((data) => UserModel.fromJson(data)).toList();
      }

      // Load matched users
      final matchedResponse = await Utils.http_get('matched-users', {});
      final matchedResp = RespondModel(matchedResponse);
      if (matchedResp.code == 1 && matchedResp.data != null) {
        final usersData = matchedResp.data['users'] as List? ?? [];
        _matchedUsers =
            usersData.map((data) => UserModel.fromJson(data)).toList();
      }

      // Load chat users
      final chatResponse = await Utils.http_get('chat-users', {});
      final chatResp = RespondModel(chatResponse);
      if (chatResp.code == 1 && chatResp.data != null) {
        final usersData = chatResp.data['users'] as List? ?? [];
        _chatUsers = usersData.map((data) => UserModel.fromJson(data)).toList();
      }
    } catch (e) {
      print('Error loading user interactions: $e');
    }
  }

  Future<void> _addPhoto() async {
    if (_isUploadingPhoto) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _isUploadingPhoto = true);

        // TODO: Upload image to server
        final response = await Utils.http_post('upload-photo', {
          'photo': image.path,
        });

        final resp = RespondModel(response);
        if (resp.code == 1) {
          await _loadUserPhotos(); // Reload photos
          Utils.toast('Photo added successfully!');
        } else {
          Utils.toast('Failed to add photo');
        }
      }
    } catch (e) {
      Utils.toast('Error adding photo: $e');
    } finally {
      setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _deletePhoto(String photoUrl) async {
    try {
      final response = await Utils.http_post('delete-photo', {
        'photo_url': photoUrl,
      });

      final resp = RespondModel(response);
      if (resp.code == 1) {
        await _loadUserPhotos(); // Reload photos
        Utils.toast('Photo deleted successfully!');
      } else {
        Utils.toast('Failed to delete photo');
      }
    } catch (e) {
      Utils.toast('Error deleting photo: $e');
    }
  }

  Future<void> _setAsProfilePhoto(String photoUrl) async {
    try {
      final response = await Utils.http_post('set-profile-photo', {
        'photo_url': photoUrl,
      });

      final resp = RespondModel(response);
      if (resp.code == 1) {
        Utils.toast('Profile photo updated!');
        await _mainController.getLoggedInUser(); // Refresh user data
        setState(() {});
      } else {
        Utils.toast('Failed to update profile photo');
      }
    } catch (e) {
      Utils.toast('Error updating profile photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DatingTheme.background,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildProfileContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: DatingTheme.background,
      elevation: 0,
      title: Text(
        'My Profile',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // Subscription button - simplified as requested
        TextButton(
          onPressed: () => Get.to(() => const SubscriptionSelectionScreen()),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [DatingTheme.primaryPink, DatingTheme.accent],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(DatingTheme.primaryPink),
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          SizedBox(height: 24),
          _buildPhotoGallery(),
          SizedBox(height: 24),
          _buildProfileInfo(),
          SizedBox(height: 24),
          _buildYouMayAlsoLike(),
          SizedBox(height: 24),
          _buildInteractionSections(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = _mainController.loggedInUser;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Profile Picture
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: DatingTheme.primaryPink, width: 2),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: user.avatar,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          color: DatingTheme.darkBackground,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          color: DatingTheme.darkBackground,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: DatingTheme.primaryPink,
                    shape: BoxShape.circle,
                    border: Border.all(color: DatingTheme.background, width: 2),
                  ),
                  child: Icon(Icons.edit, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _editName,
                      icon: Icon(
                        Icons.edit,
                        color: DatingTheme.primaryPink,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${user.age} years old',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  user.bio.isNotEmpty
                      ? user.bio
                      : 'Add a bio to tell people about yourself',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photo Gallery',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _addPhoto,
              icon:
                  _isUploadingPhoto
                      ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: DatingTheme.primaryPink,
                        ),
                      )
                      : Icon(Icons.add, color: DatingTheme.primaryPink),
              label: Text(
                'Add Photo',
                style: TextStyle(color: DatingTheme.primaryPink),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _userPhotos.length + 1, // +1 for add button
            itemBuilder: (context, index) {
              if (index == _userPhotos.length) {
                // Add photo button
                return Container(
                  width: 100,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: DatingTheme.darkBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: DatingTheme.primaryPink.withValues(alpha: 0.5),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: InkWell(
                    onTap: _addPhoto,
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          color: DatingTheme.primaryPink,
                          size: 30,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            color: DatingTheme.primaryPink,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return _buildPhotoItem(_userPhotos[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoItem(String photoUrl) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: photoUrl,
              width: 100,
              height: 120,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: DatingTheme.darkBackground,
                    child: Center(child: CircularProgressIndicator()),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: DatingTheme.darkBackground,
                    child: Icon(Icons.error, color: Colors.white),
                  ),
            ),
          ),
          // Photo actions overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoAction(
                  icon: Icons.star,
                  onTap: () => _setAsProfilePhoto(photoUrl),
                ),
                _buildPhotoAction(
                  icon: Icons.delete,
                  onTap: () => _deletePhoto(photoUrl),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildProfileInfo() {
    final user = _mainController.loggedInUser;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Me',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          _buildInfoRow('Age', '${user.age} years old'),
          _buildInfoRow('Location', user.location),
          _buildInfoRow('Interests', user.interests),
          _buildInfoRow(
            'Bio',
            user.bio.isNotEmpty ? user.bio : 'No bio added yet',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouMayAlsoLike() {
    if (_suggestedProfiles.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'You May Also Like',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => const SwipeScreen()),
              child: Text(
                'See More',
                style: TextStyle(color: DatingTheme.primaryPink),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _suggestedProfiles.length,
            itemBuilder: (context, index) {
              return _buildSuggestedProfileCard(_suggestedProfiles[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedProfileCard(UserModel user) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 12),
      child: Card(
        color: DatingTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: user.avatar,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: DatingTheme.darkBackground,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: DatingTheme.darkBackground,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${user.age}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionSections() {
    return Column(
      children: [
        _buildInteractionSection(
          'People Who Liked Me',
          _likedByUsers,
          Icons.favorite,
        ),
        SizedBox(height: 16),
        _buildInteractionSection(
          'People I Liked',
          _likedUsers,
          Icons.favorite_border,
        ),
        SizedBox(height: 16),
        _buildInteractionSection('My Matches', _matchedUsers, Icons.star),
        SizedBox(height: 16),
        _buildInteractionSection('Chat History', _chatUsers, Icons.chat),
      ],
    );
  }

  Widget _buildInteractionSection(
    String title,
    List<UserModel> users,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: DatingTheme.primaryPink, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                '${users.length}',
                style: TextStyle(
                  color: DatingTheme.primaryPink,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (users.isEmpty)
            Text(
              'No users yet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            )
          else
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 50,
                    margin: EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: DatingTheme.primaryPink,
                              width: 1,
                            ),
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: users[index].avatar,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: DatingTheme.darkBackground,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: DatingTheme.darkBackground,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          users[index].name.split(' ').first,
                          style: TextStyle(color: Colors.white, fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _editName() {
    TextEditingController nameController = TextEditingController(
      text: _mainController.loggedInUser.name,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: DatingTheme.cardBackground,
            title: Text('Edit Name', style: TextStyle(color: Colors.white)),
            content: TextField(
              controller: nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: DatingTheme.primaryPink),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: DatingTheme.primaryPink),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text.trim().isNotEmpty) {
                    try {
                      final response = await Utils.http_post('update-name', {
                        'name': nameController.text.trim(),
                      });

                      final resp = RespondModel(response);
                      if (resp.code == 1) {
                        await _mainController.getLoggedInUser();
                        setState(() {});
                        Utils.toast('Name updated successfully!');
                        Navigator.pop(context);
                      } else {
                        Utils.toast('Failed to update name');
                      }
                    } catch (e) {
                      Utils.toast('Error updating name: $e');
                    }
                  }
                },
                child: Text(
                  'Save',
                  style: TextStyle(color: DatingTheme.primaryPink),
                ),
              ),
            ],
          ),
    );
  }
}
