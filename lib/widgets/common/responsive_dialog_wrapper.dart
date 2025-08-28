import 'package:flutter/material.dart';
import '../../utils/CustomTheme.dart';

/// A responsive dialog wrapper that handles screen overflow and ensures
/// all dialog content is accessible on any screen size
class ResponsiveDialogWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final double? maxHeight;
  final double? maxWidth;
  final bool enableScrolling;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const ResponsiveDialogWrapper({
    Key? key,
    required this.child,
    this.margin,
    this.maxHeight,
    this.maxWidth,
    this.enableScrolling = true,
    this.backgroundColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Calculate responsive dimensions
    final dialogMaxHeight = maxHeight ?? screenSize.height * 0.85;
    final dialogMaxWidth =
        maxWidth ?? (screenSize.width > 600 ? 500.0 : screenSize.width * 0.92);

    // Calculate responsive margins
    final horizontalMargin = screenSize.width > 600 ? 32.0 : 16.0;
    final verticalMargin =
        (screenSize.height > 800 ? 24.0 : 12.0) +
        (keyboardHeight > 0 ? 8.0 : 0.0);

    final responsiveMargin =
        margin ??
        EdgeInsets.symmetric(
          horizontal: horizontalMargin,
          vertical: verticalMargin,
        );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: responsiveMargin,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: dialogMaxHeight - keyboardHeight,
          maxWidth: dialogMaxWidth,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? CustomTheme.card,
            borderRadius: borderRadius ?? BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.circular(24),
            child:
                enableScrolling
                    ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: child,
                    )
                    : child,
          ),
        ),
      ),
    );
  }
}

/// A responsive column wrapper for dialog content that handles overflow
class ResponsiveDialogColumn extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  const ResponsiveDialogColumn({
    Key? key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      ),
    );
  }
}

/// A responsive padding wrapper that adjusts to screen size
class ResponsiveDialogPadding extends StatelessWidget {
  final Widget child;
  final double? horizontal;
  final double? vertical;
  final double? all;

  const ResponsiveDialogPadding({
    Key? key,
    required this.child,
    this.horizontal,
    this.vertical,
    this.all,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding based on screen size
    final basePadding = all ?? 24.0;
    final responsivePadding =
        screenWidth > 600 ? basePadding : basePadding * 0.75;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal ?? responsivePadding,
        vertical: vertical ?? responsivePadding,
      ),
      child: child,
    );
  }
}
