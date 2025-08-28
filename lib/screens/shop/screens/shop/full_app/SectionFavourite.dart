import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/models/MovieModel.dart';

import '../../../../../controllers/MainController.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../../../../../utils/my_colors.dart';
import '../../../../../widget/widgets.dart';
import '../../../../gardens/VideoPlayerScreen.dart';
import '../widgets.dart';

class SectionFavourite extends StatefulWidget {
  const SectionFavourite({super.key});

  @override
  State<SectionFavourite> createState() => _SectionFavouriteState();
}

class _SectionFavouriteState extends State<SectionFavourite> {
  MainController mainController = Get.find<MainController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  init() async {
    setState(() {
      isLoading = true;
    });
    await mainController.getWatchedMovies();
    isLoading = false;
    setState(() {});
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyColors.primary,
        appBar: AppBar(
          backgroundColor: CustomTheme.primary,
          systemOverlayStyle: Utils.overlay(),
          elevation: .5,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              const FxContainer(
                width: 12,
                color: CustomTheme.secondary,
                height: 25,
              ),
              const SizedBox(
                width: 10,
              ),
              FxText.titleLarge(
                "Favourite Movies",
                fontWeight: 900,
                color: CustomTheme.accent,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                FeatherIcons.search,
                color: CustomTheme.accent,
              ),
              onPressed: () {},
            ),
            /* IconButton(
              icon: const Icon(
                FeatherIcons.filter,
                color: CustomTheme.accent,
              ),
              onPressed: () {},
            ),*/
          ],
        ),
        body: Column(
          children: [
            const Divider(
              height: 2,
              color: CustomTheme.secondary,
              thickness: 2,
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  init();
                },
                color: CustomTheme.accent,
                backgroundColor: CustomTheme.color,
                child: isLoading
                    ? myListLoaderWidget()
                    : mainController.watchedMovies.isEmpty
                        ? emptyListWidget('You have not watched any movie yet.',
                            'Watch a movie to see it here.', () {
                            init();
                          })
                        : ListView.builder(
                            itemCount: mainController.watchedMovies.length,
                            itemBuilder: (context, index) {
                              //item
                              MovieModel item =
                                  mainController.watchedMovies[index];
                              return InkWell(
                                onTap: () {
                                  Get.to(() =>
                                      VideoPlayerScreen({'video_item': item}));
                                },
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Stack(
                                          children: [
                                            roundedImage2(
                                                item.getThumbnail(), 4, 4.5,
                                                radius: 8),
                                            Positioned(
                                              bottom: 0,
                                              child: Container(
                                                alignment: Alignment.bottomLeft,
                                                width: Get.width / 4,
                                                height: Get.width / 9,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10),
                                                  ),
                                                  gradient: LinearGradient(
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                    colors: [
                                                      CustomTheme.secondary
                                                          .withValues(alpha: .9),
                                                      Colors.transparent
                                                    ],
                                                  ),
                                                ),
                                                padding: const EdgeInsets.only(
                                                    left: 5,
                                                    bottom: 2,
                                                    right: 2),
                                                child: FxText.bodyMedium(
                                                  'Episode ${item.country}'
                                                      .toUpperCase(),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FxText.titleLarge(
                                                mainController
                                                    .watchedMovies[index].title,
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
                                                width: Get.width - 140,
                                                progress: item.getProgress(),
                                                activeColor: CustomTheme.accent,
                                                inactiveColor:
                                                    CustomTheme.color3,
                                                height: 5,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  RatingBar(
                                                    initialRating:
                                                        Random().nextDouble() *
                                                            5,
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
                                                    itemPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 4.0),
                                                    onRatingUpdate: (rating) {
                                                      print(rating);
                                                    },
                                                  ),
                                                  FxContainer(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 2),
                                                    borderRadiusAll: 0,
                                                    color: CustomTheme.accent,
                                                    child: FxText.bodySmall(
                                                      "VJ: " +
                                                          mainController
                                                              .watchedMovies[
                                                                  index]
                                                              .genre,
                                                      color: CustomTheme.color,
                                                      maxLines: 1,
                                                      fontWeight: 700,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
              ),
            ),
          ],
        ));
  }
}
