import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/models/ManifestModel.dart';
import 'package:lovebirds_app/models/ManifestService.dart';
import 'package:lovebirds_app/models/NewMovieModel.dart';
import 'package:lovebirds_app/utils/CustomTheme.dart';
import 'package:shimmer/shimmer.dart';

import '../MoviesSearchScreen.dart';
import '../widgets.dart';
import 'MovieDetailScreen.dart';

/// MoviesListingScreen shows movies (or episodes) in a grid with infinite scroll.
/// It provides filter options for VJ, Genre and Type. The type distinguishes Movies from Series.
class MoviesListingScreen extends StatefulWidget {
  final Map<String, dynamic> params;

  const MoviesListingScreen(this.params, {Key? key}) : super(key: key);

  @override
  State<MoviesListingScreen> createState() => _MoviesListingScreenState();
}

class _MoviesListingScreenState extends State<MoviesListingScreen> {
  final List<NewMovieModel> _movies = [];
  bool _hasMore = true;
  bool _isLoading = false;
  int _page = 1;
  final int perPage = 20;
  final ScrollController _scrollCtrl = ScrollController();

  // Manifest info for dropdown filters.
  final ManifestService _manifestService = ManifestService();
  ManifestModel? _manifest;

  // Current selected filters.
  String? _selectedVj;
  String? _selectedGenre;
  String? _selectedType; // 'Movie' or 'Series' (or null for all)

  // Controls filter row visibility.
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // Check and set initial filter parameters.
    if (widget.params.containsKey('genre')) {
      _selectedGenre = widget.params['genre'];
      _showFilters = true;
    }
    if (widget.params.containsKey('vj')) {
      _selectedVj = widget.params['vj'];
      _showFilters = true;
    }
    if (widget.params.containsKey('type')) {
      _selectedType = widget.params['type'];
      _showFilters = true;
    }
    _scrollCtrl.addListener(_onScrollCheck);
    _initFetch();
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScrollCheck);
    _scrollCtrl.dispose();
    super.dispose();
  }

  // Listen for scroll events to trigger fetching next page.
  void _onScrollCheck() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      _fetchMovies();
    }
  }

  Future<void> _initFetch() async {
    setState(() {
      _isLoading = true;
      _movies.clear();
      _hasMore = true;
      _page = 1;
    });
    try {
      final data = await _manifestService.getManifest();
      _manifest = ManifestModel.fromJson(data);
    } catch (e) {
      // Optionally show an error (e.g., using a toast) when loading the manifest fails.
      print("Manifest load error: $e");
    }
    await _fetchMovies();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchMovies() async {
    if (_movies.isNotEmpty) {
      if (_isLoading || !_hasMore) return;
    }

    setState(() => _isLoading = true);

    // Request the next page and include typeFilter (if provided).
    List<NewMovieModel> fetched = [];
    setState(() {
      _movies.addAll(fetched);
      _page++;
      _isLoading = false;
      if (fetched.length < perPage) {
        _hasMore = false;
      }
    });
  }

  Future<void> _refreshAll() async {
    setState(() {
      _movies.clear();
      _page = 1;
      _hasMore = true;
    });
    await _fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        color: CustomTheme.primary,
        backgroundColor: Colors.white,
        child: _buildBody(),
      ),
    );
  }

  //─────────────────────────────────────────────
  // AppBar
  //─────────────────────────────────────────────
  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.yellow),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            "Movies",
            style: TextStyle(color: Colors.white, height: 1),
          ),
          Text(
            "Showing ${_movies.length} movies",
            style: const TextStyle(color: CustomTheme.accent, fontSize: 10),
          ),
        ],
      ),
      elevation: 0,
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {
            Get.to(() => const MoviesSearchScreen({}));
          },
          icon: const Icon(FeatherIcons.search, color: Colors.yellow),
        ),
        IconButton(
          onPressed: () {
            // Toggle filter row visibility.
            setState(() {
              _showFilters = !_showFilters;
            });
          },
          icon: const Icon(FeatherIcons.filter, color: Colors.yellow),
        ),
      ],
    );
  }

  //─────────────────────────────────────────────
  // Body: Filters + Movie Grid
  //─────────────────────────────────────────────
  Widget _buildBody() {
    return Column(
      children: [
        if (_showFilters) _buildFilterRow(),
        Expanded(child: _buildMovieGrid()),
      ],
    );
  }

  //─────────────────────────────────────────────
  // Filter Row: VJ, Genre, and Type dropdowns.
  //─────────────────────────────────────────────
  Widget _buildFilterRow() {
    return Container(
      color: CustomTheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          Expanded(child: _buildVjDropdown()),
          const SizedBox(width: 10),
          Expanded(child: _buildGenreDropdown()),
          const SizedBox(width: 10),
          Expanded(child: _buildTypeDropdown()),
        ],
      ),
    );
  }

  Widget _buildVjDropdown() {
    if (_manifest == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text("Loading VJs...", style: TextStyle(color: Colors.white)),
        ),
      );
    }
    List<String> vjs = ["All"];
    vjs.addAll(_manifest!.vj);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        underline: const SizedBox.shrink(),
        iconEnabledColor: Colors.white,
        dropdownColor: Colors.grey.shade800,
        isExpanded: true,
        value: _selectedVj ?? "All",
        style: const TextStyle(color: Colors.white),
        items:
            vjs
                .map(
                  (vj) => DropdownMenuItem<String>(
                    value: vj == "All" ? "All" : vj,
                    child: Text(
                      vj,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
        onChanged: (value) {
          setState(() {
            _selectedVj = (value == "All") ? null : value;
            _movies.clear();
            _page = 1;
            _hasMore = true;
          });
          _fetchMovies();
        },
      ),
    );
  }

  Widget _buildGenreDropdown() {
    if (_manifest == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            "Loading Genres...",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    List<String> genres = ["All"];
    genres.addAll(_manifest!.genres);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        underline: const SizedBox.shrink(),
        iconEnabledColor: Colors.white,
        dropdownColor: Colors.grey.shade800,
        isExpanded: true,
        value: _selectedGenre ?? "All",
        style: const TextStyle(color: Colors.white),
        items:
            genres
                .map(
                  (genre) => DropdownMenuItem<String>(
                    value: genre == "All" ? "All" : genre,
                    child: Text(
                      genre,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
        onChanged: (value) {
          setState(() {
            _selectedGenre = (value == "All") ? null : value;
            _movies.clear();
            _page = 1;
            _hasMore = true;
          });
          _fetchMovies();
        },
      ),
    );
  }

  Widget _buildTypeDropdown() {
    // Here you can define the filter types.
    List<String> types = ["All", "Movie", "Series"];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        underline: const SizedBox.shrink(),
        iconEnabledColor: Colors.white,
        dropdownColor: Colors.grey.shade800,
        isExpanded: true,
        value: _selectedType ?? "All",
        style: const TextStyle(color: Colors.white),
        items:
            types
                .map(
                  (type) => DropdownMenuItem<String>(
                    value: type == "All" ? "All" : type,
                    child: Text(
                      type,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
        onChanged: (value) {
          setState(() {
            _selectedType = (value == "All") ? null : value;
            _movies.clear();
            _page = 1;
            _hasMore = true;
          });
          _fetchMovies();
        },
      ),
    );
  }

  //─────────────────────────────────────────────
  // Movie Grid / Infinite Scroll
  //─────────────────────────────────────────────
  Widget _buildMovieGrid() {
    if (_movies.isEmpty && _isLoading) {
      return _buildShimmerGrid();
    } else if (_movies.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            FxText.bodyLarge("No movies found", color: Colors.white),
            const SizedBox(height: 10),
            FxButton.rounded(
              child: FxText.bodyLarge("Reload", color: Colors.yellow),
              onPressed: () => _fetchMovies(),
            ),
            const Spacer(),
          ],
        ),
      );
    } else {
      return GridView.builder(
        controller: _scrollCtrl,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 8,
          childAspectRatio: 0.75,
        ),
        padding: const EdgeInsets.all(8),
        itemCount: _movies.length + 1,
        itemBuilder: (ctx, index) {
          if (index == _movies.length) {
            if (_isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (!_hasMore) {
              return const Center(
                child: Text(
                  "No more movies",
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }
          NewMovieModel movie = _movies[index];
          return _buildMovieGridTile(movie);
        },
      );
    }
  }

  Widget _buildMovieGridTile(NewMovieModel movie) {
    return InkWell(
      onTap: () => Get.to(() => MovieDetailScreen({'movie': movie})),
      child: buildMovieCard2(movie),
    );
  }

  //─────────────────────────────────────────────
  // Shimmer Loader for Movies Grid
  //─────────────────────────────────────────────
  Widget _buildShimmerGrid() {
    return const ShimmerGrid();
  }

  Widget buildMovieCard2(NewMovieModel item) {
    return Container(
      width: Get.width / 3.2,
      padding: const EdgeInsets.only(right: 3, left: 3, top: 0),
      child: Stack(
        children: [
          roundedImage2(item.getThumbnail(), 1, 1),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.2, 0.6],
                colors: [
                  item.watched_movie != 'Yes' ? Colors.black : Colors.green,
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            width: double.infinity,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 5,
                bottom: 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FxText.bodyMedium(
                    item.title,
                    height: 1,
                    fontWeight: 500,
                    maxLines: 2,
                    fontSize: 14,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 0),

                  Visibility(
                    visible: item.watched_movie == 'Yes',
                    child: Column(
                      children: [
                        const SizedBox(height: 2),
                        LinearProgressIndicator(
                          value: item.watched_percentage,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.yellow,
                          ),
                          minHeight: 4,
                        ),
                        const SizedBox(height: 2),
                        FxText.bodySmall(
                          "Continue Watching This Movie",
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: 600,
                          height: .9,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 3),
                      ],
                    ),
                  ),

                  Visibility(
                    visible: item.watched_movie != 'Yes',
                    child: Row(
                      children: [
                        const Icon(
                          FeatherIcons.mic,
                          color: Colors.white,
                          size: 10,
                        ),
                        const SizedBox(width: 1),
                        Expanded(
                          child: FxText(
                            item.vj.isEmpty ? item.genre : item.vj,
                            color: Colors.yellow,
                            fontWeight: 800,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A reusable shimmer grid widget that displays a skeleton UI
/// for a grid of items. You can customize the grid’s layout,
/// shimmer colors, and placeholder sizes by providing parameters.
class ShimmerGrid extends StatelessWidget {
  /// Total number of grid items
  final int itemCount;

  /// Number of columns in the grid
  final int crossAxisCount;

  /// Vertical spacing between grid items
  final double mainAxisSpacing;

  /// Horizontal spacing between grid items
  final double crossAxisSpacing;

  /// Aspect ratio for grid items (width / height)
  final double childAspectRatio;

  /// Padding applied to the entire grid
  final EdgeInsetsGeometry padding;

  /// Height for the image placeholder section.
  final double imageHeight;

  /// Border radius for the entire grid item.
  final double borderRadius;

  /// Height for the title placeholder.
  final double titleHeight;

  /// Width for the title placeholder. If not specified, it occupies full width.
  final double? titleWidth;

  /// Height for the subtitle placeholder.
  final double subtitleHeight;

  /// Width for the subtitle placeholder.
  final double subtitleWidth;

  /// The base color for the shimmer effect.
  final Color baseColor;

  /// The highlight color for the shimmer effect.
  final Color highlightColor;

  const ShimmerGrid({
    Key? key,
    this.itemCount = 9,
    this.crossAxisCount = 3,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.childAspectRatio = 0.75,
    this.padding = const EdgeInsets.all(8),
    this.imageHeight = 80,
    this.borderRadius = 8,
    this.titleHeight = 16,
    this.titleWidth,
    this.subtitleHeight = 14,
    this.subtitleWidth = 50,
    this.baseColor = const Color(0xFF2A2A2A),
    this.highlightColor = const Color(0xFF3A3A3A),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image placeholder
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    topRight: Radius.circular(borderRadius),
                  ),
                  child: Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Title placeholder
              Padding(
                padding: const EdgeInsets.all(4),
                child: Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: titleHeight,
                    width: titleWidth ?? double.infinity,
                    color: Colors.white,
                  ),
                ),
              ),
              // Subtitle placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: subtitleHeight,
                    width: subtitleWidth,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
