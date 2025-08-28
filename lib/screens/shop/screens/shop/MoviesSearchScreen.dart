import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/models/NewMovieModel.dart';
import 'package:lovebirds_app/screens/shop/screens/shop/movies/MovieDetailScreen.dart';
import 'package:lovebirds_app/utils/CustomTheme.dart';
import 'package:shimmer/shimmer.dart';

class MoviesSearchScreen extends StatefulWidget {
  final Map<String, dynamic> params;

  const MoviesSearchScreen(this.params, {Key? key}) : super(key: key);

  @override
  State<MoviesSearchScreen> createState() => _MoviesSearchScreenState();
}

class _MoviesSearchScreenState extends State<MoviesSearchScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController _searchCtrl = TextEditingController();

  /// List of found movies
  final List<NewMovieModel> _movies = [];

  /// Pagination / state tracking
  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = false;

  /// Called whenever the user types in the search field
  Timer? _debounceTimer;

  /// Scroll controller to detect infinite scroll
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _scrollCtrl.addListener(_onScrollCheck);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _scrollCtrl.removeListener(_onScrollCheck);
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  /// Called whenever text changes in the search bar
  void _onSearchChanged() {
    // Cancel any pending calls
    _debounceTimer?.cancel();

    // If user typed fewer than 2 chars => clear results
    if (_searchCtrl.text.trim().length < 2) {
      setState(() {
        _movies.clear();
        _page = 1;
        _hasMore = true;
      });
      return;
    }

    // Debounce the search requests by 400ms
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      // Reset pagination
      setState(() {
        _movies.clear();
        _page = 1;
        _hasMore = true;
      });
      _fetchMovies();
    });
  }

  /// Called when user scrolls near the bottom => load next page
  void _onScrollCheck() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      _fetchMovies();
    }
  }

  /// Searches the next page of results
  Future<void> _fetchMovies() async {
    if (_isLoading || !_hasMore) return; // guard

    setState(() {
      _isLoading = true;
    });

    final query = _searchCtrl.text.trim();
    // Example: 15 items per page
    List<NewMovieModel> fetched = await NewMovieModel.searchMoviesOnline(
      query: query,
      page: _page,
    );

    setState(() {
      _movies.addAll(fetched);
      _isLoading = false;
      _page++;
      if (fetched.length < 15) {
        _hasMore = false;
      }
    });
  }

  /// Called by pull-to-refresh
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
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: _buildSearchBar(),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        color: CustomTheme.primary,
        backgroundColor: Colors.white,
        child: _buildResultList(),
      ),
    );
  }

  /// The search bar input on AppBar
  Widget _buildSearchBar() {
    return FxContainer(
      borderRadiusAll: 5,
      padding: const EdgeInsets.only(left: 16, right: 0),
      margin: const EdgeInsets.only(right: 15),
      child: FormBuilder(
        key: _formKey,
        child: FormBuilderTextField(
          name: 'search',
          controller: _searchCtrl,
          autofocus: true,
          cursorColor: Colors.white,
          textInputAction: TextInputAction.search,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            suffixIcon:
                _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                      onPressed: () {
                        setState(() {
                          _searchCtrl.clear();
                          _movies.clear();
                          _page = 1;
                          _hasMore = true;
                        });
                      },
                      icon: const Icon(FeatherIcons.x, color: Colors.white),
                    ),
            hintText: 'Search for movies...',
            hintStyle: const TextStyle(color: Colors.white54),
            enabledBorder: InputBorder.none,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }

  /// Main body: decides between shimmer, "no results", or the list
  Widget _buildResultList() {
    final typedChars = _searchCtrl.text.trim().length;
    // If user typed fewer than 2 chars => prompt them to type more
    if (typedChars < 2) {
      return ListView(
        controller: _scrollCtrl,
        children: const [
          SizedBox(height: 100),
          Center(
            child: Text(
              'Type at least 2 characters to search.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      );
    }

    // If there's a load in progress and no data => show shimmer placeholder
    if (_movies.isEmpty && _isLoading) {
      return _buildShimmerList();
    }

    // If typed >=2 but no results and not loading => show "no results"
    if (_movies.isEmpty && !_isLoading) {
      return ListView(
        controller: _scrollCtrl,
        children: [
          const SizedBox(height: 100),
          Center(
            child: FxText(
              'No search results for "${_searchCtrl.text}"',
              color: Colors.white,
              textAlign: TextAlign.center,
              fontWeight: 700,
            ),
          ),
        ],
      );
    }

    // Otherwise show the result list with infinite scroll
    return ListView.builder(
      controller: _scrollCtrl,
      itemCount: _movies.length + 1, // extra row for "loading" or "no more"
      itemBuilder: (context, index) {
        // If at the end => show spinner or "no more"
        if (index == _movies.length) {
          if (_isLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          } else if (!_hasMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No more results',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
        // Build a tile for each movie
        NewMovieModel movie = _movies[index];
        return _buildMovieListTile(movie);
      },
    );
  }

  /// Builds each "search result" row
  Widget _buildMovieListTile(NewMovieModel movie) {
    return InkWell(
      onTap: () => Get.to(() => MovieDetailScreen({'movie': movie})),
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Thumbnail with shimmer
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                width: 80,
                height: 80,
                imageUrl: movie.getThumbnail(),
                placeholder:
                    (context, url) =>
                        const ShimmerLoadingWidget(height: 80, width: 80),
                errorWidget:
                    (context, url, error) => const Image(
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/bg.jpg'),
                    ),
              ),
            ),
            const SizedBox(width: 10),
            // Title + info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FxText.titleMedium(
                    movie.title,
                    fontWeight: 700,
                    maxLines: 2,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: CustomTheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FxText.bodySmall(
                      movie.genre.isNotEmpty
                          ? movie.genre
                          : movie.vj.isNotEmpty
                          ? movie.vj
                          : '-',
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: 900,
                      maxLines: 1,
                      fontSize: 14,
                    ),
                  ),
                  // Additional info (like year, rating, etc.) can go here
                  //row display type and status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FxText.titleMedium(
                        movie.type,
                        fontWeight: 200,
                        maxLines: 2,
                        color: Colors.grey.shade500,
                        overflow: TextOverflow.ellipsis,
                      ),
                      FxText.titleMedium(
                        movie.status,
                        fontWeight: 200,
                        maxLines: 2,
                        color: Colors.grey.shade500,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer placeholders displayed when _movies is empty & _isLoading
  Widget _buildShimmerList() {
    // e.g. 6 placeholders
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (ctx, idx) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Shimmer for the thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const ShimmerLoadingWidget(height: 80, width: 80),
              ),
              const SizedBox(width: 10),
              // Shimmer for text
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoadingWidget(height: 16, width: double.infinity),
                    SizedBox(height: 8),
                    ShimmerLoadingWidget(height: 14, width: 80),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ShimmerLoadingWidget extends StatelessWidget {
  final double height, width;

  const ShimmerLoadingWidget({
    required this.height,
    required this.width,
    super.key,
  });

  @override
  Widget build(BuildContext c) => Shimmer.fromColors(
    baseColor: Colors.white12,
    highlightColor: Colors.white24,
    child: Container(height: height, width: width, color: Colors.white),
  );
}
