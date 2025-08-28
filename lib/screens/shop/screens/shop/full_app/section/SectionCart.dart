import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../../../controllers/MainController.dart';
import '../../../../../../utils/CustomTheme.dart';
import '../../../../../../utils/Utilities.dart';
import '../../../../../../widget/widgets.dart';
import '../../../../models/Product.dart';
import '../../ProductCreateScreen.dart';
import '../../widgets.dart';

class SectionCart extends StatefulWidget {
  MainController mainController;

  SectionCart(this.mainController, {Key? key}) : super(key: key);

  @override
  _SectionCartState createState() => _SectionCartState();
}

class _SectionCartState extends State<SectionCart> {
  late Future<dynamic> futureInit;

  Future<dynamic> do_refresh() async {
    futureInit = my_init();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    futureInit = my_init();
  }

  Future<dynamic> my_init() async {
    return "Done";
  }

  void _showBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext buildContext) {
          return Container(
            color :Colors.transparent,
            child: Container(
              decoration: const BoxDecoration(
                  color :Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16))),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      dense: true,
                      minLeadingWidth: 10,
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() =>
                        const ProductCreateScreen({
                        }

                        ));
                      },
                      leading: const Icon(
                        FeatherIcons.plus,
                        color :CustomTheme.primary,
                        size: 26,
                      ),
                      title: FxText.titleMedium(
                        "Post new product",
                        fontSize: 18,
                        fontWeight : 800,
                        color :Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.primary,
        systemOverlayStyle: Utils.overlay(),
        elevation: .5,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const FxContainer(
              width: 10,
              height: 20,
              color :Colors.white,
              borderRadiusAll: 2,
            ),
            FxSpacing.width(8),
            FxText.titleLarge(
              "My Products",
              fontWeight : 900,
              color :Colors.white,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CustomTheme.primary,
        onPressed: () {
          _showBottomSheet(context);
        },
        child: const Icon(FeatherIcons.plus),
      ),
      body: SafeArea(
        child: FutureBuilder(
            future: futureInit,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return myListLoaderWidget();
                default:
                  return Obx(() => mainWidget());
              }
            }),
      ),
    );
  }

  Future<dynamic> doRefresh() async {
    await widget.mainController.getMyProducts();
    setState(() {});
    return "Done";
  }

  Future<dynamic> myInit() async {
    //  await mainController.init();
    await widget.mainController.getCartItems();
    return "Done";
  }

  Widget mainWidget() {
    return [].isEmpty
        ? Center(
            child: FxText.titleLarge("You shopping cart is empty."),
          )
        : Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: RefreshIndicator(
              backgroundColor: Colors.white,
              onRefresh: doRefresh,
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        Product m = Product();
                        return Column(
                          children: [
                            productWidget2(m),
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Divider(
                                height: 0,
                              ),
                            ),
                          ],
                        );
                      },
                      childCount: [].length, // 1000 list items
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
