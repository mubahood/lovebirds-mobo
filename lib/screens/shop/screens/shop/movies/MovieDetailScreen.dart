import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart'; // For FxText, FxButton, etc.
import 'package:get/get.dart';
import 'package:lovebirds_app/controllers/MainController.dart';
import 'package:lovebirds_app/models/ManifestModel.dart';
import 'package:lovebirds_app/models/ManifestService.dart';
import 'package:lovebirds_app/models/NewMovieModel.dart';
import 'package:lovebirds_app/screens/gardens/VideoPlayerScreen.dart';
import 'package:lovebirds_app/utils/CustomTheme.dart';
import 'package:lovebirds_app/utils/Utilities.dart';
import 'package:lovebirds_app/widget/widgets.dart';
import 'package:readmore/readmore.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../features/moderation/screens/report_content_screen.dart';
import '../../../../../features/moderation/widgets/quick_report_button.dart';
import '../../../models/MovieDownload.dart';
import 'DownloadListScreen.dart';

/// MovieDetailScreen displays details for a given movie. When the movie is
/// of type "Series", it loads and displays all episodes (which share the same
/// category_id) in a vertical list (sorted by the `episode_number` field),
/// marking the currently selected episode clearly. The "You Might Also Like"
/// section is omitted for series.
class MovieDetailScreen extends StatefulWidget {
  final Map<String, dynamic> params;

  const MovieDetailScreen(this.params, {super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen>
    with TickerProviderStateMixin {
  //────────────────────────────
  // Constants for spacing and layout
  //────────────────────────────
  static const double _kHorizontalPadding = 20.0;
  static const double _kVerticalPadding = 16.0;
  static const double _kCardBorderRadius = 16.0;
  static const double _kChipBorderRadius = 10.0;

  //────────────────────────────
  // Color definitions (from your theme)
  //────────────────────────────
  late Color _accentColor;
  late Color _primaryColor;
  late Color _textColor;
  late Color _textMutedColor;

  //────────────────────────────
  // Animation for fade transitions
  //────────────────────────────
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  //────────────────────────────
  // Movie detail and additional data
  //────────────────────────────
  late Future<NewMovieModel?> _movieDetailsFuture;
  NewMovieModel? _movie;
  bool _isSeries = false;

  // Episodes (for series) and related movies (for films)
  final RxBool _isEpisodesLoading = true.obs;
  final RxBool _isRelatedLoading = false.obs;
  List<NewMovieModel> _episodes = [];
  List<NewMovieModel> _relatedMovies = [];

  //────────────────────────────
  // Services & Controllers
  //────────────────────────────
  final MovieService _movieService = MovieService();
  final MainController _mainController = Get.find<MainController>();

  @override
  void initState() {
    super.initState();

    // Initialize colors from your custom theme.
    _accentColor = CustomTheme.accent;
    _primaryColor = CustomTheme.background;
    _textColor = Colors.white;
    _textMutedColor = Colors.white70;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Start loading movie details.
    _movieDetailsFuture = _loadMovieDetails();
    _movieDetailsFuture
        .then((movie) {
          isDownloadCheck(movie);
          if (movie != null && mounted) {
            _movie = movie;
            _isSeries = movie.type.toLowerCase() == "series";
            _fadeController.forward();
            // For series, load episodes using category_id and sort by episode_number.
            if (_isSeries) _loadEpisodes(movie.category_id);
            // For movies, load related movies.
            if (!_isSeries) _loadRelatedMovies(movie.id.toString());
          }
        })
        .catchError((error) {
          print("Error loading movie details: $error");
        });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  //────────────────────────────
  // Data Loading Methods
  //────────────────────────────

  bool isDownloaded = false;

  Future<NewMovieModel?> _loadMovieDetails() async {
    if (widget.params.containsKey('movie') &&
        widget.params['movie'] is NewMovieModel) {
      return widget.params['movie'] as NewMovieModel;
    } else if (widget.params.containsKey('movie_id')) {
      try {
        return await _movieService.getMovieDetails(
          widget.params['movie_id'].toString(),
        );
      } catch (e) {
        _showErrorSnackbar("Load Error", "Could not load movie details.");
        rethrow;
      }
    } else {
      throw Exception("No valid movie data or ID provided.");
    }
  }

  /// Load episodes based on the category_id.
  Future<void> _loadEpisodes(String categoryId) async {
    _isEpisodesLoading.value = true;
    try {
      List<NewMovieModel> eps = await _movieService.getMovieEpisodes(
        categoryId,
      );
      // Sort episodes by episode_number (assuming numeric strings)
      /*eps.sort(
        (a, b) => int.tryParse(
          a.episode_number ?? '0',
        )!.compareTo(int.tryParse(b.episode_number ?? '0')!),
      );
      setState(() {
        _episodes = eps;
      });*/
    } catch (e) {
      _showErrorSnackbar(
        "Load Error",
        "Could not load episodes. ${e.toString()}",
      );
    } finally {
      _isEpisodesLoading.value = false;
    }
  }

  /// Load related movies (for non-series movies).
  Future<void> _loadRelatedMovies(String currentMovieId) async {
    _isRelatedLoading.value = true;
    try {
      ManifestModel? manifest = _mainController.manifestModel.value;
      if (manifest == null) {
        final data = await ManifestService().getManifest();
        manifest = ManifestModel.fromJson(data);
      }
      List<NewMovieModel> allMovies =
          manifest.lists.expand((list) => list.movies).toList();
      allMovies.removeWhere((m) => m.id.toString() == currentMovieId);
      allMovies.shuffle();
      setState(() {
        _relatedMovies = allMovies.take(12).toList();
      });
    } catch (e) {
      print("Error loading related movies: $e");
    } finally {
      _isRelatedLoading.value = false;
    }
  }

  //────────────────────────────
  // Build Method
  //────────────────────────────
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: _primaryColor,
      body: FutureBuilder<NewMovieModel?>(
        future: _movieDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _MovieDetailShimmer(
              accentColor: _accentColor,
              primaryColor: _primaryColor,
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            return _buildErrorView(textTheme);
          } else {
            final movie = snapshot.data!;
            return FadeTransition(
              opacity: _fadeAnimation,
              child: _buildMainContent(movie, textTheme),
            );
          }
        },
      ),
    );
  }

  Widget _buildMainContent(NewMovieModel movie, TextTheme textTheme) {
    // For series, we do not show the "You Might Also Like" section.
    return RefreshIndicator(
      onRefresh: () async {
        _fadeController.reset();
        setState(() {
          _movieDetailsFuture = _loadMovieDetails();
        });
        final reloadedMovie = await _movieDetailsFuture;
        if (reloadedMovie != null && mounted) {
          setState(() {
            _movie = reloadedMovie;
            _isSeries = reloadedMovie.type.toLowerCase() == "series";
            _episodes.clear();
            _relatedMovies.clear();
          });
          _fadeController.forward();
          if (_isSeries) {
            _loadEpisodes(reloadedMovie.category_id);
          } else {
            _loadRelatedMovies(reloadedMovie.id.toString());
          }
        }
      },
      color: _accentColor,
      backgroundColor: _primaryColor,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          _buildSliverAppBar(movie, textTheme),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: _kVerticalPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMovieMetadata(movie, textTheme),
                const SizedBox(height: _kVerticalPadding * 1.5),
                _buildActionButtons(movie, textTheme),
                true
                    ? Container()
                    : const SizedBox(height: _kVerticalPadding * 1.5),
                true ? Container() : _buildDescription(movie, textTheme),
                true ? Container() : _buildSectionDivider(),
              ]),
            ),
          ),
          // If the movie is a series, show vertical episode list.
          if (movie.type.toLowerCase() == "series")
            _buildVerticalEpisodesSection(textTheme)
          else
            _buildRelatedMoviesSection(textTheme),
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + _kVerticalPadding,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(NewMovieModel movie, TextTheme textTheme) {
    return SliverAppBar(
      expandedHeight: Get.height * 0.5,
      backgroundColor: _primaryColor,
      foregroundColor: _textColor,
      pinned: true,
      stretch: true,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      leading: _buildAppBarButton(
        icon: FeatherIcons.arrowLeft,
        onPressed: () => Get.back(),
      ),
      actions: [
        _buildAppBarButton(
          icon: FeatherIcons.heart,
          onPressed: () {
            _loadEpisodes(movie.category_id);
            return;
            Get.snackbar(
              'Favorite',
              'Favorite feature coming soon!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: _accentColor.withValues(alpha: 0.8),
              colorText: Colors.black,
            );
          },
        ),
        const SizedBox(width: 8),
        QuickReportButton(
          contentType: 'movie',
          contentId: movie.id.toString(),
          contentTitle: movie.title,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
        title: FxText(
          "${movie.title}${(_isSeries && (!movie.title.toLowerCase().contains("episode"))) ? " (Episode ${movie.episode_number})" : ""}",
          maxLines: 5,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: _textColor,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 3),
            ],
          ),
          overflow: TextOverflow.ellipsis,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: movie.getThumbnail(),
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 400),
              placeholder: (context, url) => Container(color: Colors.grey[900]),
              errorWidget:
                  (context, url, error) => const Image(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/bg.jpg'),
                  ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _primaryColor,
                    _primaryColor.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: const Alignment(0.0, 0.3),
                ),
              ),
            ),
          ],
        ),
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
          StretchMode.blurBackground,
        ],
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.yellow),
        ),
      ),
    );
  }

  Widget _buildMovieMetadata(NewMovieModel movie, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 0),

          // Movie ID and Report Card
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tag, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Movie ID: ${movie.id}',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Get.to(
                        () => ReportContentScreen(
                          initialContentType: 'movie',
                          initialContentId: movie.id.toString(),
                          initialContentTitle: movie.title,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flag, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Report',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: [
              if (movie.vj.isNotEmpty)
                _buildMetaChip(
                  FeatherIcons.mic,
                  movie.vj,
                  _accentColor,
                  isHighlighted: true,
                ),
              if (movie.year.isNotEmpty)
                _buildMetaChip(
                  FeatherIcons.calendar,
                  movie.year,
                  _textMutedColor,
                ),
              if (movie.genre.isNotEmpty)
                _buildMetaChip(FeatherIcons.film, movie.genre, _textMutedColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(
    IconData icon,
    String text,
    Color color, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isHighlighted
                ? _accentColor.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_kChipBorderRadius),
        border: Border.all(
          color:
              isHighlighted
                  ? _accentColor
                  : Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _accentColor),
          const SizedBox(width: 8),
          if (text.isNotEmpty)
            FxText.bodySmall(text, color: color, fontWeight: 600),
        ],
      ),
    );
  }

  Widget _buildActionButtons(NewMovieModel movie, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kHorizontalPadding),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Material(
                  color:
                      movie.watched_movie == 'Yes'
                          ? Colors.green
                          : Colors.yellow,
                  borderRadius: BorderRadius.circular(_kCardBorderRadius),
                  elevation: 3,
                  shadowColor: Colors.yellow.withValues(alpha: 0.4),
                  child: InkWell(
                    onTap:
                        () => Get.to(
                          () => VideoPlayerScreen({'video_item': movie}),
                          preventDuplicates: false,
                        ),
                    borderRadius: BorderRadius.circular(_kCardBorderRadius),
                    splashColor: Colors.black.withValues(alpha: 0.2),
                    highlightColor: Colors.black.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            FeatherIcons.playCircle,
                            color: Colors.black,
                            size: 25,
                          ),
                          const SizedBox(width: 10),

                          FxText(
                            movie.watched_movie == 'Yes'
                                ? 'Resume Watching'
                                : "Watch Now",
                            style: textTheme.titleSmall?.copyWith(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Material(
                color: CustomTheme.accent,
                borderRadius: BorderRadius.circular(_kCardBorderRadius),
                child: InkWell(
                  onTap: () {
                    Get.snackbar(
                      'Share',
                      'Sharing feature coming soon!',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  borderRadius: BorderRadius.circular(_kCardBorderRadius),
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  highlightColor: Colors.white.withValues(alpha: 0.1),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_kCardBorderRadius),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      FeatherIcons.share2,
                      color: _primaryColor,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Material(
                  color:
                      isDownloaded
                          ? Colors.green.shade500
                          : CustomTheme.primary,
                  borderRadius: BorderRadius.circular(_kCardBorderRadius),
                  elevation: 3,
                  shadowColor: Colors.yellow.withValues(alpha: 0.4),
                  child: InkWell(
                    onTap: () async {
                      if (isDownloaded) {
                        await Get.to(() => const DownloadListScreen());
                        isDownloadCheck(movie);
                        return;
                      }
                      start_downloading(movie);
                    },
                    borderRadius: BorderRadius.circular(_kCardBorderRadius),
                    splashColor: Colors.black.withValues(alpha: 0.2),
                    highlightColor: Colors.black.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isDownloaded
                                ? FeatherIcons.check
                                : FeatherIcons.download,
                            color: Colors.black,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          FxText.titleLarge(
                            isDownloaded ? "My Downloads" : "Download ",
                            style: textTheme.titleSmall?.copyWith(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Material(
                color: CustomTheme.accent,
                borderRadius: BorderRadius.circular(_kCardBorderRadius),
                child: InkWell(
                  onTap: () {
                    Get.snackbar(
                      'Share',
                      'Sharing feature coming soon!',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  borderRadius: BorderRadius.circular(_kCardBorderRadius),
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  highlightColor: Colors.white.withValues(alpha: 0.1),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CustomTheme.primary,
                      borderRadius: BorderRadius.circular(_kCardBorderRadius),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      FeatherIcons.heart,
                      color: _primaryColor,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(NewMovieModel movie, TextTheme textTheme) {
    final descriptionText =
        movie.description.trim().isNotEmpty
            ? movie.description.trim()
            : "No description available.";
    final bool needsTrimming = descriptionText.length > 50;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*    FxText("Synopsis",
              style: textTheme.titleMedium
                  ?.copyWith(color: _textColor, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),*/
          needsTrimming
              ? ReadMoreText(
                descriptionText,
                trimLines: 1,
                trimCollapsedText: ' Show more',
                trimExpandedText: ' Show less',
                colorClickableText: _accentColor,
                style: TextStyle(color: _textMutedColor),
              )
              : FxText(
                descriptionText,
                style: textTheme.bodyMedium?.copyWith(
                  color: _textMutedColor,
                  height: 1.6,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSectionDivider() {
    if (_isSeries) {
      return Column(
        children: [
          const SizedBox(height: 17),
          Row(
            children: [
              const SizedBox(width: 20),
              FxContainer(
                width: 8,
                height: 25,
                borderRadius: BorderRadius.circular(1),
                color: Colors.yellow,
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: FxText.titleLarge(
                  "Episodes (${_episodes.length})".toUpperCase(),
                  fontWeight: 700,
                  color: _accentColor,
                ),
              ),
            ],
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: _kVerticalPadding * 1.5,
        horizontal: _kHorizontalPadding * 1.5,
      ),
      child: Divider(
        color: Colors.white.withValues(alpha: 0.15),
        height: 1,
        thickness: 1,
      ),
    );
  }

  /// For movies of type "Series", build a vertical list of episodes.
  /// The episodes are sorted (by episode_number) and the current episode (matching _movie.id)
  /// is highlighted distinctly.
  Widget _buildVerticalEpisodesSection(TextTheme textTheme) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: _kHorizontalPadding,
        vertical: 0,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          // Show a shimmer placeholder if still loading episodes.
          if (_isEpisodesLoading.value) {
            return _buildEpisodeShimmerItem();
          }
          if (_episodes.isEmpty) return const SizedBox.shrink();
          NewMovieModel episode = _episodes[index];
          bool isSelected = (episode.id == _movie?.id);
          return _buildEpisodeListTile(
            episode,
            index + 1,
            textTheme,
            isSelected,
          );
        }, childCount: _episodes.isEmpty ? 10 : _episodes.length),
      ),
    );
  }

  /// Builds a single list tile for an episode.
  Widget _buildEpisodeListTile(
    NewMovieModel episode,
    int episodeNumber,
    TextTheme textTheme,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color:
            isSelected
                ? CustomTheme.accent.withValues(alpha: 0.2)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            // Navigate to the selected episode. Use Get.off to replace current detail.
            Get.off(
              () => MovieDetailScreen({'movie': episode}),
              preventDuplicates: false,
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Episode thumbnail.
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: episode.getThumbnail(),
                  height: 80,
                  width: 120,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) =>
                          ShimmerLoadingWidget(height: 80, width: 120),
                  errorWidget:
                      (context, url, error) => Container(
                        height: 80,
                        width: 120,
                        color: Colors.grey[850],
                        child: const Icon(
                          FeatherIcons.image,
                          color: Colors.white24,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 12),
              // Episode details.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FxText.bodyMedium(
                      "Episode $episodeNumber: ${episode.title}",
                      color: _textColor,
                      fontWeight: isSelected ? 800 : 600,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FxText.bodySmall(
                      "Episode ${episode.episode_number ?? ''}",
                      color: _textMutedColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shimmer placeholder for a single episode list tile.
  Widget _buildEpisodeShimmerItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ShimmerLoadingWidget(height: 80, width: 120),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoadingWidget(height: 16, width: double.infinity),
                const SizedBox(height: 4),
                ShimmerLoadingWidget(height: 14, width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// For non-series movies, build the "You Might Also Like" section.
  Widget _buildRelatedMoviesSection(TextTheme textTheme) {
    if (Platform.isIOS && !_isSeries) {
      return SliverPadding(
        padding: const EdgeInsets.only(bottom: _kVerticalPadding * 1.5),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: FxText.bodyMedium(
              "Related movies are not available on iOS.",
              style: textTheme.bodyMedium?.copyWith(color: _textMutedColor),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: _kVerticalPadding * 1.5),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kHorizontalPadding,
              ),
              child: FxText(
                "You Might Also Like",
                style: textTheme.titleMedium?.copyWith(
                  color: _accentColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: (Get.width / 2.6) * 1.5 + 10,
              child:
                  _isRelatedLoading.value
                      ? _buildRelatedMoviesShimmer()
                      : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _relatedMovies.length,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: _kHorizontalPadding,
                        ),
                        itemBuilder: (context, index) {
                          NewMovieModel relatedMovie = _relatedMovies[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              right:
                                  index < _relatedMovies.length - 1
                                      ? 14.0
                                      : 0.0,
                            ),
                            child: _buildRelatedMovieCard(
                              relatedMovie,
                              textTheme,
                            ),
                          );
                        },
                      ),
            ),
            if (_relatedMovies.isNotEmpty) _buildSectionDivider(),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedMovieCard(
    NewMovieModel relatedMovie,
    TextTheme textTheme,
  ) {
    double cardWidth = Get.width / 2.6;
    double cardHeight = cardWidth * 1.5;
    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Material(
        color: Colors.white.withValues(alpha: 0.05),
        shadowColor: Colors.black.withValues(alpha: 0.2),
        elevation: 1.5,
        borderRadius: BorderRadius.circular(_kCardBorderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Get.off(
              () => MovieDetailScreen({'movie': relatedMovie}),
              preventDuplicates: false,
            );
          },
          borderRadius: BorderRadius.circular(_kCardBorderRadius),
          splashColor: _accentColor.withValues(alpha: 0.15),
          highlightColor: _accentColor.withValues(alpha: 0.1),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: relatedMovie.getThumbnail(),
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(color: Colors.grey[850]),
                errorWidget:
                    (context, url, error) => const Image(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/bg.jpg'),
                    ),
                fadeInDuration: const Duration(milliseconds: 300),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    stops: const [0.0, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FxText(
                      relatedMovie.title,
                      style: textTheme.bodyMedium?.copyWith(
                        color: _textColor,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    if (relatedMovie.vj.isNotEmpty ||
                        relatedMovie.genre.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            FeatherIcons.mic,
                            color: CustomTheme.accent,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: FxText(
                              relatedMovie.vj.isNotEmpty
                                  ? relatedMovie.vj
                                  : relatedMovie.genre,
                              style: textTheme.bodySmall?.copyWith(
                                color: _accentColor,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //────────────────────────────
  // Shimmer Placeholders and Error Widgets
  //────────────────────────────
  Widget _buildRelatedMoviesShimmer() {
    double cardWidth = Get.width / 2.6;
    double cardHeight = cardWidth * 1.5;
    final shimmerBaseColor = Colors.white.withValues(alpha: 0.08);
    final shimmerHighlightColor = Colors.white.withValues(alpha: 0.12);
    return Padding(
      padding: const EdgeInsets.only(bottom: _kVerticalPadding * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _kHorizontalPadding,
            ),
            child: Container(
              height: 22,
              width: 180,
              decoration: BoxDecoration(
                color: shimmerBaseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: cardHeight + 10,
            child: Shimmer.fromColors(
              baseColor: shimmerBaseColor,
              highlightColor: shimmerHighlightColor,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: _kHorizontalPadding,
                ),
                itemBuilder:
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(right: 14.0),
                      child: Container(
                        width: cardWidth,
                        height: cardHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            _kCardBorderRadius,
                          ),
                        ),
                      ),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(_kHorizontalPadding * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FeatherIcons.alertOctagon,
              color: Colors.redAccent.withValues(alpha: 0.8),
              size: 54,
            ),
            const SizedBox(height: 20),
            FxText(
              "Something Went Wrong",
              style: textTheme.titleLarge?.copyWith(
                color: _textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            FxText(
              "We couldn't load the movie details. Please check your connection and try again.",
              style: textTheme.bodyMedium?.copyWith(color: _textMutedColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            FxButton.outlined(
              onPressed: () => Get.back(),
              borderColor: _accentColor.withValues(alpha: 0.7),
              borderRadiusAll: _kCardBorderRadius,
              splashColor: _accentColor.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: FxText('Go Back', color: _accentColor, fontWeight: 600),
            ),
          ],
        ),
      ),
    );
  }

  //────────────────────────────
  // End of Build Methods
  //────────────────────────────

  void _showErrorSnackbar(String title, String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
      icon: const Icon(FeatherIcons.alertCircle, color: Colors.white, size: 20),
    );
  }

  Future<void> start_downloading(NewMovieModel movie) async {
    //get platform type

    //get phone download directory
    Directory? dir = await Utils.getMyRealDownload();
    if (dir == null) {
      Utils.toast("Failed to access download path. ");
      return;
    }
    // Prepare the MovieDownload record:
    MovieDownload md = MovieDownload.fromJson(movie.toJson());
    md.status = "enqueued";
    md.created_at = DateTime.now().toIso8601String();
    md.updated_at = DateTime.now().toIso8601String();
    md.user_id = _mainController.loggedInUser.id.toString();
    md.movie_model_id = movie.id.toString();
    md.watch_progress = "0";
    md.title = movie.make_title();
    md.url = movie.get_video_url();
    md.image_url = movie.getThumbnail();
    md.local_image_url = movie.getThumbnail();
    md.thumbnail_url = movie.getThumbnail();
    md.description = movie.description;
    md.genre = movie.genre;
    md.vj = movie.vj;
    md.download_started_at = DateTime.now().toIso8601String().toString();
    md.content_type = movie.content_type;
    md.content_is_video = movie.content_is_video;
    // md.episode_number = movie.episode_number;
    md.is_premium = '${dir.path}/${md.title}';
    md.id = movie.id;

    md.local_video_link = '${dir.path}/${md.title}';
    String? taskId = await Utils.downloadFile(md.url, dir.path, md.title);
    if (taskId == null) {
      Utils.toast("Failed to download ", color: Colors.red);
      return;
    }
    md.local_id = taskId;
    md.local_text = md.local_id;

    //if taskId emtry
    if (taskId.isEmpty) {
      Utils.toast(
        "Download task ID is empty. Please check your download settings.",
      );
      return;
    }

    md.movie_model_text = taskId;
    md.user_text = taskId;

    try {
      await md.save();
    } catch (e) {
      Utils.toast("Failed to start download: $e");
      return;
    }

    await isDownloadCheck(movie);
    setState(() {});
    // If desired: navigate to the download‐list screen here:
    // Get.to(() => const DownloadListScreen());
  }

  Future<void> isDownloadCheck(NewMovieModel? movie) async {
    if (movie == null) {
      return;
    }
    List<MovieDownload> downlaods = await MovieDownload.get_items(
      where: ' movie_model_id = ${movie.id} ',
    );
    if (downlaods.isNotEmpty) {
      isDownloaded = true;
    } else {
      isDownloaded = false;
    }
    setState(() {});
  }
}

///────────────────────────────
/// Placeholder for MovieService.
/// Replace this with your actual API calls.
///────────────────────────────
class MovieService {
  Future<NewMovieModel?> getMovieDetails(String movieId) async {
    print("Fetching details for movie ID: $movieId");
    await Future.delayed(const Duration(seconds: 1));

    return null; // For demonstration
  }

  bool loadingEpisodes = false;

  Future<List<NewMovieModel>> getMovieEpisodes(String categoryId) async {
    //get movies by category_id

    Utils.toast("Loading Episodes...");

    List<NewMovieModel> fetched = [];

    return fetched;
  }
}

///────────────────────────────
/// Dedicated shimmer widget for the movie detail screen.
///────────────────────────────
class _MovieDetailShimmer extends StatelessWidget {
  final Color accentColor;
  final Color primaryColor;

  const _MovieDetailShimmer({
    required this.accentColor,
    required this.primaryColor,
  });

  static const double _kHorizontalPadding = 20.0;
  static const double _kVerticalPadding = 16.0;
  static const double _kCardBorderRadius = 16.0;
  static const double _kChipBorderRadius = 10.0;

  Widget _buildShimmerBox({
    required double height,
    double? width,
    double radius = 4.0,
  }) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shimmerBaseColor = Colors.white.withValues(alpha: 0.08);
    final shimmerHighlightColor = Colors.white.withValues(alpha: 0.12);

    return Shimmer.fromColors(
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: Get.height * 0.5, color: Colors.white),
            const SizedBox(height: _kVerticalPadding * 1.5),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kHorizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(
                    height: 30,
                    width: Get.width * 0.75,
                    radius: 6,
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: List.generate(
                      3,
                      (index) => _buildShimmerBox(
                        height: 32,
                        width: 90.0 + (index * 15),
                        radius: _kChipBorderRadius,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _kVerticalPadding * 1.5),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kHorizontalPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildShimmerBox(
                      height: 54,
                      radius: _kCardBorderRadius,
                    ),
                  ),
                  const SizedBox(width: 14),
                  _buildShimmerBox(
                    width: 54,
                    height: 54,
                    radius: _kCardBorderRadius,
                  ),
                ],
              ),
            ),
            const SizedBox(height: _kVerticalPadding * 1.5),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kHorizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(height: 22, width: 140, radius: 4),
                  const SizedBox(height: 12),
                  _buildShimmerBox(
                    height: 15,
                    width: double.infinity,
                    radius: 4,
                  ),
                  const SizedBox(height: 8),
                  _buildShimmerBox(
                    height: 15,
                    width: double.infinity,
                    radius: 4,
                  ),
                  const SizedBox(height: 8),
                  _buildShimmerBox(
                    height: 15,
                    width: Get.width * 0.65,
                    radius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: _kVerticalPadding * 2.5),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kHorizontalPadding,
              ),
              child: _buildShimmerBox(height: 22, width: 170, radius: 4),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: _kHorizontalPadding,
                ),
                itemBuilder:
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(right: 14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerBox(
                            height: 95,
                            width: 170,
                            radius: _kCardBorderRadius,
                          ),
                          const SizedBox(height: 10),
                          _buildShimmerBox(height: 10, width: 140, radius: 4),
                          const SizedBox(height: 6),
                          _buildShimmerBox(height: 10, width: 90, radius: 4),
                        ],
                      ),
                    ),
              ),
            ),
            const SizedBox(height: _kVerticalPadding * 2),
          ],
        ),
      ),
    );
  }
}
