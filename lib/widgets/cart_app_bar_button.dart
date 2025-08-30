import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../controllers/CartController.dart';
import '../screens/shop/screens/shop/cart/CartScreen.dart';
import '../utils/CustomTheme.dart';

class CartAppBarButton extends StatelessWidget {
  const CartAppBarButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.put(CartController());

    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CustomTheme.color4.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Stack(
        children: [
          IconButton(
            icon: Icon(
              FeatherIcons.shoppingCart,
              color: CustomTheme.accent,
              size: 20,
            ),
            onPressed: () => Get.to(() => const CartScreen()),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          // Cart Badge
          Obx(() {
            if (cartController.cartItems.isEmpty) return const SizedBox();
            return Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: CustomTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CustomTheme.background, width: 1),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: FxText.bodySmall(
                  '${cartController.cartItems.length}',
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: 700,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
