import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../controllers/CartController.dart';
import '../screens/shop/screens/shop/cart/CartScreen.dart';
import '../utils/CustomTheme.dart';

class CartFloatingButton extends StatelessWidget {
  const CartFloatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.put(CartController());

    return Obx(() {
      if (cartController.cartItems.isEmpty) return const SizedBox();

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: LinearGradient(
            colors: [CustomTheme.primary, CustomTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: CustomTheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            FloatingActionButton(
              onPressed: () => Get.to(() => const CartScreen()),
              backgroundColor: Colors.transparent,
              elevation: 0,
              heroTag: "cart_fab",
              child: Icon(
                FeatherIcons.shoppingCart,
                color: Colors.white,
                size: 24,
              ),
            ),
            // Cart Badge
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CustomTheme.primary, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: FxText.bodySmall(
                  '${cartController.cartItems.length}',
                  color: CustomTheme.primary,
                  fontSize: 11,
                  fontWeight: 700,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
