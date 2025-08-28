import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../../../controllers/MainController.dart';
import '../../../../../../models/ManifestModel.dart';
import '../../../../../../models/ManifestService.dart';
import '../../../../../../models/NewMovieModel.dart';
import '../../../../../../utils/CustomTheme.dart';
import '../../../../../../utils/app_theme.dart';
import '../../MoviesSearchScreen.dart';
import '../../movies/MovieDetailScreen.dart';
import '../../movies/MoviesListingScreen.dart';

class GuestDashboard extends StatefulWidget {
  const GuestDashboard({Key? key}) : super(key: key);

  @override
  _GuestDashboardState createState() => _GuestDashboardState();
}

class _GuestDashboardState extends State<GuestDashboard>
    with SingleTickerProviderStateMixin {
  late ThemeData theme;
  final MainController mainController = Get.find<MainController>();
  final ManifestService manifestService = ManifestService();
  ManifestModel manifestModel = ManifestModel();
  String _selectedVjFilter = "";

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Constants
  static const double _kHorizontalPadding = 18.0;
  static const double _kVerticalPadding = 14.0;
  static const double _kCardBorderRadius = 14.0;
  static const double _kChipBorderRadius = 18.0;

  @override
  void initState() {
    super.initState();
    theme = AppTheme.darkTheme;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _loadData();
  }

  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
    _animationController.dispose();
    super.dispose();
  }

  void _loadData() {
    _animationController.forward();
    mainController.loadManifest().then((_) {
      if (!isDisposed && mounted) {
        setState(() {
          if (mainController.manifestModel.value != null) {
            manifestModel = mainController.manifestModel.value!;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _kHorizontalPadding,
              vertical: _kVerticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildFeaturedSection(),
                const SizedBox(height: 24),
                _buildBrowseByVJ(),
                const SizedBox(height: 24),
                _buildMovieCategories(),
                const SizedBox(height: 80), // Extra padding for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FxText.bodyLarge('Discover Movies', color: CustomTheme.primary),
              const SizedBox(height: 4),
              FxText.bodyMedium(
                'Browse thousands of Luganda-translated movies',
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(FeatherIcons.search, color: CustomTheme.primary, size: 24),
          onPressed: () {
            Get.to(() => MoviesSearchScreen(const {}));
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedSection() {
    if (manifestModel.lists.isEmpty) {
      return _buildLoadingCard();
    }

    final featuredList =
        manifestModel.lists.isNotEmpty ? manifestModel.lists.first : null;

    if (featuredList == null || featuredList.movies.isEmpty) {
      return _buildNoContentCard();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FxText.titleMedium('Featured Movies'),
            TextButton(
              onPressed: () {
                Get.to(
                  () => MoviesListingScreen({
                    'title': 'Featured Movies',
                    'movies': featuredList.movies,
                  }),
                );
              },
              child: FxText.bodySmall('View All', color: CustomTheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount:
                featuredList.movies.length > 10
                    ? 10
                    : featuredList.movies.length,
            itemBuilder: (context, index) {
              final movie = featuredList.movies[index];
              return _buildMovieCard(movie);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBrowseByVJ() {
    final vjOptions = ['All VJs'] + _getUniqueVJs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FxText.titleMedium('Browse by VJ'),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: vjOptions.length,
            itemBuilder: (context, index) {
              final vj = vjOptions[index];
              final isSelected =
                  _selectedVjFilter == vj ||
                  (_selectedVjFilter.isEmpty && vj == 'All VJs');

              return Padding(
                padding: EdgeInsets.only(
                  right: index < vjOptions.length - 1 ? 12 : 0,
                ),
                child: _buildVJChip(vj, isSelected),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildFilteredMovies(),
      ],
    );
  }

  Widget _buildVJChip(String vj, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVjFilter = vj == 'All VJs' ? '' : vj;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? CustomTheme.primary : Colors.grey[800],
          borderRadius: BorderRadius.circular(_kChipBorderRadius),
          border: Border.all(
            color: isSelected ? CustomTheme.primary : Colors.grey[600]!,
            width: 1,
          ),
        ),
        child: FxText.bodySmall(
          vj,
          color: isSelected ? Colors.white : Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildFilteredMovies() {
    final filteredMovies = _getFilteredMovies();

    if (filteredMovies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(FeatherIcons.film, size: 48, color: Colors.grey[600]),
              const SizedBox(height: 16),
              FxText.bodyMedium(
                'No movies found for this VJ',
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filteredMovies.length > 15 ? 15 : filteredMovies.length,
        itemBuilder: (context, index) {
          return _buildMovieCard(filteredMovies[index]);
        },
      ),
    );
  }

  Widget _buildMovieCategories() {
    if (manifestModel.lists.length <= 1) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FxText.titleMedium('Categories'),
        const SizedBox(height: 16),
        ...manifestModel.lists.skip(1).map((movieList) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _buildCategorySection(movieList),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCategorySection(MovieCategoryList movieList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FxText.titleMedium(movieList.title),
            if (movieList.movies.length > 5)
              TextButton(
                onPressed: () {
                  Get.to(
                    () => MoviesListingScreen({
                      'title': movieList.title,
                      'movies': movieList.movies,
                    }),
                  );
                },
                child: FxText.bodySmall('View All', color: CustomTheme.primary),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount:
                movieList.movies.length > 10 ? 10 : movieList.movies.length,
            itemBuilder: (context, index) {
              return _buildMovieCard(movieList.movies[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(NewMovieModel movie) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          // Create movie params map for MovieDetailScreen
          final movieParams = {
            'id': movie.id,
            'title': movie.title,
            'thumbnail_url': movie.getThumbnail(),
            'url': movie.url,
            'vj': movie.vj,
            'description': movie.description,
            'type': movie.type,
            'status': movie.status,
          };
          Get.to(() => MovieDetailScreen(movieParams));
        },
        child: FxContainer(
          width: 140,
          color: Colors.transparent,
          borderRadiusAll: _kCardBorderRadius,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie Poster
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_kCardBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_kCardBorderRadius),
                  child: CachedNetworkImage(
                    imageUrl: movie.getThumbnail(),
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          color: Colors.grey[800],
                          child: const Center(
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
                          child: const Icon(
                            FeatherIcons.film,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Movie Title
              FxText.bodyMedium(
                movie.title,
                color: Colors.white,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Movie VJ
              if (movie.vj.isNotEmpty)
                FxText.bodySmall(
                  movie.vj,
                  color: CustomTheme.primary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return FxContainer(
      height: 200,
      width: double.infinity,
      color: Colors.grey[850],
      borderRadiusAll: _kCardBorderRadius,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(CustomTheme.primary),
        ),
      ),
    );
  }

  Widget _buildNoContentCard() {
    return FxContainer(
      height: 200,
      width: double.infinity,
      color: Colors.grey[850],
      borderRadiusAll: _kCardBorderRadius,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FeatherIcons.film, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            FxText.bodyMedium('No movies available', color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  List<String> _getUniqueVJs() {
    final Set<String> vjSet = {};
    for (final movieList in manifestModel.lists) {
      for (final movie in movieList.movies) {
        if (movie.vj.isNotEmpty) {
          vjSet.add(movie.vj);
        }
      }
    }
    final vjList = vjSet.toList();
    vjList.sort();
    return vjList;
  }

  List<NewMovieModel> _getFilteredMovies() {
    if (_selectedVjFilter.isEmpty) {
      // Return all movies from all lists
      final List<NewMovieModel> allMovies = [];
      for (final movieList in manifestModel.lists) {
        allMovies.addAll(movieList.movies);
      }
      return allMovies;
    }

    // Filter by selected VJ
    final List<NewMovieModel> filteredMovies = [];
    for (final movieList in manifestModel.lists) {
      for (final movie in movieList.movies) {
        if (movie.vj == _selectedVjFilter) {
          filteredMovies.add(movie);
        }
      }
    }
    return filteredMovies;
  }
}
