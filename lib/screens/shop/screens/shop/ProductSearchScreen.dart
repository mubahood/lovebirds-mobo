import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/utils/Utilities.dart';

import '../../../../controllers/MainController.dart';
import '../../../../utils/AppConfig.dart';
import '../../../../utils/CustomTheme.dart';
import '../../../../widget/widgets.dart';
import '../../models/Product.dart';
import 'ProductScreen.dart';

class ProductSearchScreen2 extends StatefulWidget {
  const ProductSearchScreen2({Key? key}) : super(key: key);

  @override
  _ProductSearchScreen2State createState() => _ProductSearchScreen2State();
}

class _ProductSearchScreen2State extends State<ProductSearchScreen2> {
  String keyWord = "";
  final _fKey = GlobalKey<FormBuilderState>();
  final MainController mainController = Get.find<MainController>();
  late Future<void> futureInit;
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    futureInit = _load();
    setState(() {});
    await futureInit;
  }

  Future<void> _load() async {
    if (keyWord.length > 1) {
      products = await Product.getItems(where: "name LIKE '%$keyWord%'");
    } else {
      products.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomTheme.background,
        iconTheme: IconThemeData(color: CustomTheme.accent),
        title: FormBuilder(
          key: _fKey,
          child: FormBuilderTextField(
            name: 'search',
            initialValue: '',
            autofocus: true,
            cursorColor: CustomTheme.accent,
            textInputAction: TextInputAction.search,
            onChanged: (v) {
              keyWord = v ?? "";
              _refresh();
            },
            decoration: InputDecoration(
              hintText: 'Search in ${AppConfig.MARKETPLACE_NAME}…',
              hintStyle: TextStyle(color: CustomTheme.color3),
              filled: true,
              fillColor: CustomTheme.card,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              prefixIcon: Icon(FeatherIcons.search, color: CustomTheme.accent),
              suffixIcon: IconButton(
                icon: Icon(FeatherIcons.x, color: CustomTheme.accent),
                onPressed: () {
                  _fKey.currentState!.patchValue({'search': ''});
                  keyWord = "";
                  _refresh();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: futureInit,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildResults();
        },
      ),
    );
  }

  Widget _buildResults() {
    return RefreshIndicator(
      color: CustomTheme.primary,
      onRefresh: _refresh,
      child:
          products.isEmpty
              ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: Get.height / 3),
                  Center(
                    child: FxText.bodyLarge(
                      keyWord.length > 1
                          ? 'No results for "$keyWord"'
                          : 'Type at least 2 characters to search',
                      color: CustomTheme.color2,
                      textAlign: TextAlign.center,
                      fontWeight: 600,
                    ),
                  ),
                ],
              )
              : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: products.length,
                separatorBuilder:
                    (_, __) => Divider(
                      color: CustomTheme.color4,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                itemBuilder: (_, i) {
                  final p = products[i];
                  return InkWell(
                    onTap: () => Get.to(() => ProductScreen(p)),
                    child: Container(
                      color: CustomTheme.card,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: Utils.img(p.feature_photo),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              placeholder:
                                  (_, __) => ShimmerLoadingWidget(
                                    height: 60,
                                    width: 60,
                                  ),
                              errorWidget:
                                  (_, __, ___) => Image.asset(
                                    AppConfig.NO_IMAGE,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FxText.bodyLarge(
                                  p.name,
                                  color: CustomTheme.color,
                                  fontWeight: 700,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                FxText.bodySmall(
                                  "${AppConfig.CURRENCY}${Utils.moneyFormat(p.price_1)}",
                                  color: CustomTheme.primary,
                                  fontWeight: 800,
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
    );
  }
}
