/**
 * Controller Disposal Enhancement Utility - BUG-2 Implementation
 * 
 * This utility helps ensure proper disposal of controllers, streams,
 * and other resources to prevent memory leaks.
 */

import 'dart:async';
import 'package:flutter/material.dart';

/// Enhanced base controller class with automatic resource management
abstract class EnhancedController {
  final List<VoidCallback> _disposers = [];
  final List<Timer> _timers = [];
  final List<StreamSubscription> _subscriptions = [];
  final List<AnimationController> _animationControllers = [];
  final List<TextEditingController> _textControllers = [];
  final List<ScrollController> _scrollControllers = [];

  /// Register a disposer function
  void registerDisposer(VoidCallback disposer) {
    _disposers.add(disposer);
  }

  /// Register a timer for automatic disposal
  void registerTimer(Timer timer) {
    _timers.add(timer);
  }

  /// Register a stream subscription for automatic disposal
  void registerSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Register an animation controller for automatic disposal
  void registerAnimationController(AnimationController controller) {
    _animationControllers.add(controller);
  }

  /// Register a text editing controller for automatic disposal
  void registerTextController(TextEditingController controller) {
    _textControllers.add(controller);
  }

  /// Register a scroll controller for automatic disposal
  void registerScrollController(ScrollController controller) {
    _scrollControllers.add(controller);
  }

  /// Dispose all registered resources
  void dispose() {
    // Cancel all timers
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Dispose animation controllers
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    _animationControllers.clear();

    // Dispose text controllers
    for (final controller in _textControllers) {
      controller.dispose();
    }
    _textControllers.clear();

    // Dispose scroll controllers
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    _scrollControllers.clear();

    // Call all registered disposers
    for (final disposer in _disposers) {
      try {
        disposer();
      } catch (e) {
        // Continue disposing other resources
        print('Error disposing resource: $e');
      }
    }
    _disposers.clear();
  }

  /// Get resource statistics
  Map<String, int> getResourceStats() {
    return {
      'timers': _timers.length,
      'subscriptions': _subscriptions.length,
      'animation_controllers': _animationControllers.length,
      'text_controllers': _textControllers.length,
      'scroll_controllers': _scrollControllers.length,
      'custom_disposers': _disposers.length,
    };
  }
}

/// Enhanced StatefulWidget mixin for automatic resource management
mixin ResourceManagementMixin<T extends StatefulWidget> on State<T> {
  final EnhancedController _resourceController = _ResourceController();

  /// Register a timer for automatic disposal
  void registerTimer(Timer timer) {
    _resourceController.registerTimer(timer);
  }

  /// Register a stream subscription for automatic disposal
  void registerSubscription(StreamSubscription subscription) {
    _resourceController.registerSubscription(subscription);
  }

  /// Register an animation controller for automatic disposal
  void registerAnimationController(AnimationController controller) {
    _resourceController.registerAnimationController(controller);
  }

  /// Register a text editing controller for automatic disposal
  void registerTextController(TextEditingController controller) {
    _resourceController.registerTextController(controller);
  }

  /// Register a scroll controller for automatic disposal
  void registerScrollController(ScrollController controller) {
    _resourceController.registerScrollController(controller);
  }

  /// Register a custom disposer function
  void registerDisposer(VoidCallback disposer) {
    _resourceController.registerDisposer(disposer);
  }

  @override
  void dispose() {
    _resourceController.dispose();
    super.dispose();
  }

  /// Get resource statistics
  Map<String, int> getResourceStats() {
    return _resourceController.getResourceStats();
  }
}

/// Internal resource controller implementation
class _ResourceController extends EnhancedController {}

/// Memory-efficient dispose checker utility
class DisposeChecker {
  static final Map<String, DateTime> _disposeTimestamps = {};
  static final Map<String, Map<String, int>> _resourceCounts = {};

  /// Record disposal of a resource type
  static void recordDisposal(String screenName, String resourceType) {
    _disposeTimestamps['${screenName}_$resourceType'] = DateTime.now();

    _resourceCounts.putIfAbsent(screenName, () => {});
    _resourceCounts[screenName]!.update(
      resourceType,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  }

  /// Get disposal statistics
  static Map<String, dynamic> getDisposalStats() {
    return {
      'total_disposals': _disposeTimestamps.length,
      'disposal_by_screen': _resourceCounts,
      'recent_disposals': _getRecentDisposals(),
    };
  }

  /// Get recent disposals (last 10 minutes)
  static List<String> _getRecentDisposals() {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 10));
    return _disposeTimestamps.entries
        .where((entry) => entry.value.isAfter(cutoff))
        .map((entry) => entry.key)
        .toList();
  }

  /// Clear old disposal records
  static void clearOldRecords() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    _disposeTimestamps.removeWhere(
      (key, timestamp) => timestamp.isBefore(cutoff),
    );
  }
}

/// Enhanced widget lifecycle manager
class WidgetLifecycleManager {
  static final Map<String, DateTime> _creationTimes = {};
  static final Map<String, Duration> _lifespans = {};

  /// Record widget creation
  static void recordCreation(String widgetName) {
    _creationTimes[widgetName] = DateTime.now();
  }

  /// Record widget disposal and calculate lifespan
  static void recordDisposal(String widgetName) {
    final creationTime = _creationTimes[widgetName];
    if (creationTime != null) {
      final lifespan = DateTime.now().difference(creationTime);
      _lifespans[widgetName] = lifespan;
      _creationTimes.remove(widgetName);
    }
  }

  /// Get widget lifecycle statistics
  static Map<String, dynamic> getLifecycleStats() {
    final avgLifespan =
        _lifespans.values.isNotEmpty
            ? _lifespans.values
                    .map((d) => d.inMilliseconds)
                    .reduce((a, b) => a + b) /
                _lifespans.length
            : 0.0;

    return {
      'active_widgets': _creationTimes.length,
      'total_disposed': _lifespans.length,
      'average_lifespan_ms': avgLifespan,
      'longest_lifespan_ms':
          _lifespans.values.isNotEmpty
              ? _lifespans.values
                  .map((d) => d.inMilliseconds)
                  .reduce((a, b) => a > b ? a : b)
              : 0,
    };
  }
}

/// Lazy loading helper for large lists
class LazyLoadingHelper {
  static const int _defaultPageSize = 20;
  static const double _defaultLoadThreshold = 0.8;

  /// Create a lazy loading paginated list
  static Widget createLazyList<T>({
    required List<T> items,
    required Widget Function(BuildContext context, T item, int index)
    itemBuilder,
    VoidCallback? onLoadMore,
    bool hasMore = false,
    int pageSize = _defaultPageSize,
    double loadThreshold = _defaultLoadThreshold,
    Widget? loadingWidget,
    ScrollController? controller,
  }) {
    return LazyListView<T>(
      items: items,
      itemBuilder: itemBuilder,
      onLoadMore: onLoadMore,
      hasMore: hasMore,
      pageSize: pageSize,
      loadThreshold: loadThreshold,
      loadingWidget: loadingWidget,
      controller: controller,
    );
  }
}

/// Lazy list view implementation
class LazyListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final int pageSize;
  final double loadThreshold;
  final Widget? loadingWidget;
  final ScrollController? controller;

  const LazyListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.pageSize = 20,
    this.loadThreshold = 0.8,
    this.loadingWidget,
    this.controller,
  });

  @override
  State<LazyListView<T>> createState() => _LazyListViewState<T>();
}

class _LazyListViewState<T> extends State<LazyListView<T>>
    with ResourceManagementMixin {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    registerScrollController(_scrollController);
    _scrollController.addListener(_onScroll);

    WidgetLifecycleManager.recordCreation('LazyListView<$T>');
  }

  @override
  void dispose() {
    WidgetLifecycleManager.recordDisposal('LazyListView<$T>');
    DisposeChecker.recordDisposal('LazyListView', 'scroll_controller');
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || _isLoadingMore) return;

    final threshold =
        _scrollController.position.maxScrollExtent * widget.loadThreshold;
    if (_scrollController.position.pixels >= threshold) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    widget.onLoadMore?.call();

    // Reset loading state after a delay (this would be handled by the parent widget)
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      addAutomaticKeepAlives: false, // Improve memory usage
      addRepaintBoundaries: false, // Reduce widget tree depth
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          // Loading indicator for pagination
          return widget.loadingWidget ??
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }
}

/// Performance monitoring utilities
class PerformanceMonitor {
  static final Map<String, Stopwatch> _stopwatches = {};
  static final Map<String, Duration> _measurements = {};

  /// Start timing an operation
  static void startTiming(String operationName) {
    _stopwatches[operationName] = Stopwatch()..start();
  }

  /// Stop timing an operation and record the duration
  static Duration stopTiming(String operationName) {
    final stopwatch = _stopwatches[operationName];
    if (stopwatch != null) {
      stopwatch.stop();
      final duration = stopwatch.elapsed;
      _measurements[operationName] = duration;
      _stopwatches.remove(operationName);
      return duration;
    }
    return Duration.zero;
  }

  /// Get performance measurements
  static Map<String, Duration> getMeasurements() {
    return Map.from(_measurements);
  }

  /// Clear all measurements
  static void clearMeasurements() {
    _measurements.clear();
    _stopwatches.clear();
  }

  /// Get average timing for an operation
  static Duration? getAverageTiming(String operationName) {
    // This would track multiple measurements and return average
    return _measurements[operationName];
  }
}
