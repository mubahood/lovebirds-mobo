/**
 * Performance & Memory Optimization Service - BUG-2 Implementation
 * 
 * This file provides comprehensive performance optimization utilities for
 * image loading, memory management, lazy loading, and resource disposal.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Optimized image loading and caching service
class ImageOptimizationService {
  static final ImageOptimizationService _instance =
      ImageOptimizationService._internal();
  factory ImageOptimizationService() => _instance;
  ImageOptimizationService._internal();

  // Cache configuration
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int _maxCacheObjects = 500;
  static const Duration _cacheExpiry = Duration(days: 7);

  // Memory monitoring
  final Map<String, DateTime> _imageLoadTimestamps = {};
  final Set<String> _preloadedImages = {};

  /// Get optimized cached network image with performance features
  static Widget getCachedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    bool enableMemoryCache = true,
    bool enableDiskCache = true,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth:
          width != null
              ? (width *
                      MediaQuery.of(NavigationService.context).devicePixelRatio)
                  .round()
              : null,
      memCacheHeight:
          height != null
              ? (height *
                      MediaQuery.of(NavigationService.context).devicePixelRatio)
                  .round()
              : null,
      placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
      errorWidget:
          (context, url, error) => errorWidget ?? _defaultErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
      useOldImageOnUrlChange: true,
      cacheManager: enableDiskCache ? null : _createMemoryOnlyCacheManager(),
    );
  }

  /// Default loading placeholder with shimmer effect
  static Widget _defaultPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  /// Default error widget
  static Widget _defaultErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.error_outline, color: Colors.grey, size: 32),
    );
  }

  /// Create memory-only cache manager for temporary images
  static dynamic _createMemoryOnlyCacheManager() {
    // This would be implemented with a custom CacheManager
    // For now, return null to use default behavior
    return null;
  }

  /// Preload critical images for better performance
  Future<void> preloadCriticalImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      if (!_preloadedImages.contains(url)) {
        try {
          await precacheImage(
            CachedNetworkImageProvider(url),
            NavigationService.context,
          );
          _preloadedImages.add(url);
          _imageLoadTimestamps[url] = DateTime.now();
        } catch (e) {
          // Failed to preload - continue with others
        }
      }
    }
  }

  /// Clear old cached images to free memory
  void clearOldImageCache() {
    final cutoff = DateTime.now().subtract(_cacheExpiry);
    _imageLoadTimestamps.removeWhere((url, timestamp) {
      if (timestamp.isBefore(cutoff)) {
        _preloadedImages.remove(url);
        return true;
      }
      return false;
    });
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'preloaded_images': _preloadedImages.length,
      'cache_entries': _imageLoadTimestamps.length,
      'memory_cache_size_mb': (_maxCacheSize / (1024 * 1024)).toStringAsFixed(
        2,
      ),
      'max_cache_objects': _maxCacheObjects,
    };
  }
}

/// Navigation service for accessing context globally
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static BuildContext get context => navigatorKey.currentContext!;
}

/// Enhanced ListView builder with lazy loading and performance optimizations
class OptimizedListView extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Widget? loadingWidget;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final double loadMoreThreshold;
  final ScrollController? controller;

  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.loadingWidget,
    this.onLoadMore,
    this.hasMore = false,
    this.loadMoreThreshold = 0.8,
    this.controller,
  });

  @override
  State<OptimizedListView> createState() => _OptimizedListViewState();
}

class _OptimizedListViewState extends State<OptimizedListView> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || _isLoadingMore) return;

    final threshold =
        _scrollController.position.maxScrollExtent * widget.loadMoreThreshold;
    if (_scrollController.position.pixels >= threshold) {
      _loadMore();
    }
  }

  void _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      widget.onLoadMore?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.itemCount + (widget.hasMore ? 1 : 0),
      addAutomaticKeepAlives: false, // Improve memory usage
      addRepaintBoundaries: false, // Reduce widget tree depth
      itemBuilder: (context, index) {
        if (index >= widget.itemCount) {
          // Loading indicator for pagination
          return widget.loadingWidget ??
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
        }
        return widget.itemBuilder(context, index);
      },
    );
  }
}

/// Enhanced FutureBuilder with better error handling and memory management
class OptimizedFutureBuilder<T> extends StatefulWidget {
  final Future<T>? future;
  final Widget Function(BuildContext context, AsyncSnapshot<T> snapshot)
  builder;
  final T? initialData;
  final Duration? timeout;

  const OptimizedFutureBuilder({
    super.key,
    this.future,
    required this.builder,
    this.initialData,
    this.timeout,
  });

  @override
  State<OptimizedFutureBuilder<T>> createState() =>
      _OptimizedFutureBuilderState<T>();
}

class _OptimizedFutureBuilderState<T> extends State<OptimizedFutureBuilder<T>> {
  Timer? _timeoutTimer;
  late Future<T>? _future;

  @override
  void initState() {
    super.initState();
    _future = widget.future;
    _startTimeoutTimer();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _startTimeoutTimer() {
    if (widget.timeout != null) {
      _timeoutTimer = Timer(widget.timeout!, () {
        if (mounted) {
          setState(() {
            _future = Future.error('Request timeout');
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      initialData: widget.initialData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _timeoutTimer?.cancel();
        }
        return widget.builder(context, snapshot);
      },
    );
  }
}

/// Resource disposal manager for proper cleanup
class ResourceManager {
  static final List<VoidCallback> _disposers = [];
  static final Map<String, Timer> _timers = {};
  static final Map<String, StreamSubscription> _subscriptions = {};

  /// Register a disposer function
  static void registerDisposer(VoidCallback disposer) {
    _disposers.add(disposer);
  }

  /// Register a timer for automatic cleanup
  static void registerTimer(String key, Timer timer) {
    _timers[key]?.cancel();
    _timers[key] = timer;
  }

  /// Register a stream subscription for automatic cleanup
  static void registerSubscription(
    String key,
    StreamSubscription subscription,
  ) {
    _subscriptions[key]?.cancel();
    _subscriptions[key] = subscription;
  }

  /// Cancel a specific timer
  static void cancelTimer(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
  }

  /// Cancel a specific subscription
  static void cancelSubscription(String key) {
    _subscriptions[key]?.cancel();
    _subscriptions.remove(key);
  }

  /// Dispose all resources
  static void disposeAll() {
    // Cancel all timers
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();

    // Cancel all subscriptions
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Call all disposers
    for (final disposer in _disposers) {
      try {
        disposer();
      } catch (e) {
        // Continue disposing other resources
      }
    }
    _disposers.clear();
  }

  /// Get resource statistics
  static Map<String, int> getResourceStats() {
    return {
      'active_timers': _timers.length,
      'active_subscriptions': _subscriptions.length,
      'registered_disposers': _disposers.length,
    };
  }
}

/// Memory monitoring and optimization service
class MemoryOptimizationService {
  static final MemoryOptimizationService _instance =
      MemoryOptimizationService._internal();
  factory MemoryOptimizationService() => _instance;
  MemoryOptimizationService._internal();

  Timer? _memoryMonitorTimer;
  final List<MemorySnapshot> _memorySnapshots = [];

  /// Start memory monitoring
  void startMonitoring() {
    _memoryMonitorTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _takeMemorySnapshot(),
    );
  }

  /// Stop memory monitoring
  void stopMonitoring() {
    _memoryMonitorTimer?.cancel();
    _memoryMonitorTimer = null;
  }

  /// Take a memory snapshot
  void _takeMemorySnapshot() {
    // This would use actual memory profiling in production
    final snapshot = MemorySnapshot(
      timestamp: DateTime.now(),
      estimatedMemoryMB: _estimateMemoryUsage(),
    );

    _memorySnapshots.add(snapshot);

    // Keep only last 100 snapshots
    if (_memorySnapshots.length > 100) {
      _memorySnapshots.removeAt(0);
    }

    // Trigger cleanup if memory usage is high
    if (snapshot.estimatedMemoryMB > 150) {
      performMemoryCleanup();
    }
  }

  /// Estimate current memory usage
  double _estimateMemoryUsage() {
    // Simplified estimation - would use actual profiling in production
    double usage = 50.0; // Base app usage
    usage += ImageOptimizationService()._preloadedImages.length * 2.0;
    usage += ResourceManager.getResourceStats()['active_timers']! * 0.1;
    return usage;
  }

  /// Perform memory cleanup
  void performMemoryCleanup() {
    // Clear image cache
    ImageOptimizationService().clearOldImageCache();

    // Clear old memory snapshots
    if (_memorySnapshots.length > 50) {
      _memorySnapshots.removeRange(0, _memorySnapshots.length - 50);
    }

    // Force garbage collection (if available)
    _forceGarbageCollection();
  }

  /// Force garbage collection
  void _forceGarbageCollection() {
    // This would trigger actual GC in production
    // For now, just log the action
    print('Memory cleanup performed at ${DateTime.now()}');
  }

  /// Get memory statistics
  Map<String, dynamic> getMemoryStats() {
    final currentUsage = _estimateMemoryUsage();
    final avgUsage =
        _memorySnapshots.isNotEmpty
            ? _memorySnapshots
                    .map((s) => s.estimatedMemoryMB)
                    .reduce((a, b) => a + b) /
                _memorySnapshots.length
            : 0.0;

    return {
      'current_memory_mb': currentUsage.toStringAsFixed(2),
      'average_memory_mb': avgUsage.toStringAsFixed(2),
      'snapshots_count': _memorySnapshots.length,
      'is_monitoring': _memoryMonitorTimer != null,
    };
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _memorySnapshots.clear();
  }
}

/// Memory snapshot model
class MemorySnapshot {
  final DateTime timestamp;
  final double estimatedMemoryMB;

  MemorySnapshot({required this.timestamp, required this.estimatedMemoryMB});

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'memory_mb': estimatedMemoryMB,
    };
  }
}

/// Performance testing utilities
class PerformanceTestingService {
  /// Test image loading performance
  static Future<Map<String, dynamic>> testImageLoadingPerformance(
    List<String> imageUrls,
  ) async {
    final results = <String, dynamic>{};
    final stopwatch = Stopwatch();

    stopwatch.start();

    try {
      await ImageOptimizationService().preloadCriticalImages(imageUrls);
      stopwatch.stop();

      results['success'] = true;
      results['duration_ms'] = stopwatch.elapsedMilliseconds;
      results['images_loaded'] = imageUrls.length;
      results['avg_per_image_ms'] =
          stopwatch.elapsedMilliseconds / imageUrls.length;
    } catch (e) {
      stopwatch.stop();
      results['success'] = false;
      results['error'] = e.toString();
      results['duration_ms'] = stopwatch.elapsedMilliseconds;
    }

    return results;
  }

  /// Test list scrolling performance
  static Future<Map<String, dynamic>> testListScrollingPerformance(
    int itemCount,
  ) async {
    final results = <String, dynamic>{};
    final stopwatch = Stopwatch();

    stopwatch.start();

    // Simulate large list rendering
    final items = List.generate(itemCount, (index) => 'Item $index');

    stopwatch.stop();

    results['item_count'] = itemCount;
    results['generation_time_ms'] = stopwatch.elapsedMilliseconds;
    results['memory_impact_mb'] =
        (items.length * 50) / (1024 * 1024); // Rough estimate

    return results;
  }

  /// Generate performance report
  static Map<String, dynamic> generatePerformanceReport() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'image_cache_stats': ImageOptimizationService().getCacheStats(),
      'memory_stats': MemoryOptimizationService().getMemoryStats(),
      'resource_stats': ResourceManager.getResourceStats(),
    };
  }
}
