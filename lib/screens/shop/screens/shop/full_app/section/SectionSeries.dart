import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lovebirds_app/models/NewMovieModel.dart';
import 'package:lovebirds_app/screens/shop/screens/shop/movies/MovieDetailScreen.dart';
import 'package:lovebirds_app/utils/CustomTheme.dart';

class SectionSeries extends StatefulWidget {
  const SectionSeries({Key? key}) : super(key: key);

  @override
  State<SectionSeries> createState() => _SectionSeriesState();
}

class _SectionSeriesState extends State<SectionSeries> {
  static const int _perPage = 50;
  static const double _cardHeight = 200.0;
  static const double _cardRadius = 16.0;

  final ScrollController _ctrl = ScrollController();
  final List<NewMovieModel> _episodes = [];

  bool _loading = false;
  bool _initial = true;
  bool _hasMore = true;
  int _page = 1;
  String? _error;

  late Color _accent, _primary, _shimmerBase, _shimmerHighlight;

  @override
  void initState() {
    super.initState();
    _accent = CustomTheme.accent;
    _primary = CustomTheme.primary;
    _shimmerBase = Colors.grey[850]!;
    _shimmerHighlight = Colors.grey[800]!;

    _fetchSeries(refresh: true);
    _ctrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_loading &&
        _hasMore &&
        _ctrl.position.pixels > _ctrl.position.maxScrollExtent - 300) {
      _fetchSeries();
    }
  }

  Future<void> _fetchSeries({bool refresh = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      if (refresh) {
        _initial = true;
        _page = 1;
        _hasMore = true;
        _episodes.clear();
        _error = null;
      }
    });

    try {
      final fetched = await NewMovieModel.getMoviesOnline(
        page: _page,
        perPage: _perPage,
        typeFilter: 'Series',
        isFirstEpisode: 'yes',
      );
      if (!mounted) return;
      setState(() {
        _episodes.addAll(fetched);
        _hasMore = fetched.length == _perPage;
        if (_hasMore) _page++;
      });
    } catch (e) {
      setState(() => _error = "Couldn't load series.");
      Get.snackbar(
        "Error",
        _error!,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _initial = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final txt = Theme.of(context).textTheme;
    return Scaffold(

      appBar: AppBar(

        title: Row(
          children: [
            const FxContainer(
              width: 12,
              color: CustomTheme.secondary,
              height: 25,
            ),
            const SizedBox(
              width: 10,
            ),
            FxText.titleLarge(
              "Series",
              fontWeight: 900,
              color: CustomTheme.accent,
            ),
          ],
        ),
        elevation: 1,
      ),
      body: RefreshIndicator(
        color: _accent,
        onRefresh: () => _fetchSeries(refresh: true),
        child: _buildBody(txt),
      ),
    );
  }

  Widget _buildBody(TextTheme txt) {
    if (_initial) return _buildShimmer();
    if (_error != null && _episodes.isEmpty) return _buildError();
    if (!_loading && _episodes.isEmpty) return _buildEmpty();

    return ListView.builder(
      controller: _ctrl,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _episodes.length + (_hasMore ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i == _episodes.length) return _buildLoader();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildSeriesCard(_episodes[i], txt),
        );
      },
    );
  }

  Widget _buildSeriesCard(NewMovieModel m, TextTheme txt) {
    return SizedBox(
      height: _cardHeight,
      child: Card(
        color: Colors.black,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Get.to(() => MovieDetailScreen({'movie': m})),
          child: Stack(children: [
            // Background image
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: m.getThumbnail(),
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: _shimmerBase),
                errorWidget: (_, __, ___) => Container(color: _shimmerBase),
              ),
            ),
            // Dark gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.8)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // SERIES badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CustomTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FxText.bodySmall(
                  "SERIES",
                  color: Colors.white,
                  fontWeight: 700,
                ),
              ),
            ),
            // Title & play icon
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: FxText.bodyLarge(
                      m.category,
                      color: Colors.white,
                      fontWeight: 800,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FeatherIcons.play,
                      color: _accent,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildShimmer() => Shimmer.fromColors(
        baseColor: _shimmerBase,
        highlightColor: _shimmerHighlight,
        child: ListView.builder(
          itemCount: 5,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: _cardHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_cardRadius),
              ),
            ),
          ),
        ),
      );

  Widget _buildLoader() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              color: _accent,
              strokeWidth: 3.5,
            ),
          ),
        ),
      );

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(FeatherIcons.alertCircle,
                color: Colors.redAccent, size: 50),
            const SizedBox(height: 16),
            FxText.titleMedium("Oops!", color: _accent, fontWeight: 700),
            const SizedBox(height: 8),
            FxText(_error!, color: Colors.white70, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FxButton.outlined(
              onPressed: () => _fetchSeries(refresh: true),
              borderColor: _accent,
              borderRadiusAll: 8,
              child: FxText("Retry", color: _accent),
            ),
          ]),
        ),
      );

  Widget _buildEmpty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(FeatherIcons.film, size: 60, color: Colors.white30),
            const SizedBox(height: 16),
            FxText.titleMedium("No series found",
                color: Colors.white70, fontWeight: 600),
            const SizedBox(height: 8),
            FxText("Check back later!", color: Colors.white54),
            const SizedBox(height: 16),
            FxButton.outlined(
              onPressed: () => _fetchSeries(refresh: true),
              borderColor: _accent,
              borderRadiusAll: 8,
              child: FxText("Refresh", color: _accent),
            ),
          ]),
        ),
      );
}
