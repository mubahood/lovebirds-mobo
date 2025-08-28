import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutx/flutx.dart';

import '../../models/UserModel.dart';
import '../../utils/CustomTheme.dart';

class MultiPhotoGallery extends StatefulWidget {
  final UserModel user;
  final double height;
  final bool showIndicators;
  final bool allowSwipe;
  final Function(int)? onPhotoChanged;

  const MultiPhotoGallery({
    Key? key,
    required this.user,
    this.height = 400,
    this.showIndicators = true,
    this.allowSwipe = true,
    this.onPhotoChanged,
  }) : super(key: key);

  @override
  State<MultiPhotoGallery> createState() => _MultiPhotoGalleryState();
}

class _MultiPhotoGalleryState extends State<MultiPhotoGallery> {
  late PageController _pageController;
  int _currentIndex = 0;
  late List<String> _photoUrls;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _photoUrls = widget.user.getProfilePhotoUrls();

    // If no profile photos, use primary photo URL as fallback
    if (_photoUrls.isEmpty) {
      _photoUrls = [widget.user.getPrimaryPhotoUrl()];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPhotoChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onPhotoChanged?.call(index);
  }

  void _goToPhoto(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_photoUrls.isEmpty) {
      return _buildErrorWidget();
    }

    return Container(
      height: widget.height,
      child: Stack(
        children: [
          // Photo viewer
          _buildPhotoViewer(),

          // Photo indicators at top
          if (widget.showIndicators && _photoUrls.length > 1)
            _buildPhotoIndicators(),

          // Photo counter in top-right corner
          if (_photoUrls.length > 1)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentIndex + 1}/${_photoUrls.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Navigation areas (invisible tap zones)
          if (widget.allowSwipe && _photoUrls.length > 1)
            _buildNavigationAreas(),
        ],
      ),
    );
  }

  Widget _buildPhotoViewer() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPhotoChanged,
      itemCount: _photoUrls.length,
      itemBuilder: (context, index) {
        return _buildPhotoItem(_photoUrls[index]);
      },
    );
  }

  Widget _buildPhotoItem(String imageUrl) {
    return Container(
      width: double.infinity,
      height: widget.height,
      child: GestureDetector(
        onTap: () {
          // Allow tapping photo to open full-screen viewer
          if (_photoUrls.length > 1) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => FullScreenPhotoViewer(
                      photoUrls: _photoUrls,
                      initialIndex: _currentIndex,
                      userName:
                          widget.user.first_name.isNotEmpty
                              ? '${widget.user.first_name} ${widget.user.last_name}'
                              : 'User',
                    ),
              ),
            );
          }
        },
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                color: CustomTheme.primary.withValues(alpha: 0.1),
                child: const Center(child: CircularProgressIndicator()),
              ),
          errorWidget:
              (context, url, error) => Container(
                color: CustomTheme.primary.withValues(alpha: 0.1),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, size: 80, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Image not available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildPhotoIndicators() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        children: List.generate(_photoUrls.length, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              height: 3,
              decoration: BoxDecoration(
                color:
                    _currentIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationAreas() {
    return Row(
      children: [
        // Left tap area
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_currentIndex > 0) {
                _goToPhoto(_currentIndex - 1);
              }
            },
            child: Container(height: widget.height, color: Colors.transparent),
          ),
        ),
        // Right tap area
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_currentIndex < _photoUrls.length - 1) {
                _goToPhoto(_currentIndex + 1);
              }
            },
            child: Container(height: widget.height, color: Colors.transparent),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: widget.height,
      color: CustomTheme.primary.withValues(alpha: 0.1),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.grey),
            SizedBox(height: 8),
            Text('No photos available', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// Full-screen photo viewer
class FullScreenPhotoViewer extends StatefulWidget {
  final List<String> photoUrls;
  final int initialIndex;
  final String userName;

  const FullScreenPhotoViewer({
    Key? key,
    required this.photoUrls,
    this.initialIndex = 0,
    required this.userName,
  }) : super(key: key);

  @override
  State<FullScreenPhotoViewer> createState() => _FullScreenPhotoViewerState();
}

class _FullScreenPhotoViewerState extends State<FullScreenPhotoViewer> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: FxText.titleMedium(
          '${widget.userName} (${_currentIndex + 1}/${widget.photoUrls.length})',
          color: Colors.white,
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.photoUrls.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.photoUrls[index],
                fit: BoxFit.contain,
                placeholder:
                    (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                errorWidget:
                    (context, url, error) => const Center(
                      child: Icon(Icons.error, color: Colors.white, size: 50),
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
