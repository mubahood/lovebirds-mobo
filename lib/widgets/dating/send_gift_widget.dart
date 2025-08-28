import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';

import '../../models/UserModel.dart';
import '../../services/canadian_localization_service.dart';
import '../../utils/dating_theme.dart';
import '../../utils/Utilities.dart';

/// Send Gift Feature for Dating-Marketplace Integration
/// Allows matched users to send gifts to each other
class SendGiftWidget extends StatefulWidget {
  final UserModel matchedUser;
  final UserModel currentUser;
  final Function(GiftSendResult) onGiftSent;

  const SendGiftWidget({
    Key? key,
    required this.matchedUser,
    required this.currentUser,
    required this.onGiftSent,
  }) : super(key: key);

  @override
  _SendGiftWidgetState createState() => _SendGiftWidgetState();
}

class _SendGiftWidgetState extends State<SendGiftWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  List<GiftCategory> _giftCategories = [];
  List<GiftItem> _selectedCategoryGifts = [];
  GiftItem? _selectedGift;
  String _personalMessage = '';
  bool _isAnonymous = false;
  bool _isSending = false;

  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _loadGiftCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bounceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _loadGiftCategories() {
    setState(() {
      _giftCategories = GiftService.getGiftCategories();
      if (_giftCategories.isNotEmpty) {
        _selectedCategoryGifts = _giftCategories.first.gifts;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DatingTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: DatingTheme.primaryPink,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FxText.titleMedium(
              'Send a Gift',
              color: Colors.white,
              fontWeight: 600,
            ),
            FxText.bodySmall(
              'to ${widget.matchedUser.first_name}',
              color: Colors.white70,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(FeatherIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(FeatherIcons.heart, color: Colors.white),
            onPressed: () {
              _bounceController.forward().then((_) {
                _bounceController.reverse();
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: DatingTheme.primaryRose,
          tabs: const [
            Tab(icon: Icon(FeatherIcons.gift), text: 'Choose Gift'),
            Tab(icon: Icon(FeatherIcons.messageCircle), text: 'Message'),
            Tab(icon: Icon(FeatherIcons.send), text: 'Send'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGiftSelectionTab(),
          _buildMessageTab(),
          _buildSendTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildGiftSelectionTab() {
    return Column(
      children: [
        // Gift Categories
        Container(
          height: 120,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _giftCategories.length,
            itemBuilder: (context, index) {
              final category = _giftCategories[index];
              final isSelected = _selectedCategoryGifts == category.gifts;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryGifts = category.gifts;
                    _selectedGift = null; // Reset selection
                  });
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isSelected
                                  ? DatingTheme.primaryPink.withValues(
                                    alpha: 0.2,
                                  )
                                  : DatingTheme.cardBackground,
                          border: Border.all(
                            color:
                                isSelected
                                    ? DatingTheme.primaryPink
                                    : Colors.white.withValues(alpha: 0.1),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          category.icon,
                          color:
                              isSelected
                                  ? DatingTheme.primaryPink
                                  : Colors.white70,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FxText.bodySmall(
                        category.name,
                        color:
                            isSelected
                                ? DatingTheme.primaryPink
                                : Colors.white70,
                        fontWeight: isSelected ? 600 : 400,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Gift Items Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _selectedCategoryGifts.length,
            itemBuilder: (context, index) {
              final gift = _selectedCategoryGifts[index];
              final isSelected = _selectedGift?.id == gift.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGift = gift;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: DatingTheme.cardBackground,
                    border: Border.all(
                      color:
                          isSelected
                              ? DatingTheme.primaryPink
                              : Colors.white.withValues(alpha: 0.1),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: DatingTheme.primaryPink.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                            : null,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(gift.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child:
                              gift.imageUrl.isEmpty
                                  ? Icon(
                                    gift.icon,
                                    size: 40,
                                    color: DatingTheme.primaryPink,
                                  )
                                  : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            FxText.bodyMedium(
                              gift.name,
                              color: Colors.white,
                              fontWeight: 600,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            FxText.bodySmall(
                              'CAD \$${gift.price.toStringAsFixed(2)}',
                              color: DatingTheme.primaryPink,
                              fontWeight: 600,
                            ),
                            if (gift.isPopular)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: DatingTheme.accentGold.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: FxText.bodySmall(
                                  'POPULAR',
                                  color: DatingTheme.accentGold,
                                  fontWeight: 600,
                                ),
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
    );
  }

  Widget _buildMessageTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.titleMedium(
            'Add a Personal Message',
            color: Colors.white,
            fontWeight: 600,
          ),
          const SizedBox(height: 8),
          FxText.bodyMedium(
            'Make your gift extra special with a heartfelt message',
            color: Colors.white70,
          ),
          const SizedBox(height: 24),

          // Message Input
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: DatingTheme.cardBackground,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: TextFormField(
              controller: _messageController,
              maxLines: 6,
              maxLength: 200,
              style: TextStyle(color: Colors.white),
              cursorColor: DatingTheme.primaryPink,
              decoration: InputDecoration(
                hintText: 'Write your message here...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                counterStyle: TextStyle(color: Colors.white70),
              ),
              onChanged: (value) {
                setState(() {
                  _personalMessage = value;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Message Templates
          FxText.titleSmall(
            'Quick Message Templates',
            color: Colors.white,
            fontWeight: 600,
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _getMessageTemplates().map((template) {
                  return GestureDetector(
                    onTap: () {
                      _messageController.text = template;
                      setState(() {
                        _personalMessage = template;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: DatingTheme.primaryPink.withValues(alpha: 0.1),
                        border: Border.all(
                          color: DatingTheme.primaryPink.withValues(alpha: 0.3),
                        ),
                      ),
                      child: FxText.bodySmall(
                        template,
                        color: DatingTheme.primaryPink,
                      ),
                    ),
                  );
                }).toList(),
          ),

          const SizedBox(height: 24),

          // Anonymous Option
          Row(
            children: [
              Checkbox(
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value ?? false;
                  });
                },
                activeColor: DatingTheme.primaryPink,
                checkColor: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FxText.bodyMedium(
                  'Send anonymously (they won\'t know it\'s from you)',
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSendTab() {
    if (_selectedGift == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FeatherIcons.gift, size: 64, color: Colors.white30),
            const SizedBox(height: 16),
            FxText.titleMedium('No Gift Selected', color: Colors.white70),
            const SizedBox(height: 8),
            FxText.bodyMedium(
              'Please go back and choose a gift first',
              color: Colors.white.withValues(alpha: 0.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FxText.titleMedium(
            'Gift Summary',
            color: Colors.white,
            fontWeight: 600,
          ),
          const SizedBox(height: 16),

          // Gift Preview Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: DatingTheme.cardBackground,
              border: Border.all(
                color: DatingTheme.primaryPink.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image:
                        _selectedGift!.imageUrl.isNotEmpty
                            ? DecorationImage(
                              image: NetworkImage(_selectedGift!.imageUrl),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      _selectedGift!.imageUrl.isEmpty
                          ? Icon(
                            _selectedGift!.icon,
                            size: 40,
                            color: DatingTheme.primaryPink,
                          )
                          : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.titleSmall(
                        _selectedGift!.name,
                        color: Colors.white,
                        fontWeight: 600,
                      ),
                      const SizedBox(height: 4),
                      FxText.bodyMedium(
                        _selectedGift!.description,
                        color: Colors.white70,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      FxText.titleSmall(
                        'CAD \$${_selectedGift!.price.toStringAsFixed(2)}',
                        color: DatingTheme.primaryPink,
                        fontWeight: 600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recipient Info
          FxText.titleMedium(
            'Sending To',
            color: Colors.white,
            fontWeight: 600,
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: DatingTheme.cardBackground,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage:
                      widget.matchedUser.avatar.isNotEmpty
                          ? NetworkImage(
                            Utils.getImageUrl(widget.matchedUser.avatar),
                          )
                          : null,
                  child:
                      widget.matchedUser.avatar.isEmpty
                          ? Icon(FeatherIcons.user, color: Colors.white70)
                          : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FxText.bodyMedium(
                      _isAnonymous
                          ? 'Anonymous Gift'
                          : widget.matchedUser.first_name,
                      color: Colors.white,
                      fontWeight: 600,
                    ),
                    FxText.bodySmall(
                      _isAnonymous
                          ? 'Recipient will see "Secret Admirer"'
                          : 'Your matched connection',
                      color: Colors.white70,
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_personalMessage.isNotEmpty) ...[
            const SizedBox(height: 24),
            FxText.titleMedium(
              'Your Message',
              color: Colors.white,
              fontWeight: 600,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: DatingTheme.cardBackground,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: FxText.bodyMedium(_personalMessage, color: Colors.white70),
            ),
          ],

          const SizedBox(height: 32),

          // Delivery Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: DatingTheme.successGreen.withValues(alpha: 0.1),
              border: Border.all(
                color: DatingTheme.successGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  FeatherIcons.info,
                  color: DatingTheme.successGreen,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FxText.bodyMedium(
                        'Instant Delivery',
                        color: DatingTheme.successGreen,
                        fontWeight: 600,
                      ),
                      FxText.bodySmall(
                        'Your gift will be delivered immediately to their notifications',
                        color: DatingTheme.successGreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DatingTheme.cardBackground,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          if (_tabController.index > 0)
            Expanded(
              child: FxButton.outlined(
                onPressed: () {
                  _tabController.animateTo(_tabController.index - 1);
                },
                borderColor: DatingTheme.primaryPink,
                child: FxText.bodyMedium(
                  'Previous',
                  color: DatingTheme.primaryPink,
                  fontWeight: 600,
                ),
              ),
            ),
          if (_tabController.index > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ScaleTransition(
              scale: _bounceAnimation,
              child: FxButton(
                onPressed: _isSending ? null : _handleNextOrSend,
                backgroundColor: DatingTheme.primaryPink,
                child:
                    _isSending
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _tabController.index == 2
                                  ? FeatherIcons.send
                                  : FeatherIcons.arrowRight,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            FxText.bodyMedium(
                              _tabController.index == 2
                                  ? 'Send Gift (${_selectedGift?.price.toStringAsFixed(2) ?? '0.00'} CAD)'
                                  : 'Next',
                              color: Colors.white,
                              fontWeight: 600,
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNextOrSend() {
    if (_tabController.index == 2) {
      _sendGift();
    } else if (_tabController.index == 0 && _selectedGift == null) {
      Utils.toast('Please select a gift first');
    } else {
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  void _sendGift() async {
    if (_selectedGift == null) {
      Utils.toast('Please select a gift');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // Process payment first
      final billingAddress = CanadianAddress(
        street: '123 Main St', // Would get from user profile
        city: 'Toronto',
        province: 'ON',
        postalCode: 'M5H 2N2',
      );

      final paymentRequest = PaymentRequest(
        paymentMethodId: 'interac_debit',
        amount: _selectedGift!.price,
        currency: 'CAD',
        billingAddress: billingAddress,
      );

      final paymentResult = await CanadianPaymentService.instance
          .processPayment(paymentRequest);

      if (paymentResult.success) {
        // Send the gift
        final giftResult = GiftSendResult(
          success: true,
          giftId: _selectedGift!.id,
          recipientId: widget.matchedUser.id.toString(),
          senderId: widget.currentUser.id.toString(),
          message: _personalMessage,
          isAnonymous: _isAnonymous,
          transactionId: paymentResult.transactionId,
          amount: _selectedGift!.price,
        );

        widget.onGiftSent(giftResult);
        Navigator.pop(context);

        Utils.toast('Gift sent successfully! 💝');
      } else {
        Utils.toast('Payment failed: ${paymentResult.error}');
      }
    } catch (e) {
      Utils.toast('Failed to send gift: ${e.toString()}');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  List<String> _getMessageTemplates() {
    return [
      'Thinking of you! 💕',
      'Hope this brightens your day! ☀️',
      'Just because you\'re amazing! ⭐',
      'Can\'t wait to see you! 😊',
      'You deserve something special! 🎁',
      'Missing you! 💭',
    ];
  }
}

// Data classes and services for the gift system

class GiftService {
  static List<GiftCategory> getGiftCategories() {
    return [
      GiftCategory(
        id: 'flowers',
        name: 'Flowers',
        icon: FeatherIcons.heart, // Using heart instead of flower
        gifts: [
          GiftItem(
            id: 'roses_red',
            name: 'Red Roses',
            description: 'Classic dozen red roses for romance',
            price: 75.99,
            imageUrl: 'https://example.com/red_roses.jpg',
            icon: FeatherIcons.heart,
            isPopular: true,
          ),
          GiftItem(
            id: 'tulips_mixed',
            name: 'Mixed Tulips',
            description: 'Beautiful mixed color tulip bouquet',
            price: 45.99,
            imageUrl: 'https://example.com/tulips.jpg',
            icon: FeatherIcons.heart,
          ),
          GiftItem(
            id: 'sunflowers',
            name: 'Sunflowers',
            description: 'Bright and cheerful sunflower bouquet',
            price: 55.99,
            imageUrl: 'https://example.com/sunflowers.jpg',
            icon: FeatherIcons.heart,
          ),
        ],
      ),
      GiftCategory(
        id: 'chocolate',
        name: 'Sweets',
        icon: FeatherIcons.heart,
        gifts: [
          GiftItem(
            id: 'luxury_chocolates',
            name: 'Luxury Chocolates',
            description: 'Premium Belgian chocolate selection',
            price: 35.99,
            imageUrl: 'https://example.com/chocolates.jpg',
            icon: FeatherIcons.heart,
            isPopular: true,
          ),
          GiftItem(
            id: 'macarons',
            name: 'French Macarons',
            description: 'Assorted French macarons box',
            price: 28.99,
            imageUrl: 'https://example.com/macarons.jpg',
            icon: FeatherIcons.heart,
          ),
        ],
      ),
      GiftCategory(
        id: 'jewelry',
        name: 'Jewelry',
        icon: FeatherIcons.star,
        gifts: [
          GiftItem(
            id: 'necklace_heart',
            name: 'Heart Necklace',
            description: 'Sterling silver heart pendant necklace',
            price: 89.99,
            imageUrl: 'https://example.com/necklace.jpg',
            icon: FeatherIcons.star,
            isPopular: true,
          ),
          GiftItem(
            id: 'earrings_pearl',
            name: 'Pearl Earrings',
            description: 'Classic pearl stud earrings',
            price: 65.99,
            imageUrl: 'https://example.com/earrings.jpg',
            icon: FeatherIcons.star,
          ),
        ],
      ),
      GiftCategory(
        id: 'experiences',
        name: 'Experiences',
        icon: FeatherIcons.calendar,
        gifts: [
          GiftItem(
            id: 'dinner_voucher',
            name: 'Dinner for Two',
            description: 'Romantic dinner voucher at premium restaurant',
            price: 125.99,
            imageUrl: 'https://example.com/dinner.jpg',
            icon: FeatherIcons.calendar,
            isPopular: true,
          ),
          GiftItem(
            id: 'spa_day',
            name: 'Spa Day',
            description: 'Relaxing spa day experience',
            price: 199.99,
            imageUrl: 'https://example.com/spa.jpg',
            icon: FeatherIcons.calendar,
          ),
        ],
      ),
    ];
  }
}

class GiftCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<GiftItem> gifts;

  GiftCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.gifts,
  });
}

class GiftItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final IconData icon;
  final bool isPopular;

  GiftItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.icon,
    this.isPopular = false,
  });
}

class GiftSendResult {
  final bool success;
  final String giftId;
  final String recipientId;
  final String senderId;
  final String message;
  final bool isAnonymous;
  final String transactionId;
  final double amount;

  GiftSendResult({
    required this.success,
    required this.giftId,
    required this.recipientId,
    required this.senderId,
    required this.message,
    required this.isAnonymous,
    required this.transactionId,
    required this.amount,
  });
}
