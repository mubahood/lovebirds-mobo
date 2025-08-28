import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart'; // Assuming FxButton, FxContainer, FxText are used
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
// Assuming these paths are correct - adjust if needed
import 'package:lovebirds_app/controllers/MainController.dart';
import 'package:lovebirds_app/models/LoggedInUserModel.dart';
import 'package:lovebirds_app/models/ManifestModel.dart';
import 'package:lovebirds_app/models/ManifestService.dart';
import 'package:lovebirds_app/models/NewMovieModel.dart';
import 'package:lovebirds_app/screens/shop/models/ChatHead.dart';
import 'package:lovebirds_app/utils/AppConfig.dart'; // Assuming contains checkForUpdate
import 'package:lovebirds_app/utils/CustomTheme.dart';
import 'package:lovebirds_app/utils/app_theme.dart';

import '../../../../../../features/moderation/screens/moderation_home_screen.dart';
import '../../../../../../utils/Utilities.dart';
import '../../../../models/MovieDownload.dart';
import '../../MoviesSearchScreen.dart';
import '../../chat/ChatsScreen.dart';
import '../../movies/DownloadListScreen.dart';
import '../../movies/MovieDetailScreen.dart';
import '../../movies/MoviesListingScreen.dart';
import '../AppUpdateScreen.dart' as AppUpdateScreen;
import '../SectionResume.dart';
import 'SectionSeries.dart';

class SectionDashboard extends StatefulWidget {
  const SectionDashboard({super.key});

  @override
  _SectionDashboardState createState() => _SectionDashboardState();
}

class _SectionDashboardState extends State<SectionDashboard>
    with SingleTickerProviderStateMixin {
  // --- State Variables ---
  late ThemeData theme;
  final MainController mainController = Get.find<MainController>();
  final ManifestService manifestService = ManifestService();
  ManifestModel manifestModel = ManifestModel();
  late Future<void> _futureInit;
  String _selectedVjFilter = "";

  // --- Animation ---
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // --- Ads State ---
  // BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // --- Ad Unit IDs (Use Test IDs for Development) ---
  // TODO: Replace with your actual AdMob Ad Unit IDs before publishing!

  // --- Constants ---
  static const double _kHorizontalPadding = 18.0;
  static const double _kVerticalPadding = 14.0;
  static const double _kCardBorderRadius = 14.0;
  static const double _kHeroBorderRadius = 22.0;
  static const double _kChipBorderRadius = 18.0;

  @override
  void initState() {
    super.initState();
    theme = AppTheme.darkTheme; // Assuming this theme exists

    _checkNotificationPermission();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _startListening();
    _loadData();
    _loadBannerAd(); // Load the banner ad on init
  }

  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
    _animationController.dispose();
    // _bannerAd?.dispose(); // Dispose banner ad
    super.dispose();
  }

  // --- Data Loading ---
  void _loadData() {
    // AppConfig.checkForUpdate(); // Assuming this exists and is needed
    _futureInit = _initializeData();
    _futureInit
        .then((_) {
          if (mounted) {
            _animationController.forward();
          }
        })
        .catchError((_) {
          // Handle error
        });
  }

  Future<void> _refreshData() async {
    Utils.checkUpdate();
    _animationController.reset();
    // Optionally reload banner ad on refresh? Usually not necessary.
    // _loadBannerAd();
    setState(() {
      _futureInit = _initializeData(); // Re-run the initialization future
    });
    await _futureInit; // Wait for refresh to complete
    if (mounted) {
      _animationController.forward();
    }
    setState(() {});
  }

  Future<void> completedProfile() async {
    LoggedInUserModel l = await LoggedInUserModel.getLoggedInUser();
    if (l.sex.length < 2) {
      Utils.shouldCompletedProfile(context);
      return;
    }
    if (l.dob.length < 4) {
      Utils.shouldCompletedProfile(context);
      return;
    }

    if (l.country.length < 4) {
      Utils.shouldCompletedProfile(context);
      return;
    }
  }

  List<MovieDownload> downlaods = [];

  Future<void> _initializeData() async {
    try {
      final data = await manifestService.getManifest();

      manifestService.fetchManifestOnline();
      if (mounted) {
        manifestModel = ManifestModel.fromJson(data);
        if (manifestModel.APP_VERSION != 0) {
          if (manifestModel.APP_VERSION > AppConfig.APP_VERSION) {
            Utils.toast("New App Version Available.");
            Get.to(() => AppUpdateScreen.AppUpdateScreen(manifestModel));
          }
        }
        setState(() {});
      }
      downlaods = await MovieDownload.get_items();
      // await mainController.getMovies(); // Consider if needed
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to load content. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
      rethrow; // Rethrow for FutureBuilder error state
    }
  }

  // --- Ad Loading ---
  void _loadBannerAd() {}

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        // Main column for Header, Content, and Banner Ad
        children: [
          /*  FxText.bodyLarge(
            mainController.loggedInUser.name,
            color: CustomTheme.accent,
            fontWeight: 700,
          ),
*/
          // --- Header ---
          _buildHeaderBar(),
          // --- Main Content Area ---
          /* FxButton.block(
            onPressed: () async {
              Get.to(() => const MenuScreen());
            },
            child: FxText.titleLarge("OPEN MENU"),
          ),*/
          Expanded(
            child: FutureBuilder<void>(
              future: _futureInit,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Use a more thematic shimmer or loading indicator here
                  return _buildContentLoadingIndicator();
                } else if (snapshot.hasError) {
                  return _buildContentErrorView();
                } else {
                  // Content loaded successfully
                  return _buildMainContent();
                }
              },
            ),
          ),
          Visibility(visible: countUnread > 0, child: _buildDownloadsLink()),
        ],
      ),
    );
  }

  Widget _buildDownloadsLink() {
    return FxContainer(
      onTap: () async {
        Get.to(() => ChatsScreen());
      },
      borderRadiusAll: 0,
      color: Colors.green,
      padding: const EdgeInsets.only(left: 15, top: 0, bottom: 0, right: 15),
      child: Row(
        children: [
          const Icon(FeatherIcons.mail, color: Colors.white, size: 20),
          FxText.titleMedium(
            "You have ${countUnread} unread message${countUnread != 1 ? 's' : ''}.",
          ),
          const Spacer(),
          Icon(FeatherIcons.arrowRight, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _buildContentLoadingIndicator() {
    // You can replace this with a more elaborate shimmer effect
    // similar to the MovieDetailScreen shimmer if desired.
    return Center(
      child: CircularProgressIndicator(color: Colors.yellowAccent[700]),
    );
  }

  Widget _buildContentErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(FeatherIcons.wifiOff, color: Colors.white30, size: 48),
          const SizedBox(height: 16),
          FxText.bodyLarge('Could not connect', color: Colors.white70),
          FxText.bodySmall(
            'Please check your connection and retry',
            color: Colors.white54,
          ),
          const SizedBox(height: 24),
          FxButton.outlined(
            onPressed: _refreshData,
            borderColor: Colors.yellow.shade700,
            splashColor: Colors.yellowAccent[700]?.withValues(alpha: 0.2),
            borderRadiusAll: _kChipBorderRadius,
            child: FxText('Retry', color: Colors.yellowAccent[700]),
          ),
        ],
      ),
    );
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    } else {}
  }

  Widget _buildMainContent() {
    final textTheme = Theme.of(context).textTheme; // Get theme for consistency

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: CustomTheme.primary,
      backgroundColor: Colors.yellowAccent[700] ?? Colors.yellow,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // --- Top Hero Movie ---
          SliverPadding(
            padding: const EdgeInsets.only(
              left: _kHorizontalPadding,
              right: _kHorizontalPadding,
              top: _kVerticalPadding,
              bottom: _kVerticalPadding * 1.5,
            ),
            sliver: SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildTopMovieHero(
                  manifestModel.top_movie.isNotEmpty
                      ? manifestModel.top_movie[0]
                      : NewMovieModel(), // Handle empty case
                ),
              ),
            ),
          ),
          // --- Genres Section ---
          if (manifestModel.genres.isNotEmpty)
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildGenreSection(manifestModel.genres),
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(top: _kVerticalPadding)),

          // --- Movie Category Sections ---
          // TODO: Consider inserting Native Ads here periodically
          ...manifestModel.lists.where((list) => list.movies.isNotEmpty).map((
            list,
          ) {
            // int index = manifestModel.lists.indexOf(list); // Index for staggering?
            return SliverPadding(
              padding: const EdgeInsets.only(bottom: _kVerticalPadding * 1.8),
              sliver: SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildMovieCategorySection(list, textTheme),
                ),
              ),
            );
          }).toList(),

          // --- Browse All Button ---
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: _kHorizontalPadding * 1.5,
              vertical: _kVerticalPadding * 2,
            ),
            sliver: SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildBrowseAllButton(textTheme),
              ),
            ),
          ),

          // Add final padding at the very bottom (adjust if banner is present)
          // The SafeArea around the banner handles bottom padding when ad is ready
          // SliverPadding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom)),
        ],
      ),
    );
  }

  // --- Header, Search, Hero, Sections, Cards, Buttons (Keep implementations from previous version) ---
  // (Make sure to pass textTheme where appropriate for consistent styling)

  int countUnread = 0;
  String msgs_count = "0";

  bool is_loading = false;

  Future<void> _startListening() async {
    if (is_loading) {
      return;
    }
    is_loading = true;
    await mainController.getLoggedInUser();
    List<ChatHead> heads = await ChatHead.get_items(
      mainController.loggedInUser,
    );
    countUnread = 0;
    msgs_count = '0';
    for (var head in heads) {
      head.myUnread(mainController.loggedInUser);
      countUnread += head.myUnreadCount;
    }

    msgs_count = '$countUnread';
    if (countUnread > 9) {
      msgs_count = '9+';
    }
    setState(() {});

    if (isDisposed) return;
    // Re-poll
    await Future.delayed(const Duration(seconds: 5));
    is_loading = false;
    _startListening();
  }

  Widget _buildHeaderBar() {
    return Container(
      padding: EdgeInsets.only(
        left: _kHorizontalPadding,
        right: _kHorizontalPadding,
        top: MediaQuery.of(context).padding.top + _kVerticalPadding * 0.8,
        bottom: _kVerticalPadding * 0.8,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              Get.to(() => const ChatsScreen());
            } /*_showVjFilterBottomSheet*/,
            customBorder: const CircleBorder(),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FeatherIcons.mail,
                    color: Colors.yellow,
                    size: 24,
                  ),
                ),

                Positioned(
                  right: 0,
                  top: 3,
                  child: FxContainer(
                    padding: const EdgeInsets.only(top: 0),
                    alignment: Alignment.center,
                    color: CustomTheme.primary,
                    borderRadiusAll: 100,
                    width: 18,
                    height: 18,
                    child: Center(
                      child: FxText.bodySmall(
                        msgs_count,
                        color: Colors.white,
                        height: .8,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),
          Expanded(
            child: Container(
              height: 25,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [


                  FxContainer(
                    color: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    alignment: Alignment.center,
                    bordered: true,
                    onTap: () {
                      Get.to(() => const SectionResume());
                    },
                    borderRadiusAll: 20,
                    borderColor: Colors.green.shade900,
                    child: Row(
                      children: [
                        // play icon
                        const Icon(
                          FeatherIcons.play,
                          color: Colors.white,
                          size: 10,
                        ),
                        SizedBox(width: 5),
                        FxText.bodyMedium(
                          'RESUME'.toUpperCase(),
                          fontSize: 10,
                          fontWeight: 900,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  FxContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    alignment: Alignment.center,
                    bordered: true,
                    onTap: () {
                      Get.to(() => const SectionSeries());
                    },
                    borderRadiusAll: 20,
                    borderColor: CustomTheme.primary,
                    child: FxText.bodyMedium(
                      'Series Movies'.toUpperCase(),
                      fontSize: 10,
                      fontWeight: 900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  FxContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    alignment: Alignment.center,
                    bordered: true,
                    onTap: () {
                      Get.to(() => const DownloadListScreen());
                    },
                    borderRadiusAll: 20,
                    borderColor: CustomTheme.primary,
                    child: FxText.bodyMedium(
                      'My Downloads'.toUpperCase(),
                      fontSize: 10,
                      fontWeight: 900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  FxContainer(
                    color: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    alignment: Alignment.center,
                    bordered: true,
                    onTap: () {
                      Get.to(() => const ModerationHomeScreen());
                    },
                    borderRadiusAll: 20,
                    borderColor: Colors.red.shade900,
                    child: Row(
                      children: [
                        const Icon(
                          FeatherIcons.shield,
                          color: Colors.white,
                          size: 10,
                        ),
                        const SizedBox(width: 5),
                        FxText.bodyMedium(
                          'SAFETY'.toUpperCase(),
                          fontSize: 10,
                          fontWeight: 900,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          /*Expanded(
            child: _buildSearchBar(
              hint: 'Search movies, VJs...',
              onTap: () => Get.to(() => const MoviesSearchScreen({})),
            ),
          ),*/
          const SizedBox(width: 5),
          InkWell(
            onTap: () {
              Get.to(() => const MoviesSearchScreen({}));
            } /*_showVjFilterBottomSheet*/,
            customBorder: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FeatherIcons.search,
                color: Colors.yellow,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 5),
          // Moderation/Safety Button
          InkWell(
            onTap: () {
              Get.to(() => const ModerationHomeScreen());
            },
            customBorder: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FeatherIcons.shield,
                color: Colors.red,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar({required String hint, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: FxContainer(
        color: Colors.white.withValues(alpha: 0.1),
        bordered: false,
        borderRadiusAll: _kChipBorderRadius,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              FeatherIcons.search,
              color: Colors.yellow,
              size: 20,
            ), // Accent search icon
            const SizedBox(width: 10),
            Expanded(
              child: FxText(
                hint,
                fontWeight: 400,
                color: Colors.white70,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopMovieHero(NewMovieModel movie) {

    if (movie.id <= 0) {
      // Check for valid movie ID
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "No featured movie",
            style: TextStyle(color: Colors.white54),
          ),
        ),
      ); // Placeholder or empty state
    }
    return AspectRatio(
      aspectRatio: 16 / 9.5,
      child: FxContainer(
        borderRadiusAll: _kHeroBorderRadius,
        clipBehavior: Clip.antiAlias,
        bordered: true,
        borderColor: Colors.yellow,
        // Subtle accent border
        paddingAll: 0,
        child: InkWell(
          onTap: () => Get.to(() => MovieDetailScreen({'movie': movie})),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                // Ensure image respects border radius
                borderRadius: BorderRadius.circular(_kHeroBorderRadius - 1),
                // Inner radius for image
                child: CachedNetworkImage(
                  imageUrl: movie.getThumbnail(),
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(color: Colors.grey[900]),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(
                            FeatherIcons.image,
                            color: Colors.white24,
                            size: 48,
                          ),
                        ),
                      ),
                  fadeInDuration: const Duration(milliseconds: 400),
                ),
              ),
              Container(
                // Gradient
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_kHeroBorderRadius - 1),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.0, 0.7, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.95),
                      Colors.black.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                // Content
                bottom: _kVerticalPadding * 1.2,
                left: _kHorizontalPadding,
                right: _kHorizontalPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FxText.bodyLarge(
                      movie.title,
                      fontWeight: 800,
                      color: Colors.white,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (movie.vj.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FeatherIcons.mic,
                            color: Colors.yellow,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          FxText.bodyLarge(
                            movie.vj,
                            color: CustomTheme.accent,
                            fontWeight: 700,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    FxButton(
                      onPressed: () async {
                        Get.to(() => MovieDetailScreen({'movie': movie}));
                      },
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      backgroundColor: Colors.yellow,
                      borderRadiusAll: _kChipBorderRadius,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            FeatherIcons.play,
                            color: Colors.black,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          FxText.bodyMedium(
                            "Watch Now",
                            fontWeight: 900,
                            color: Colors.black,
                          ),
                        ],
                      ),
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

  Widget _buildGenreSection(List<String> genres) {
    return SizedBox(
      height: 38, // Slightly taller chips
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: _kHorizontalPadding),
        itemBuilder: (context, index) {
          String genre = genres[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < genres.length - 1 ? 10.0 : 0.0,
            ),
            child: FxButton.outlined(
              // Use outlined for genres
              onPressed:
                  () => Get.to(() => MoviesListingScreen({'genre': genre})),
              borderRadiusAll: _kChipBorderRadius,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              borderColor: Colors.yellow.withValues(alpha: 0.6),
              // Accent border
              splashColor: CustomTheme.accent.withValues(alpha: 0.1),
              child: FxText.bodyMedium(
                genre,
                color: Colors.yellow,
                fontWeight: 500,
              ), // Accent text
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieCategorySection(
    MovieCategoryList categoryList,
    TextTheme textTheme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _kHorizontalPadding,
          ).copyWith(bottom: _kVerticalPadding * 0.8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FxText(
                categoryList.title.isEmpty
                    ? "Featured Movies"
                    : categoryList.title,
                style: textTheme.titleLarge?.copyWith(
                  color: CustomTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // Use theme
              FxButton.text(
                onPressed: () {
                  if (categoryList.title == 'Continue Watching') {
                    //go to resume section
                    Get.to(() => const SectionResume());
                    return;
                  }
                  Get.to(
                    () => MoviesListingScreen({
                      'category': categoryList.title,
                      'movies': categoryList.movies,
                    }),
                  );
                },
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                splashColor: CustomTheme.accent.withValues(alpha: 0.1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FxText(
                      'View All',
                      color: CustomTheme.primary,
                      fontWeight: 600,
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      FeatherIcons.arrowRight,
                      color: CustomTheme.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          // Horizontal Movie List
          height: (Get.width / 2.8) * 1.5 + 10, // Adjust height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categoryList.movies.length,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: _kHorizontalPadding,
            ),
            itemBuilder: (context, index) {
              NewMovieModel movie = categoryList.movies[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < categoryList.movies.length - 1 ? 12.0 : 0.0,
                ),
                child: _buildMovieCard(movie, textTheme), // Pass theme
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(NewMovieModel item, TextTheme textTheme) {
    double cardWidth = Get.width / 2.8;
    double cardHeight = cardWidth * 1.5;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: FxContainer(
        borderRadiusAll: _kCardBorderRadius,
        paddingAll: 0,
        child: InkWell(
          onTap: () => Get.to(() => MovieDetailScreen({'movie': item})),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(_kCardBorderRadius),
                child: CachedNetworkImage(
                  imageUrl: item.getThumbnail(),
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(color: Colors.grey[850]),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[850],
                        child: const Center(
                          child: Icon(
                            FeatherIcons.film,
                            color: Colors.white24,
                            size: 30,
                          ),
                        ),
                      ),
                  fadeInDuration: const Duration(milliseconds: 300),
                ),
              ),
              Container(
                // Gradient
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_kCardBorderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    stops: const [0.0, 1.0],
                    colors: [
                      (item.watched_movie == 'Yes'
                              ? Colors.green
                              : Colors.black)
                          .withValues(alpha: 0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FxText(
                      item.title,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(FeatherIcons.mic, color: Colors.yellow, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: FxText(
                            item.vj.isNotEmpty
                                ? item.vj
                                : (item.genre.isNotEmpty ? item.genre : '-'),
                            style: textTheme.bodySmall?.copyWith(
                              color: CustomTheme.accent,
                              fontWeight: FontWeight.w700,
                            ),
                            // Use theme
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

  Widget _buildBrowseAllButton(TextTheme textTheme) {
    return FxButton(
      onPressed: () => Get.to(() => const MoviesListingScreen({})),
      elevation: 3,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.yellow,
      borderRadiusAll: _kChipBorderRadius * 1.5,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FeatherIcons.film, color: Colors.black, size: 20),
          const SizedBox(width: 10),
          FxText(
            "Browse All Movies",
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showVjFilterBottomSheet() {
    // Keep implementation from previous version
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext buildContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(_kHeroBorderRadius),
                  topRight: Radius.circular(_kHeroBorderRadius),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 5,
                    width: 45,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  _buildFilterBottomSheetHeader(),
                  ElevatedButton(
                    onPressed: () {
                      // Upgrader().checkVersion(context: context, showDialog: true),
                    },
                    child: const Text('Check for Updates'),
                  ),
                  const Divider(color: Colors.white12, height: 1, thickness: 1),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: AppConfig.VJs.length,
                      // Ensure AppConfig.VJs exists
                      itemBuilder: (context, position) {
                        String data = AppConfig.VJs[position];
                        bool isSelected = _selectedVjFilter == data;
                        return ListTile(
                          onTap: () {
                            setModalState(() {
                              _selectedVjFilter = data;
                            });
                            Navigator.pop(context);
                            Get.to(() => MoviesListingScreen({'vj': data}));
                          },
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: _kHorizontalPadding + 4,
                          ),
                          title: FxText.bodyLarge(
                            data,
                            color:
                                isSelected
                                    ? CustomTheme.accent
                                    : Colors.white.withValues(alpha: 0.8),
                            fontWeight: isSelected ? 700 : 500,
                          ),
                          trailing:
                              !isSelected
                                  ? null
                                  : Icon(
                                    FeatherIcons.checkCircle,
                                    color: CustomTheme.accent,
                                    size: 24,
                                  ),
                          dense: false,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 5),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterBottomSheetHeader() {
    // Keep implementation from previous version
    return Container(
      padding: EdgeInsets.only(
        left: _kHorizontalPadding,
        right: _kHorizontalPadding,
        bottom: _kVerticalPadding * 0.8,
        top: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FxText.titleLarge(
            'Filter by VJ',
            color: Colors.white,
            fontWeight: 700,
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            customBorder: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FeatherIcons.x,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
