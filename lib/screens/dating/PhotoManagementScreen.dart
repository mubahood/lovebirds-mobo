import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../models/LoggedInUserModel.dart';
import '../../models/RespondModel.dart';
import '../../utils/AppConfig.dart';
import '../../utils/CustomTheme.dart';
import '../../utils/Utilities.dart';

class PhotoManagementScreen extends StatefulWidget {
  final LoggedInUserModel user;

  const PhotoManagementScreen({Key? key, required this.user}) : super(key: key);

  @override
  _PhotoManagementScreenState createState() => _PhotoManagementScreenState();
}

class _PhotoManagementScreenState extends State<PhotoManagementScreen> {
  late LoggedInUserModel _user;
  List<String> _photos = [];
  bool _loading = true;
  bool _uploading = false;
  String _error = "";

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadPhotos();
  }

  void _loadPhotos() {
    setState(() {
      _loading = true;
      _error = "";
    });

    // Parse profile photos from user data
    if (_user.profile_photos.isNotEmpty) {
      try {
        // Parse JSON string - handle both JSON array format and comma-separated format
        String photosStr = _user.profile_photos.trim();

        if (photosStr.startsWith('[') && photosStr.endsWith(']')) {
          // JSON array format: ["photo1.jpg", "photo2.jpg"]
          photosStr = photosStr.substring(
            1,
            photosStr.length - 1,
          ); // Remove brackets
          _photos =
              photosStr
                  .split(',')
                  .map((e) => e.trim().replaceAll('"', '')) // Remove quotes
                  .where((e) => e.isNotEmpty)
                  .toList();
        } else if (photosStr.contains(',')) {
          // Comma-separated format: photo1.jpg,photo2.jpg
          _photos =
              photosStr
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
        } else {
          // Single photo
          _photos = [photosStr];
        }
      } catch (e) {
        print('Error parsing photos: $e');
        _photos = [];
      }
    } else {
      _photos = [];
    }

    setState(() => _loading = false);
  }

  Future<void> _pickAndUploadPhoto() async {
    if (_photos.length >= 6) {
      Utils.toast('Maximum 6 photos allowed', color: Colors.orange);
      return;
    }

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _uploading = true);

    try {
      FormData formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          picked.path,
          filename: 'photo.jpg',
        ),
      });

      Dio dio = Dio();
      LoggedInUserModel user = await LoggedInUserModel.getLoggedInUser();

      dio.options.headers = {
        'logged_in_user_id': user.id.toString(),
        'Content-Type': 'multipart/form-data',
      };

      final response = await dio.post(
        '${AppConfig.API_BASE_URL}/upload-profile-photos',
        data: formData,
      );

      if (response.statusCode == 200) {
        RespondModel r = RespondModel(response.data);
        if (r.code == 1) {
          // Update local photos list
          if (r.data != null && r.data['profile_photos'] != null) {
            _photos = List<String>.from(r.data['profile_photos']);
            _user.profile_photos = jsonEncode(_photos);
            await _user.save();
          }
          Utils.toast('Photo uploaded successfully!', color: Colors.green);
          setState(() {});
        } else {
          throw Exception(r.message);
        }
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      setState(() => _error = 'Upload failed: ${e.toString()}');
      Utils.toast('Upload failed', color: Colors.red);
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _deletePhoto(String photoUrl) async {
    try {
      dynamic response = await Utils.http_post('delete-profile-photo', {
        'photo_url': photoUrl,
      });

      RespondModel r = RespondModel(response);
      if (r.code == 1) {
        // Update local photos list
        if (r.data != null && r.data['profile_photos'] != null) {
          _photos = List<String>.from(r.data['profile_photos']);
          _user.profile_photos = jsonEncode(_photos);
          await _user.save();
        }
        Utils.toast('Photo deleted successfully!', color: Colors.green);
        setState(() {});
      } else {
        throw Exception(r.message);
      }
    } catch (e) {
      Utils.toast('Delete failed: ${e.toString()}', color: Colors.red);
    }
  }

  Future<void> _reorderPhotos() async {
    try {
      dynamic response = await Utils.http_post('reorder-profile-photos', {
        'photo_order': _photos,
      });

      RespondModel r = RespondModel(response);
      if (r.code == 1) {
        _user.profile_photos = jsonEncode(_photos);
        await _user.save();
        Utils.toast('Photos reordered successfully!', color: Colors.green);
      } else {
        throw Exception(r.message);
      }
    } catch (e) {
      Utils.toast('Reorder failed: ${e.toString()}', color: Colors.red);
    }
  }

  void _showDeleteDialog(String photoUrl, int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: CustomTheme.card,
            title: FxText.titleMedium('Delete Photo', color: Colors.white),
            content: FxText.bodyMedium(
              'Are you sure you want to delete this photo?',
              color: CustomTheme.color2,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: FxText.bodyMedium('Cancel', color: CustomTheme.color2),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deletePhoto(photoUrl);
                },
                child: FxText.bodyMedium('Delete', color: Colors.red),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        iconTheme: const IconThemeData(color: CustomTheme.accent),
        elevation: 1,
        title: FxText.titleLarge(
          'Manage Photos',
          color: CustomTheme.accent,
          fontWeight: 700,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_a_photo, color: CustomTheme.primary),
            onPressed: _uploading ? null : _pickAndUploadPhoto,
          ),
        ],
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(CustomTheme.accent),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FxText.bodySmall(
                                _error,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Instructions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CustomTheme.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: CustomTheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              FxText.bodyLarge(
                                'Photo Tips',
                                color: Colors.white,
                                fontWeight: 600,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          FxText.bodySmall(
                            '• First photo is your primary photo\n'
                            '• Long press and drag to reorder\n'
                            '• Tap trash icon to delete\n'
                            '• Maximum 6 photos allowed',
                            color: CustomTheme.color2,
                            height: 1.4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Photos count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FxText.titleMedium(
                          'Your Photos (${_photos.length}/6)',
                          color: CustomTheme.accent,
                          fontWeight: 600,
                        ),
                        if (_uploading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                CustomTheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Photos grid
                    if (_photos.isEmpty)
                      _buildEmptyState()
                    else
                      _buildPhotosGrid(),

                    const SizedBox(height: 24),

                    // Add photo button
                    if (_photos.length < 6)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _uploading ? null : _pickAndUploadPhoto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            Icons.add_a_photo,
                            color: CustomTheme.accent,
                          ),
                          label: FxText.bodyLarge(
                            _uploading ? 'Uploading...' : 'Add Photo',
                            color: CustomTheme.accent,
                            fontWeight: 600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomTheme.color3.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: CustomTheme.color3,
          ),
          const SizedBox(height: 16),
          FxText.titleMedium(
            'No Photos Yet',
            color: Colors.white,
            fontWeight: 600,
          ),
          const SizedBox(height: 8),
          FxText.bodyMedium(
            'Add your first photo to get started!\nGreat photos get 3x more matches.',
            color: CustomTheme.color2,
            textAlign: TextAlign.center,
            height: 1.4,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid() {
    return ReorderableGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children:
          _photos.asMap().entries.map((entry) {
            int index = entry.key;
            String photo = entry.value;
            return _buildPhotoCard(photo, index, key: ValueKey(photo));
          }).toList(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final String item = _photos.removeAt(oldIndex);
          _photos.insert(newIndex, item);
        });
        _reorderPhotos();
      },
    );
  }

  Widget _buildPhotoCard(String photo, int index, {required Key key}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border:
            index == 0
                ? Border.all(color: CustomTheme.primary, width: 2)
                : Border.all(color: CustomTheme.color3.withValues(alpha: 0.3)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                Utils.getImageUrl(photo),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: CustomTheme.card,
                    child: Icon(
                      Icons.broken_image,
                      color: CustomTheme.color3,
                      size: 32,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: CustomTheme.card,
                    child: Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(CustomTheme.primary),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Primary photo badge
          if (index == 0)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CustomTheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FxText.bodySmall(
                  'PRIMARY',
                  color: CustomTheme.accent,
                  fontWeight: 700,
                  fontSize: 10,
                ),
              ),
            ),

          // Delete button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _showDeleteDialog(photo, index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete, color: Colors.white, size: 16),
              ),
            ),
          ),

          // Drag handle
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.drag_indicator,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
