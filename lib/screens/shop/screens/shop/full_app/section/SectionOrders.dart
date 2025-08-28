import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/models/LoggedInUserModel.dart';

import '../../../../../../controllers/MainController.dart';
import '../../../../../../utils/CustomTheme.dart';
import '../../../../../../utils/Utilities.dart';
import '../../../../../../widget/widgets.dart';
import '../../../../models/OrderOnline.dart';
import '../../widgets.dart';


class SectionOrders extends StatefulWidget {
  MainController mainController;

  SectionOrders(this.mainController, {Key? key}) : super(key: key);

  @override
  _SectionOrdersState createState() => _SectionOrdersState();
}

class _SectionOrdersState extends State<SectionOrders> {
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

  LoggedInUserModel u = LoggedInUserModel();

  Future<dynamic> my_init() async {
    u = await LoggedInUserModel.getLoggedInUser();
    await widget.mainController.getOrders();
    return "Done";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: Utils.overlay(),
        elevation: .5,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const FxContainer(
              width: 10,
              height: 20,
              color :CustomTheme.primary,
              borderRadiusAll: 2,
            ),
            FxSpacing.width(8),
            FxText.titleLarge(
              "My Orders",
              fontWeight : 900,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
            future: futureInit,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return myListLoaderWidget();
                default:
                  return (u.id < 1)
                      ? notLoggedInWidget()
                      : Obx(() => mainWidget());
              }
            }),
      ),
    );
  }

  Widget mainWidget() {
    return [].isEmpty
        ? Center(
            child: FxText.titleLarge("You have not placed any order."),
          )
        : Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: RefreshIndicator(
              backgroundColor: Colors.white,
              onRefresh: do_refresh,
              child: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              OrderOnline m = OrderOnline();
                              return FxCard(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 7, horizontal: 10),
                                child: ListTile(
                                  title: Flex(
                                    direction: Axis.horizontal,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: FxText.titleMedium(
                                          Utils.to_date_1(m.created_at),
                                          color :Colors.black,
                                        ),
                                      ),
                                      FxText.titleLarge(
                                        "\$ ${Utils.moneyFormat(m.order_total)}",
                                        color :CustomTheme.primary,
                                        fontWeight : 900,
                                      ),
                                    ],
                                  ),
                                  subtitle: Row(
                                    children: [
                                      FxContainer(
                                        margin: const EdgeInsets.only(top: 5),
                                        color :m.order_state == '0'
                                            ? Colors.red.shade700
                                            : m.order_state == '1'
                                                ? Colors.yellow.shade700
                                                : Colors.green.shade700,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        child: FxText.bodySmall(
                                          m.order_state == '0'
                                              ? 'Pending'
                                              : m.order_state == '1'
                                                  ? 'Shipping'
                                                  : 'Competed',
                                          color :Colors.white,
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                  leading: const Icon(
                                    FeatherIcons.file,
                                    color :CustomTheme.primary,
                                  ),
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                              );
                            },
                            childCount: []
                                .length, // 1000 list items
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
