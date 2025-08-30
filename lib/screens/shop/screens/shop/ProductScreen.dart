// lib/screens/shop/screens/shop/ProductScreen.dart

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../controllers/MainController.dart';
import '../../../../utils/AppConfig.dart';
import '../../../../utils/CustomTheme.dart';
import '../../../../utils/Utilities.dart';
import '../../models/CartItem.dart';
import '../../models/ImageModelLocal.dart';
import '../../models/Product.dart';
import 'cart/CartScreen.dart';
import 'chat/chat_screen.dart';

class ProductScreen extends StatefulWidget {
  final Product item;

  const ProductScreen(this.item, {Key? key}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState(item);
}

final MainController mainController = Get.find<MainController>();

class _ProductScreenState extends State<ProductScreen> {
  Product item;
  List<String> downloadedPics = [];
  String tempPath = '';
  CarouselSliderController _carouselController = CarouselSliderController();
  int _currentImageIndex = 0;
  int _quantity = 1;

  _ProductScreenState(this.item);

  @override
  void initState() {
    super.initState();
    item.getAttributes();
    _initialize();
  }

  List relatedProducts = [];

  Future<void> _initialize() async {
    await item.getOnlinePhotos();
    setState(() {});

    RxList<dynamic> tempPros = mainController.products;
    if (tempPros.isEmpty) {
      await mainController.getProducts();
      tempPros = mainController.products;
    }
    tempPros.shuffle();
    tempPros.shuffle();
    if (tempPros.length > 9) {
      relatedProducts = tempPros.sublist(0, 8);
    } else {
      relatedProducts = tempPros;
    }

    downloadedPics = await Utils.getDownloadPics();
    final dir = await getApplicationDocumentsDirectory();
    tempPath = dir.path;
    _downloadPics();
  }

  Future<void> _downloadPics() async {
    int x = 0;
    for (var pic in item.online_photos) {
      if (!downloadedPics.contains(pic.src)) {
        x++;
        pic.position = x;
        await Utils.downloadPhoto(pic.src);
        downloadedPics = await Utils.getDownloadPics();
      }
    }
    setState(() {});
  }

  Future<void> openPhotos(ImageModel pic) async {
    String imageName = pic.src.split('/').last;
    String imagePath = "";
    if (!downloadedPics.contains(imageName)) {
      Utils.toast("Just a minute...");
      await Utils.downloadPhoto(pic.src);
      downloadedPics = await Utils.getDownloadPics();

      Utils.toast("DOES NOT Exists...");
      for (var x in downloadedPics) {
        String imageName2 = x.replaceAll('images/', '').split('/').last;
        if (imageName.toLowerCase() == imageName2.toLowerCase()) {
          imageName = x;
          imagePath = "$tempPath/images/$imageName";
          break;
        }
      }
    } else {
      imagePath = "$tempPath/images/$imageName";
    }

    String path_1 = "$tempPath/$imageName";
    String path_2 = "$tempPath/images/$imageName";

    if (await File(path_1).exists()) {
      imagePath = path_1;
    } else {
      if (await File(path_2).exists()) {
        imagePath = path_2;
      }
    }

    if (imagePath.isEmpty) {
      Utils.toast(
        "Failed to find image. ${pic.src.replaceAll('images/', '').split('/').last}",
      );
      return;
    }

    ImageProvider imageProvider = FileImage(File(imagePath));
    showImageViewer(
      context,
      imageProvider,
      backgroundColor: CustomTheme.background,
      closeButtonColor: Colors.white,
      closeButtonTooltip: 'Close',
      doubleTapZoomable: true,
      useSafeArea: true,
      immersive: false,
      swipeDismissible: false,
    );
  }

  Future<bool> _addToCart() async {
    if (item.getColors().isNotEmpty) {
      if (cartItem.color.isEmpty) {
        Utils.toast("Please first select color");
        return false;
      }
    }

    if (item.getSizes().isNotEmpty) {
      if (cartItem.size.isEmpty) {
        Utils.toast("Please select size");
        return false;
      }
    }

    await mainController.addToCart(
      widget.item,
      color: cartItem.color,
      size: cartItem.size,
    );
    setState(() {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProductInfo(),
                _buildDescriptionSection(),
                _buildRelatedProducts(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: CustomTheme.background,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CustomTheme.card.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(FeatherIcons.arrowLeft, color: CustomTheme.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CustomTheme.card.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(FeatherIcons.share2, color: CustomTheme.accent),
            onPressed: _shareProduct,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(background: _buildImageCarousel()),
    );
  }

  Widget _buildImageCarousel() {
    final images =
        item.online_photos.isNotEmpty
            ? item.online_photos.map((e) => Utils.img(e.src)).toList()
            : [Utils.img(item.feature_photo)];

    return Stack(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          items:
              images
                  .map(
                    (imageUrl) => Container(
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder:
                            (_, __) => Container(
                              color: CustomTheme.card,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        errorWidget:
                            (_, __, ___) => Image.asset(
                              AppConfig.NO_IMAGE,
                              fit: BoxFit.cover,
                            ),
                      ),
                    ),
                  )
                  .toList(),
          options: CarouselOptions(
            height: 400,
            viewportFraction: 1.0,
            enableInfiniteScroll: images.length > 1,
            onPageChanged: (index, reason) {
              setState(() => _currentImageIndex = index);
            },
          ),
        ),

        // Image indicators
        if (images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  images
                      .asMap()
                      .entries
                      .map(
                        (entry) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _currentImageIndex == entry.key
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.titleLarge(
            "${item.name}",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            fontWeight: 600,
            color: CustomTheme.color,
          ),

          SizedBox(height: 15),

          // Price section
          Row(
            children: [
              FxText.titleLarge(
                Utils.money(item.price_1),
                color: CustomTheme.primary,
                fontWeight: 700,
              ),
              const SizedBox(width: 8),
              if (item.id % 4 == 0) // Mock discount
                FxText.bodyMedium(
                  'CAD \$${(double.parse(item.price_1.replaceAll(',', '')) * 1.25).toStringAsFixed(0)}',
                  color: Colors.grey[500],
                  decoration: TextDecoration.lineThrough,
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FeatherIcons.check,
                      size: 14,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 4),
                    FxText.bodySmall(
                      'In Stock',
                      color: Colors.green[700],
                      fontWeight: 600,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Size selection (mock)
          _buildSizeSelector(),

          // Color selection (mock)
          _buildColorSelector(),

          const SizedBox(height: 20),

          // Quantity selector
          _buildQuantitySelector(),

          const SizedBox(height: 20),

          // Chat with Admin Button
          _buildChatWithAdminButton(),
        ],
      ),
    );
  }

  CartItem cartItem = CartItem();

  Widget _buildSizeSelector() {
    return item.getSizes().isNotEmpty
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20, left: 0, right: 0),
              child: FxText.titleMedium(
                "Select size".toUpperCase(),
                color: CustomTheme.accent,
                fontWeight: 800,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.only(left: 0, right: 15),
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: item.getSizes().length,
                itemBuilder: (BuildContext context, int index) {
                  String size = item.getSizes()[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: FxContainer(
                      bordered: true,
                      onTap: () {
                        if (cartItem.size == size) {
                          cartItem.size = "";
                          setState(() {});
                          return;
                        }
                        cartItem.size = size;
                        if (cartItem.id > 0) {
                          cartItem.save();
                        }
                        setState(() {});
                      },
                      borderColor: CustomTheme.primary,
                      alignment: Alignment.center,
                      borderRadiusAll: 10,
                      color:
                          cartItem.size == size
                              ? CustomTheme.primary
                              : Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      child: Center(
                        child: FxText.bodyLarge(
                          size,
                          color:
                              cartItem.size == size
                                  ? Colors.white
                                  : Colors.black,
                          fontWeight: 900,
                          height: .8,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        )
        : const SizedBox();
  }

  Widget _buildColorSelector() {
    return item.getColors().isNotEmpty
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: FxText.titleMedium(
                "Select Colour".toUpperCase(),
                color: CustomTheme.accent,
                fontWeight: 800,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              height: 60,
              padding: const EdgeInsets.only(left: 0, right: 15),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: item.getColors().length,
                itemBuilder: (BuildContext context, int index) {
                  String color = item.getColors()[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: FxContainer(
                      bordered: true,
                      borderRadiusAll: 100,
                      border: Border.all(
                        color:
                            cartItem.color == color
                                ? CustomTheme.primary
                                : Colors.white,
                        width: 5,
                      ),
                      paddingAll: 5,
                      color: Colors.white,
                      child: FxContainer(
                        onTap: () {
                          if (cartItem.color == color) {
                            cartItem.color = "";
                            setState(() {});
                            return;
                          }
                          cartItem.color = color;
                          if (cartItem.id > 0) {
                            cartItem.save();
                          }
                          setState(() {});
                        },
                        width: 40,
                        height: 40,
                        borderRadiusAll: 100,
                        color: Utils.getColor(color),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        )
        : const SizedBox();
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        FxText.titleLarge(
          'Quantity'.toUpperCase(),
          fontWeight: 600,
          color: CustomTheme.accent,
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed:
                    _quantity > 1 ? () => setState(() => _quantity--) : null,
                icon: const Icon(
                  FeatherIcons.minus,
                  size: 16,
                  color: CustomTheme.accent,
                ),
                color: _quantity > 1 ? CustomTheme.primary : Colors.grey,
              ),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: FxText.bodyLarge(
                  '$_quantity',
                  color: CustomTheme.color,
                  fontWeight: 900,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _quantity++),
                icon: const Icon(FeatherIcons.plus, size: 16),
                color: CustomTheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatWithAdminButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomTheme.accent.withValues(alpha: 0.1),
            CustomTheme.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomTheme.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CustomTheme.accent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FeatherIcons.messageCircle,
                  color: CustomTheme.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FxText.bodyLarge(
                      'Need Help with this Product?',
                      fontWeight: 600,
                      color: CustomTheme.colorLight,
                    ),
                    FxText.bodySmall(
                      'Chat with our ${AppConfig.MARKETPLACE_NAME} support team',
                      color: CustomTheme.color3,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  () => Get.to(
                    () => ChatScreen({
                      'task': 'PRODUCT_CHAT',
                      'receiver_id': '1', // Always chat with admin (ID=1)
                      'product': item,
                      'start_message':
                          'Hi! I\'m interested in "${item.name}" (${Utils.money(item.price_1)}). Can you help me with more details?',
                    }),
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(FeatherIcons.send, size: 18),
              label: FxText.bodyMedium(
                'Start Chat',
                fontWeight: 600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomTheme.color4.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CustomTheme.color4.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  FeatherIcons.fileText,
                  color: CustomTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                FxText.titleMedium(
                  'Product Description',
                  color: CustomTheme.colorLight,
                  fontWeight: 700,
                ),
              ],
            ),
          ),

          // Description Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FxText.bodyMedium(
                  item.description.isNotEmpty
                      ? item.description
                      : 'This is a high-quality product with excellent features and craftsmanship. Perfect for daily use and designed to meet your needs with style and functionality. Comes with our satisfaction guarantee and premium customer support.',
                  color: CustomTheme.color,
                  height: 1.6,
                ),

                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 16),

                  // Additional product highlights
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CustomTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: CustomTheme.primary.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              FeatherIcons.checkCircle,
                              color: CustomTheme.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            FxText.bodyMedium(
                              'Product Highlights',
                              color: CustomTheme.primary,
                              fontWeight: 600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildHighlightItem(
                          'Premium quality materials and construction',
                        ),
                        _buildHighlightItem('Satisfaction guarantee included'),
                        _buildHighlightItem('Professional customer support'),
                        _buildHighlightItem('Fast and secure delivery'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: CustomTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FxText.bodySmall(
              text,
              color: CustomTheme.color2,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.titleLarge(
            'You may also like'.toUpperCase(),
            color: CustomTheme.accent,
            fontWeight: 700,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: relatedProducts.length,
              itemBuilder: (context, index) {
                final product = relatedProducts[index];
                return InkWell(
                  onTap:
                      () => Get.to(
                        () => ProductScreen(product),
                        transition: Transition.downToUp,
                        preventDuplicates: false,
                      ),
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: CustomTheme.card,
                      border: Border.all(color: Colors.grey[700]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: Utils.img(product.feature_photo),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder:
                                  (_, __) => Container(color: CustomTheme.card),
                              errorWidget:
                                  (_, __, ___) => Image.asset(
                                    AppConfig.NO_IMAGE,
                                    fit: BoxFit.cover,
                                  ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FxText.bodySmall(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: 600,
                                color: CustomTheme.color,
                              ),
                              const SizedBox(height: 4),
                              FxText.bodySmall(
                                Utils.money(product.price_1),
                                color: CustomTheme.primary,
                                fontWeight: 700,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child:
          mainController.cartItemsIDs.contains(widget.item.id.toString())
              ? OutlinedButton(
                onPressed: () {
                  Get.to(() => const CartScreen());
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: CustomTheme.accent,
                  side: BorderSide(color: CustomTheme.accent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FeatherIcons.creditCard, size: 18),
                    const SizedBox(width: 8),
                    FxText.bodyMedium(
                      'CHECKOUT',
                      fontWeight: 600,
                      color: CustomTheme.accent,
                    ),
                  ],
                ),
              )
              : Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _addToCart,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CustomTheme.primary,
                        side: BorderSide(color: CustomTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FeatherIcons.shoppingCart, size: 18),
                          const SizedBox(width: 8),
                          FxText.bodyMedium(
                            'Add to Cart',
                            fontWeight: 600,
                            color: CustomTheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _buyNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: FxText.bodyMedium('Buy Now', fontWeight: 600),
                    ),
                  ),
                ],
              ),
    );
  }

  void _shareProduct() {
    final shareText = '''
🛍️ Check out this amazing product on ${AppConfig.MARKETPLACE_NAME}!

${item.name}
💰 ${Utils.money(item.price_1)}

${item.description.isNotEmpty ? item.description.substring(0, item.description.length > 100 ? 100 : item.description.length) + (item.description.length > 100 ? '...' : '') : 'High-quality product with excellent features.'}

📱 Download ${AppConfig.APP_NAME} from:
${AppConfig.PLAYSTORE_LINK}

#${AppConfig.MARKETPLACE_NAME} #Shopping #QualityProducts
    ''';

    // Show sharing options dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: CustomTheme.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: FxText.titleMedium(
              'Share Product',
              color: CustomTheme.colorLight,
              fontWeight: 700,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CustomTheme.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CustomTheme.color4),
                  ),
                  child: FxText.bodySmall(
                    shareText.trim(),
                    color: CustomTheme.color,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await Clipboard.setData(
                            ClipboardData(text: shareText.trim()),
                          );
                          Utils.toast('Product details copied to clipboard!');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CustomTheme.primary,
                          side: BorderSide(color: CustomTheme.primary),
                        ),
                        icon: Icon(FeatherIcons.copy, size: 16),
                        label: FxText.bodySmall('Copy'
                            , fontWeight: 600,
                            color: CustomTheme.primary

                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          final Uri whatsappUri = Uri.parse(
                            'https://wa.me/?text=${Uri.encodeComponent(shareText.trim())}',
                          );
                          if (await canLaunchUrl(whatsappUri)) {
                            await launchUrl(
                              whatsappUri,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            Utils.toast('Could not open WhatsApp');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomTheme.successGreen,
                          foregroundColor: Colors.white,
                        ),
                        icon: Icon(FeatherIcons.messageCircle, size: 16),
                        label: FxText.bodySmall('WhatsApp', fontWeight: 600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _buyNow() {
    _addToCart();
    Get.to(() => CartScreen());
  }

  @override
  void dispose() {
    super.dispose();
  }
}
