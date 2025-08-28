import 'package:flutter/material.dart';
import 'package:flutx/widgets/container/container.dart';
import 'package:flutx/widgets/text/text.dart';
import 'package:get/get.dart';
import 'package:lovebirds_app/utils/CustomTheme.dart';
import 'package:lovebirds_app/utils/Utilities.dart';

import '../../models/MovieModel.dart';
import '../shop/screens/shop/full_app/full_app.dart';

class GardensScreen extends StatefulWidget {
  const GardensScreen({super.key});

  @override
  State<GardensScreen> createState() => _GardensScreenState();
}

class _GardensScreenState extends State<GardensScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_items();
  }

  bool isLoading = false;
  bool searchMode = false;
  List<MovieModel> items = [];
  List<MovieModel> temp_items = [];

  Future<void> get_items() async {
    setState(() {
      isLoading = true;
    });
    temp_items = await MovieModel.get_items();
    setState(() {
      isLoading = false;
    });
    prepare_data();
  }

  void prepare_data() {
    if (keyword.isEmpty) {
      items = temp_items;
    } else {
      items = [];
      for (MovieModel item in temp_items) {
        if (item.title.toLowerCase().contains(keyword.toLowerCase())) {
          items.add(item);
        }
      }
    }
    if (show_downloaded) {
      List<MovieModel> temp = [];
      for (MovieModel item in items) {
        if (item.video_is_downloaded_to_server.toLowerCase() == 'yes') {
          temp.add(item);
        }
      }
      items = temp;
    }
    setState(() {});
  }

  String keyword = "";
  bool show_downloaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: searchMode
              ? FxContainer(
                  paddingAll: 0,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
                    ),
                    onChanged: (v) {
                      keyword = v.toString();
                      prepare_data();
                    },
                    style: const TextStyle(color: Colors.black),
                  ),
                )
              : FxText.titleLarge(
                  "${Utils.moneyFormat(items.length.toString())} Movies",
                  color: Colors.white,
                ),
          backgroundColor: CustomTheme.primary,
          actions: [
            IconButton(
              onPressed: () {
                Get.to(() => const HomeScreen());
              },
              icon: const Icon(
                Icons.ac_unit,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  searchMode = !searchMode;
                });
              },
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  show_downloaded = !show_downloaded;
                  prepare_data();
                });
              },
              icon: const Icon(
                Icons.filter_alt_outlined,
                color: Colors.white,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            get_items();
          },
          child: const Icon(Icons.add),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: get_items,
                color: CustomTheme.primary,
                backgroundColor: Colors.white,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    MovieModel item = items[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FxContainer(
                          onTap: () {
                            print(item.video_url);
                            print(item.thumbnail_url);
                          },
                          color: item.video_is_downloaded_to_server == 'yes'
                              ? Colors.green.shade100
                              : Colors.red.shade50,
                          borderRadiusAll: 0,
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              FxText.bodySmall(
                                "${Utils.to_date_1(item.created_at)} | DOWNLOADED ${(item.video_is_downloaded_to_server)}",
                                color: Colors.black,
                              ),
                              FxText.bodyLarge(
                                item.title,
                                color: Colors.black,
                                fontWeight: 600,
                              ),
                              /*  const SizedBox(
                                height: 10,
                              ),*/
                              /* Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.black,
                                    size: 14,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  FxText.bodySmall(
                                    item.created_at,
                                    color: Colors.black,
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.black,
                                    size: 14,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  FxText.bodySmall(
                                    Utils.to_date_3(item.created_at),
                                    color: Colors.black,
                                  ),
                                ],
                              )*/
                            ],
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                  itemCount: items.length,
                ),
              ));
  }
}
