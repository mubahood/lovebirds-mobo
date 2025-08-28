import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/screens/shop/screens/shop/MoviesSearchScreen.dart';
import 'package:lovebirds_app/utils/AppConfig.dart';
import 'package:lovebirds_app/utils/CustomTheme.dart';
import 'package:lovebirds_app/utils/SizeConfig.dart';

import '../../../../../../models/ManifestModel.dart';
import '../../../../../../models/ManifestService.dart';
import '../../../../../../models/NewMovieModel.dart';
import '../../../../../gardens/VideoPlayerScreen.dart';

class SectionDashboardNew extends StatefulWidget {
  const SectionDashboardNew({Key? key}) : super(key: key);

  @override
  _SectionDashboardNewState createState() => _SectionDashboardNewState();
}

class _SectionDashboardNewState extends State<SectionDashboardNew> {
  late Future<ManifestModel> futureManifest;
  final ManifestService manifestService = ManifestService();
  String cat = "";
  String selectedVJ = "";

  @override
  void initState() {
    super.initState();
    futureManifest = manifestService
        .getManifest()
        .then((json) => ManifestModel.fromJson(json));
    // Optionally, initialize other controllers or services here.
  }

  Future<void> doRefresh() async {
    setState(() {
      futureManifest = manifestService
          .getManifest()
          .then((json) => ManifestModel.fromJson(json));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.primary,
      body: FutureBuilder<ManifestModel>(
          future: futureManifest,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: Text("⌛ Loading...",
                      style: TextStyle(color: Colors.white)));
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text("Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.white)));
            }
            if (!snapshot.hasData) {
              return const Center(
                  child:
                      Text("No data", style: TextStyle(color: Colors.white)));
            }
            ManifestModel manifest = snapshot.data!;
            return mainWidget(manifest);
          }),
    );
  }

  Widget mainWidget(ManifestModel manifest) {
    return Column(
      children: [
        // Top header with search and filter buttons.
        Container(
          color: CustomTheme.primary,
          padding:
              const EdgeInsets.only(left: 10, right: 15, top: 18, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: const Icon(FeatherIcons.home,
                    color: CustomTheme.accent, size: 30),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: FxContainer(
                  onTap: () {
                    Get.to(() => const MoviesSearchScreen({}));
                  },
                  color: CustomTheme.primary,
                  bordered: true,
                  borderRadiusAll: 8,
                  borderColor: CustomTheme.accent,
                  margin: const EdgeInsets.only(left: 5),
                  padding: const EdgeInsets.only(left: 5, top: 8, bottom: 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 2),
                      const Icon(FeatherIcons.search,
                          color: CustomTheme.accent, size: 18),
                      const SizedBox(width: 5),
                      FxText(
                        'Search Luganda translated movies...',
                        fontWeight: 400,
                        color: CustomTheme.color,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  showBottomSheetCategoryPicker();
                },
                child: const Icon(FeatherIcons.mic,
                    color: CustomTheme.accent, size: 35),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ),
        // If a VJ filter is active, show a bar indicating the filter.
        cat.isEmpty
            ? const SizedBox()
            : FxContainer(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: FxText.bodySmall("Filter by VJ: $cat",
                          fontWeight: 900, color: Colors.black),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          cat = '';
                        });
                        doRefresh();
                      },
                      child: const Icon(FeatherIcons.x,
                          color: CustomTheme.accent, size: 20),
                    ),
                  ],
                ),
              ),
        // Main content: using RefreshIndicator & CustomScrollView to display sections.
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: RefreshIndicator(
              onRefresh: doRefresh,
              color: CustomTheme.primary,
              backgroundColor: Colors.white,
              child: CustomScrollView(
                slivers: [
                  // First section: Top movie carousel (glass style)
                  SliverToBoxAdapter(
                    child: buildTopMovieCarousel(manifest.top_movie),
                  ),
                  // Next section: For each category (List of Lists) from manifest.lists
                  ...manifest.lists.map((categoryList) {
                    return SliverToBoxAdapter(
                      child: buildMovieCategorySection(categoryList),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
        // Cart info at the bottom if any items exist; otherwise, nothing.
        // (Assuming mainController.cartItems still exists; if not, adjust accordingly.)
        // For demonstration, we leave this as-is.
      ],
    );
  }

  /// Builds a top movie carousel using glass UI style.
  Widget buildTopMovieCarousel(List<NewMovieModel> topMovies) {
    if (topMovies.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: CarouselSlider(
        items: topMovies.map((movie) => buildMovieCardGlass(movie)).toList(),
        options: CarouselOptions(
          height: 220,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.85,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
        ),
      ),
    );
  }

  /// Builds a category section with a title and a horizontal list of movies.
  Widget buildMovieCategorySection(MovieCategoryList categoryList) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              categoryList.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          // Horizontal list of movies for this category.
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categoryList.movies.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                NewMovieModel movie = categoryList.movies[index];
                // Cycle through five UI styles for variety.
                switch (index % 5) {
                  case 0:
                    return buildMovieCardGlass(movie);
                  case 1:
                    return buildMovieGridTile(movie);
                  case 2:
                    return buildMovieListTile(movie);
                  case 3:
                    return buildMovieTileOverlay(movie);
                  case 4:
                    return buildMovieAvatarTile(movie);
                  default:
                    return buildMovieCardGlass(movie);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// UI Style 1: Glassmorphism Card
  Widget buildMovieCardGlass(NewMovieModel movie) {
    return GestureDetector(
      onTap: () => Get.to(() => VideoPlayerScreen({'video_item': movie})),
      child: Container(
        width: Get.width * 0.8,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: movie.thumbnail_url ?? "",
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => Container(
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                      color: CustomTheme.accent),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.white),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Text(
                  movie.title ?? "",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// UI Style 2: Grid Tile Style
  Widget buildMovieGridTile(NewMovieModel movie) {
    return GestureDetector(
      onTap: () => Get.to(() => VideoPlayerScreen({'video_item': movie})),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: movie.thumbnail_url ?? "",
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                      color: CustomTheme.accent),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                movie.title ?? "",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }

  /// UI Style 3: Horizontal List Tile with Side Image
  Widget buildMovieListTile(NewMovieModel movie) {
    return GestureDetector(
      onTap: () => Get.to(() => VideoPlayerScreen({'video_item': movie})),
      child: Container(
        width: Get.width * 0.9,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: movie.thumbnail_url ?? "",
                width: 100,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                    child:
                        CircularProgressIndicator(color: CustomTheme.accent)),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title ?? "",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.genre ?? "",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// UI Style 4: Tile with Image and Overlay Text
  Widget buildMovieTileOverlay(NewMovieModel movie) {
    return GestureDetector(
      onTap: () => Get.to(() => VideoPlayerScreen({'video_item': movie})),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: CachedNetworkImageProvider(movie.thumbnail_url ?? ""),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.85),
                Colors.transparent,
              ],
            ),
          ),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.bottomLeft,
          child: Text(
            movie.title ?? "",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  /// UI Style 5: Circular Avatar with Title
  Widget buildMovieAvatarTile(NewMovieModel movie) {
    return GestureDetector(
      onTap: () => Get.to(() => VideoPlayerScreen({'video_item': movie})),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage:
                CachedNetworkImageProvider(movie.thumbnail_url ?? ""),
            backgroundColor: Colors.grey[800],
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 80,
            child: Text(
              movie.title ?? "",
              style: const TextStyle(color: Colors.white, fontSize: 12),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }

  /// Bottom sheet for filtering by VJ.
  void showBottomSheetCategoryPicker() {
    showModalBottomSheet(
      context: context,
      barrierColor: CustomTheme.primary.withValues(alpha: 0.5),
      builder: (BuildContext buildContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(MySize.size16),
              topRight: Radius.circular(MySize.size16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FxText.titleMedium('Filter by VJ', color: Colors.black),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                        child: const Icon(FeatherIcons.x, color: Colors.red),
                      )
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: AppConfig.VJs.length,
                    itemBuilder: (context, position) {
                      String data = AppConfig.VJs[position];
                      return ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            cat = data;
                          });
                          // Optionally, refetch manifest with filter.
                          doRefresh();
                        },
                        title: FxText.titleMedium(
                          data,
                          color: CustomTheme.primary,
                          maxLines: 1,
                          fontWeight: 700,
                        ),
                        trailing: cat != data
                            ? const SizedBox()
                            : const Icon(Icons.check_circle,
                                color: CustomTheme.primary, size: 30),
                        visualDensity: VisualDensity.compact,
                        dense: true,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
