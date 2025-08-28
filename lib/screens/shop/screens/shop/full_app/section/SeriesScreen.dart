import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/models/SeriesModel.dart';
import 'package:lovebirds_app/utils/CustomTheme.dart';
import 'package:lovebirds_app/utils/Utilities.dart';
import 'package:lovebirds_app/utils/my_colors.dart';

import '../../../../../../models/MovieModel.dart';
import '../../widgets.dart';

class SeriesScreen extends StatefulWidget {
  SeriesModel item;

  SeriesScreen(this.item, {super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  List<MovieModel> episodes = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  init() {
    getEpisodes();
  }

  void getEpisodes() async {
    Utils.toast("Loading episodes...");
    episodes = await MovieModel.get_items(
      where: "category_id = ${widget.item.id}",
    );
    if (episodes.isEmpty) {
      Utils.toast("No episodes found.");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyColors.primary,
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: CustomTheme.accent,
          ),
          backgroundColor: MyColors.primary,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FxText.titleMedium(
                widget.item.title,
                fontWeight: 600,
                color: CustomTheme.color,
                maxLines: 2,
              ),
              FxText.bodySmall(
                "${widget.item.total_seasons} Episodes",
                color: CustomTheme.secondary,
              ),
            ],
          ),
          systemOverlayStyle: Utils.overlay(),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            getEpisodes();
          },
          color: CustomTheme.accent,
          backgroundColor: CustomTheme.color,
          child: ListView.builder(
            itemCount: episodes.length,
            itemBuilder: (context, index) {
              //item
              MovieModel item = episodes[index];
              return InkWell(
                onTap: () {
                },
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        Stack(
                          children: [
                            roundedImage2(item.getThumbnail(), 4, 4.5,
                                radius: 8),
                            Positioned(
                              bottom: 0,
                              child: Container(
                                alignment: Alignment.bottomLeft,
                                width: Get.width / 4,
                                height: Get.width / 9,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      CustomTheme.secondary.withValues(alpha: .9),
                                      Colors.transparent
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.only(
                                    left: 5, bottom: 2, right: 2),
                                child: FxText.bodyMedium(
                                  'Episode ${item.country}'.toUpperCase(),
                                  color: Colors.black,
                                  fontWeight: 900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FxText.titleLarge(
                                episodes[index].title,
                                color: CustomTheme.color,
                                fontWeight: 300,
                                maxLines: 2,
                                height: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              //progress bar
                              const SizedBox(
                                height: 10,
                              ),
                              FxProgressBar(
                                //shuffle progress: ,
                                progress: ((Random().nextDouble() * 100) / 100)
                                    .toDouble(),
                                width: Get.width - 100,
                                activeColor: CustomTheme.accent,
                                inactiveColor: CustomTheme.color3,
                                height: 5,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RatingBar(
                                    initialRating: Random().nextDouble() * 5,
                                    itemSize: 25,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    ratingWidget: RatingWidget(
                                      full: const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      half: const Icon(
                                        Icons.star_half,
                                        color: Colors.amber,
                                      ),
                                      empty: const Icon(
                                        Icons.star_border,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    itemPadding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                    },
                                  ),
                                  FxContainer(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 2),
                                    borderRadiusAll: 0,
                                    color: CustomTheme.accent,
                                    child: FxText.bodySmall(
                                      "VJ: ${episodes[index].genre}",
                                      color: CustomTheme.color,
                                      maxLines: 1,
                                      fontWeight: 700,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              );
            },
          ),
        ));
  }
}
