import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lovebirds_app/models/LoggedInUserModel.dart';

import '../../models/RespondModel.dart';
import '../../models/UserModel.dart';
import '../../utils/AppConfig.dart';
import '../../utils/CustomTheme.dart';
import '../../utils/Utilities.dart';
import '../../widget/widgets.dart';
import '../shop/screens/shop/chat/chat_screen.dart';
import 'ProfileViewScreen.dart';
import 'SwipeScreen.dart';
import 'WhoLikedMeScreen.dart';
import 'MatchesScreen.dart';

enum ViewType { list, grid, swipe }

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({Key? key}) : super(key: key);

  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final _scrollC = ScrollController();
  late PageController _pageC;

  List<UserModel> _all = [];
  bool _loading = true, _moreLoading = false;
  bool _showSearch = false, _onlineOnly = false, _verifiedOnly = false;
  String search = '';
  int _page = 1, _perPage = 20;
  bool _hasMore = true;

  ViewType _viewType = ViewType.list;

  Timer? _debounce;

  Future<void> completedProfile() async {
    LoggedInUserModel l = await LoggedInUserModel.getLoggedInUser();
    if (l.sex.length < 2) {
      Utils.shouldCompletedProfile(context);
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageC = PageController(viewportFraction: 0.85);
    _loadPage();
    _scrollC.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollC.dispose();
    _pageC.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // debounce 500ms
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _page = 1;
      _hasMore = true;
      _all.clear();
      _loadPage();
    });
  }

  LoggedInUserModel loggedUser = LoggedInUserModel();

  Future<void> _loadPage({bool refresh = false}) async {
    completedProfile();
    Utils.checkUpdate();
    completedProfile();
    loggedUser = await LoggedInUserModel.getLoggedInUser();
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _all.clear();
    }
    if (!_hasMore) return;

    setState(() {
      if (_all.isEmpty)
        _loading = true;
      else
        _moreLoading = true;
    });

    // build API params
    final params = {
      'page': _page.toString(),
      'per_page': _perPage.toString(),
      if (search.isNotEmpty) 'search': search,
      if (_onlineOnly) 'online_only': 'yes',
      if (_verifiedOnly) 'email_verified': 'yes',
    };

    // fetch from server
    final raw = await Utils.http_get(UserModel.endPoint, params);

    final resp = RespondModel(raw);

    List<UserModel> items = [];
    if (resp.code == 1 &&
        resp.data is Map<String, dynamic> &&
        resp.data['data'] is List) {
      items =
          (resp.data['data'] as List)
              .map((m) => UserModel.fromJson(m))
              .toList();
    }

    setState(() {
      _all.addAll(items);
      _loading = false;
      _moreLoading = false;
      if (items.length < _perPage)
        _hasMore = false;
      else
        _page++;
    });
  }

  void _onScroll() {
    if (_scrollC.position.pixels > _scrollC.position.maxScrollExtent - 200 &&
        !_moreLoading &&
        _hasMore) {
      _loadPage();
    }
  }

  Future<void> _onRefresh() async {
    _page = 1;
    _hasMore = true;
    _all.clear();
    await _loadPage();
  }

  void _toggleSearch() => setState(() {
    _showSearch = !_showSearch;
    if (!_showSearch) {
      search = '';
      _onRefresh();
    }
  });

  void _openFilterSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.grey[900],
      context: context,
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FxText.titleMedium('Filters', color: Colors.white),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: FxText.bodyMedium('Online only', color: Colors.white),
                  value: _onlineOnly,
                  activeColor: CustomTheme.primary,
                  onChanged: (v) => setState(() => _onlineOnly = v),
                ),
                SwitchListTile(
                  title: FxText.bodyMedium(
                    'Email verified',
                    color: Colors.white,
                  ),
                  value: _verifiedOnly,
                  activeColor: CustomTheme.primary,
                  onChanged: (v) => setState(() => _verifiedOnly = v),
                ),
                const SizedBox(height: 8),
                FxButton.small(
                  backgroundColor: CustomTheme.primary,
                  onPressed: () {
                    Navigator.pop(context);
                    _onRefresh();
                  },
                  child: FxText.bodyMedium('APPLY', color: Colors.white),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: RefreshIndicator(
                color: CustomTheme.primary,
                onRefresh: _onRefresh,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child:
                      _loading
                          ? _buildShimmer()
                          : Stack(
                            children: [
                              _buildBody(),
                              Positioned(
                                bottom: 0,
                                right: 10,
                                child: Column(
                                  children:
                                      ViewType.values.map((vt) {
                                        IconData icon;
                                        switch (vt) {
                                          case ViewType.grid:
                                            icon = Icons.grid_view;
                                            break;
                                          case ViewType.swipe:
                                            icon = Icons.swipe;
                                            break;
                                          case ViewType.list:
                                            icon = FeatherIcons.users;
                                        }
                                        final active = _viewType == vt;
                                        return FxContainer(
                                          padding: const EdgeInsets.all(10),
                                          width: 50,
                                          height: 50,
                                          margin: EdgeInsets.only(bottom: 8),
                                          color:
                                              active
                                                  ? CustomTheme.primary
                                                  : CustomTheme.accent,
                                          borderRadiusAll: 100,
                                          child: GestureDetector(
                                            onTap:
                                                () => setState(
                                                  () => _viewType = vt,
                                                ),
                                            child: Icon(
                                              icon,
                                              size: active ? 30 : 30,
                                              color:
                                                  active
                                                      ? CustomTheme.accent
                                                      : Colors.black,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  _showSearch
                      ? TextField(
                        key: const ValueKey('search'),
                        onChanged: (v) {
                          search = v;
                          _onSearchChanged();
                        },
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: CustomTheme.primary,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 0,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Search users…',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          filled: true,
                          fillColor: Colors.grey[800],
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.yellow[700],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )
                      : _buildViewToggle(),
            ),
          ),
          if (_viewType == ViewType.swipe) ...[
            // Likes received button
            IconButton(
              icon: Icon(
                Icons.favorite_border,
                color: CustomTheme.primary,
                size: 28,
              ),
              onPressed: () => Get.to(() => const WhoLikedMeScreen()),
            ),
            // Matches button
            IconButton(
              icon: Icon(Icons.people, color: CustomTheme.primary, size: 28),
              onPressed: () => Get.to(() => const MatchesScreen()),
            ),
          ],
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              color: CustomTheme.accent,

              size: 30,
            ),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: CustomTheme.accent, size: 30),
            onPressed: _openFilterSheet,
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: FxText.titleLarge(
        "Connect",
        fontWeight: 800,
        color: CustomTheme.accent,
        maxLines: 1,
      ),
    );
  }

  Widget _buildBody() {
    if (_all.isEmpty) {
      return Column(
        children: [
          Spacer(),
          Center(
            child: FxText.bodyMedium(
              'No users found.',
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          //show loader
          Spacer(),
        ],
      );
    }
    switch (_viewType) {
      case ViewType.grid:
        return _buildGrid();
      case ViewType.swipe:
        return _buildSwipe();
      case ViewType.list:
        return _buildList();
    }
  }

  Widget _buildList() {
    return ListView.builder(
      controller: _scrollC,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _all.length + (_hasMore ? 1 : 0),
      itemBuilder: (c, i) {
        if (i == _all.length && _hasMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(color: CustomTheme.primary),
            ),
          );
        }
        if (i >= _all.length) return null;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 200 + i * 15),
          builder:
              (_, v, child) => Opacity(
                opacity: v,
                child: Transform.translate(
                  offset: Offset((1 - v) * 40, 0),
                  child: child,
                ),
              ),
          child: _buildTile(_all[i]),
        );
      },
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      controller: _scrollC,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3 / 4.2, // <-- Changed from 4 to 4.2
      ),
      itemCount: _all.length + (_hasMore ? 1 : 0),
      itemBuilder: (c, i) {
        if (i == _all.length && _hasMore) {
          return Center(
            child: CircularProgressIndicator(color: CustomTheme.primary),
          );
        }
        if (i >= _all.length) return null;
        return _buildCard(_all[i]);
      },
    );
  }

  Widget _buildSwipe() {
    // Navigate to the comprehensive SwipeScreen
    return const SwipeScreen();
  }

  Widget _buildTile(UserModel u) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: CustomTheme.primary.withValues(alpha: 0.3),
          onTap: () {
            /* open profile */
            Get.to(() => ProfileViewScreen(u));
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildAvatar(u, size: 56),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.bodyLarge(
                        u.name.isNotEmpty ? u.name : u.username,
                        color: Colors.white,
                        fontWeight: 700,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (u.occupation.isNotEmpty)
                        FxText.bodySmall(
                          u.occupation,
                          color: CustomTheme.color,
                        ),
                      if (u.city.isNotEmpty || u.state.isNotEmpty)
                        FxText.bodySmall(
                          [
                            if (u.city.isNotEmpty) u.city,
                            if (u.state.isNotEmpty) u.state,
                          ].join(', '),
                          color: CustomTheme.color,
                        ),
                      FxText.bodySmall(
                        u.online_status,
                        color: CustomTheme.color2,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.white70),
                  onPressed: () => startChat(u),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(UserModel u, {bool large = false}) {
    return Material(
      elevation: large ? 4 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      color: Colors.grey[850],
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      // This clips the child (the image) to the border radius
      child: InkWell(
        onTap: () {
          Get.to(() => ProfileViewScreen(u));
        },
        splashColor: CustomTheme.primary.withValues(alpha: 0.3),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: The User Image
            CachedNetworkImage(
              imageUrl: Utils.getImageUrl(u.avatar),
              fit: BoxFit.cover,

              errorWidget:
                  (_, __, ___) =>
                      Image.asset(AppConfig.NO_IMAGE, fit: BoxFit.cover),
            ),
            // Layer 2: The protective gradient for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.4], // Gradient covers bottom 40%
                ),
              ),
            ),
            // Layer 3: The user's name and status indicators
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Online status indicator
                  if (u.isOnline)
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                    ),
                  // User's name
                  Expanded(
                    child: FxText.bodyLarge(
                      u.name.isNotEmpty ? u.name : u.username,
                      color: Colors.white,
                      fontWeight: 700,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Verified status indicator
                  if (u.email_verified == 'yes')
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.blueAccent,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(UserModel u, {double size = 40}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: CachedNetworkImage(
            imageUrl: Utils.getImageUrl(u.avatar),
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder:
                (_, __) => ShimmerLoadingWidget(height: size, width: size),
            errorWidget:
                (_, __, ___) => Image.asset(
                  AppConfig.NO_IMAGE,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
          ),
        ),
        if (u.isOnline)
          Positioned(
            top: 0,
            right: 0,

            child: Container(
              width: size * 0.30,
              height: size * 0.30,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[850]!, width: 2),
              ),
            ),
          ),
        if (u.email_verified == 'yes')
          Positioned(
            bottom: 0,
            right: 0,
            child: Icon(
              Icons.check_circle,
              size: size * 0.3,
              color: Colors.blueAccent,
            ),
          ),
      ],
    );
  }

  void startChat(UserModel u) {
    Get.to(
      () => ChatScreen({
        'task': 'START_CHAT',
        'receiver_id': u.id.toString(),
        'receiver': u,
      }),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[600]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: 6,
        itemBuilder:
            (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(width: 56, height: 56, color: Colors.grey[800]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14, color: Colors.grey[800]),
                        const SizedBox(height: 6),
                        Container(
                          height: 12,
                          width: 150,
                          color: Colors.grey[800],
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
}
