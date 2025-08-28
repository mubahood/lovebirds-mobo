import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../../controllers/MainController.dart';
import '../../../../../utils/AppConfig.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../../../models/CartItem.dart';
import '../widgets.dart';

class cartItemWidget extends StatefulWidget {
  CartItem u;
  int index;
  MainController mainController;

  cartItemWidget(this.u, this.mainController, this.index, {Key? key})
    : super(key: key);

  @override
  State<cartItemWidget> createState() => _cartItemWidgetState();
}

class _cartItemWidgetState extends State<cartItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.index.isEven ? CustomTheme.background : CustomTheme.background.withAlpha(20),
      padding: const EdgeInsets.only(top: 10, bottom: 15, left: 15, right: 10),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          roundedImage(
            "${Utils.img(widget.u.product_feature_photo)}",
            4.5,
            4.5,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Flex(
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      child: FxText.bodyLarge(
                        widget.u.product_name,
                        maxLines: 1,
                        height: 1,
                        color: CustomTheme.color,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: 800,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Get.defaultDialog(
                              middleText:
                                  "Are you sure you need to remove this item from your cart?",
                              titleStyle:   TextStyle(color: CustomTheme.color2),
                              actions: <Widget>[
                                FxButton.text(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  borderColor: CustomTheme.primary,
                                  child: FxText(
                                    'CANCEL',
                                    color: CustomTheme.primary,
                                    fontWeight: 800,
                                  ),
                                ),
                                FxButton.text(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await widget.mainController.removeFromCart(
                                      widget.u.id.toString(),
                                    );
                                    await widget.mainController.getCartItems();
                                  },
                                  child: FxText(
                                    'REMOVE',
                                    color: Colors.red,
                                    fontWeight: 800,
                                  ),
                                ),
                              ],
                            );
                          },
                          child: const Icon(
                            FeatherIcons.trash2,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                (widget.u.color.isNotEmpty || widget.u.size.isNotEmpty)
                    ? const SizedBox(height: 0)
                    : const SizedBox(height: 20),
                (widget.u.color.isNotEmpty || widget.u.size.isNotEmpty)
                    ? Row(
                      children: [
                        widget.u.color.isEmpty
                            ? SizedBox()
                            : FxContainer(
                              margin: const EdgeInsets.only(bottom: 5),
                              paddingAll: 4,
                              borderRadiusAll: 4,
                              color: CustomTheme.primary,
                              child: FxText.bodySmall(
                                widget.u.color,
                                height: 1,
                                color: Colors.white,
                                fontWeight: 800,
                              ),
                            ),
                        const SizedBox(width: 5),
                        widget.u.size.isEmpty
                            ? SizedBox()
                            : FxContainer(
                              margin: const EdgeInsets.only(bottom: 5),
                              paddingAll: 4,
                              borderRadiusAll: 5,
                              color: CustomTheme.primary,
                              child: FxText.bodySmall(
                                widget.u.size,
                                height: 1,
                                color: Colors.white,
                                fontWeight: 800,
                              ),
                            ),
                      ],
                    )
                    : const SizedBox(),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FxText.titleLarge(
                          "@${AppConfig.CURRENCY}${Utils.moneyFormat(widget.u.product_price_1).toString().toUpperCase()}",
                          fontWeight: 400,
                          color: CustomTheme.color2,
                          height: 1,
                        ),
                        FxText.bodySmall(
                          "TOTAL: ${AppConfig.CURRENCY} ${Utils.moneyFormat("${Utils.int_parse(widget.u.product_quantity) * Utils.int_parse(widget.u.product_price_1)}").toString().toUpperCase()}",
                          fontWeight: 400,
                          color: CustomTheme.color2,
                        ),
                      ],
                    ),
                    const Spacer(),
                    FxContainer(
                      paddingAll: 6,
                      onTap: () async {
                        int x = Utils.int_parse(widget.u.product_quantity);
                        x--;
                        if (x < 1) {
                          x = 1;
                          return;
                        }
                        widget.u.product_quantity = '$x';
                        await widget.u.save();
                        await widget.mainController.getCartItems();
                      },
                      color: CustomTheme.primary.withAlpha(40),
                      borderRadiusAll: 100,
                      child: const Icon(
                        FeatherIcons.minus,
                        size: 18,
                        color: CustomTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    FxText.bodyLarge(
                      widget.u.product_quantity,
                      maxLines: 1,
                      fontWeight: 900,
                      color: CustomTheme.color2,
                    ),
                    const SizedBox(width: 5),
                    FxContainer(
                      onTap: () async {
                        int x = Utils.int_parse(widget.u.product_quantity);
                        x++;
                        widget.u.product_quantity = '$x';
                        await widget.u.save();
                        await widget.mainController.getCartItems();
                      },
                      paddingAll: 6,
                      color: CustomTheme.primary.withAlpha(40),
                      borderRadiusAll: 100,
                      child: const Icon(
                        FeatherIcons.plus,
                        size: 18,
                        color: CustomTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> doDelete(CartItem u) async {
    await u.delete();
    await widget.mainController.getCartItems();
    widget.mainController.update();
    setState(() {});
  }
}
