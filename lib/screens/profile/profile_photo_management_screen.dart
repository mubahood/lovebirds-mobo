import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

import '../../models/LoggedInUserModel.dart';
import '../../utils/AppConfig.dart';
import '../../utils/CustomTheme.dart';
import '../../widgets/dating/multi_photo_gallery.dart';

class ProfilePhotoManagementScreen extends StatefulWidget {
  @override
  _ProfilePhotoManagementScreenState createState() =>
      _ProfilePhotoManagementScreenState();
}

class _ProfilePhotoManagementScreenState
    extends State<ProfilePhotoManagementScreen> {
  late LoggedInUserModel currentUser;
  List<String> _photoUrls = [];
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  static const int maxPhotos = 6;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    currentUser = await LoggedInUserModel.getLoggedInUser();
    _photoUrls = _getProfilePhotoUrls();
    setState(() {});
  }

  // Helper methods for LoggedInUserModel photo management
  List<String> _getProfilePhotos() {
    if (currentUser.profile_photos.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(currentUser.profile_photos);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  List<String> _getProfilePhotoUrls() {
    final photos = _getProfilePhotos();
    return photos.map((photo) {
      if (photo.startsWith('http')) {
        return photo;
      }
      return '${AppConfig.BASE_URL}/storage/$photo';
    }).toList();
  }

  Future<void> _pickImage() async {
    if (_photoUrls.length >= maxPhotos) {
      _showSnackBar('Maximum $maxPhotos photos allowed');
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        await _uploadPhoto(File(image.path));
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  Future<void> _uploadPhoto(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.BASE_URL}/api/User'),
      );

      // Add authorization header
      final token = await LoggedInUserModel.get_token();

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Tok'] = 'Bearer $token';

      // Add user ID
      request.fields['id'] = currentUser.id.toString();

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath('photo', imageFile.path),
      );

      // Add temp_file_field to indicate we're uploading a photo
      request.fields['temp_file_field'] = 'profile_photos';

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseData);
        if (jsonResponse['success']) {
          // Refresh user data
          _loadCurrentUser();
          _showSnackBar('Photo uploaded successfully!');
        } else {
          _showSnackBar('Upload failed: ${jsonResponse['message']}');
        }
      } else {
        _showSnackBar('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Upload error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomTheme.background,
        title: FxText.titleLarge(
          'Manage Photos',
          fontWeight: 700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: CustomTheme.background,
      body: Column(
        children: [
          // Instructions
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CustomTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.bodyMedium(
                  'Photo Tips:',
                  fontWeight: 600,
                  color: CustomTheme.primary,
                ),
                SizedBox(height: 8),
                FxText.bodySmall(
                  '• Upload up to $maxPhotos photos\n'
                  '• First photo is your primary photo\n'
                  '• High quality photos get more matches!',
                  color: Colors.white70,
                ),
              ],
            ),
          ),

          // Photo grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: maxPhotos,
                itemBuilder: (context, index) {
                  return _buildPhotoSlot(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSlot(int index) {
    final bool hasPhoto = index < _photoUrls.length;
    final bool isPrimary = index == 0 && hasPhoto;

    return GestureDetector(
      onTap: hasPhoto ? () => _showPhotoViewer(index) : _pickImage,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isPrimary ? CustomTheme.primary : Colors.grey.withValues(alpha: 0.3),
            width: isPrimary ? 3 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Photo or add button
              if (hasPhoto)
                _buildPhotoItem(_photoUrls[index])
              else
                _buildAddPhotoButton(),

              // Primary badge
              if (isPrimary)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: CustomTheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FxText.bodySmall(
                      'PRIMARY',
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: 700,
                    ),
                  ),
                ),

              // Loading overlay
              if (_isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoItem(String imageUrl) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              color: CustomTheme.primary.withValues(alpha: 0.1),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    CustomTheme.primary,
                  ),
                ),
              ),
            ),
        errorWidget:
            (context, url, error) => Container(
              color: Colors.grey[800],
              child: Icon(Icons.error, color: Colors.grey),
            ),
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: CustomTheme.primary.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 32, color: CustomTheme.primary),
          SizedBox(height: 8),
          FxText.bodySmall(
            'Add Photo',
            color: CustomTheme.primary,
            fontWeight: 600,
          ),
        ],
      ),
    );
  }

  void _showPhotoViewer(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FullScreenPhotoViewer(
              photoUrls: _photoUrls,
              initialIndex: index,
              userName: currentUser.name,
            ),
      ),
    );
  }
}
