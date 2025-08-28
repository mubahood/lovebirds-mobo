import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lovebirds_app/utils/CustomTheme.dart';

import '../../utils/Utilities.dart';
import '../shop/screens/shop/models/ImageModelLocal.dart';

class ImagesPickerScreen extends StatefulWidget {
  List<String> allImages = [];
  List<String> uploadedImages = [];
  String parent_id = "";
  String type = "";

  ImagesPickerScreen(
      this.allImages, this.uploadedImages, this.parent_id, this.type,
      {super.key});

  @override
  State<ImagesPickerScreen> createState() => _ImagesPickerScreenState();
}

class _ImagesPickerScreenState extends State<ImagesPickerScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_items();
  }

  bool isLoading = false;

  Future<void> get_items() async {
    setState(() {
      isLoading = true;
    });
    upload_photos();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FxText.titleMedium(
                "Select Members",
                fontWeight: 800,
                color: Colors.white,
              ),
              FxText.bodyMedium(
                "${widget.uploadedImages.length} of ${widget.allImages.length} images uploaded",
                color: Colors.white,
              ),
            ],
          ),
          backgroundColor: CustomTheme.primary,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: get_items,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          String imagePath = widget.allImages[index];
                          return Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(imagePath),
                                      fit: BoxFit.fitWidth,
                                      width: Get.width / 4.1,
                                      height: Get.width / 4.1,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      widget.uploadedImages.contains(imagePath)
                                          ? FxContainer(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              onTap: () {
                                                //upload_photo(imagePath);
                                              },
                                              color: Colors.green.shade800,
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 15,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  FxText.bodySmall(
                                                    "Uploaded",
                                                    color: Colors.white,
                                                    fontWeight: 700,
                                                  ),
                                                ],
                                              ),
                                            )
                                          : FxContainer(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              color: Colors.yellow.shade800,
                                              child: Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 10,
                                                    height: 10,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                      backgroundColor:
                                                          Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  FxText.bodySmall(
                                                    "Uploading...",
                                                    color: Colors.white,
                                                    fontWeight: 700,
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                        itemCount: widget.allImages.length,
                      ),
                    ),
                  ),
                  FxContainer(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: FxButton.block(
                            onPressed: () {
                              _show_bottom_sheet_photo();
                            },
                            borderRadiusAll: 0,
                            backgroundColor: CustomTheme.primary,
                            child: FxText.bodyLarge(
                              "ADD PHOTO",
                              color: Colors.white,
                              fontWeight: 700,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: FxButton.block(
                            onPressed: () {
                              Navigator.pop(context, widget.allImages);
                            },
                            borderRadiusAll: 0,
                            backgroundColor: CustomTheme.primary,
                            child: FxText.bodyLarge(
                              "DONE",
                              color: Colors.white,
                              fontWeight: 700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ));
  }

  Future<void> _show_bottom_sheet_photo() async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext buildContext) {
          return Container(
            color: Colors.transparent,
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16))),
              child: Padding(
                padding: FxSpacing.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        do_pick_image("camera");
                      },
                      dense: false,
                      leading: const Icon(Icons.camera_alt,
                          color: CustomTheme.primary),
                      title: FxText.bodyLarge("Use Camera", fontWeight: 600),
                    ),
                    ListTile(
                        dense: false,
                        onTap: () {
                          Navigator.pop(context);
                          do_pick_image("gallery");
                        },
                        leading: const Icon(Icons.photo_library_sharp,
                            color: CustomTheme.primary),
                        title: FxText.bodyLarge("Pick from Gallery",
                            fontWeight: 600)),
                  ],
                ),
              ),
            ),
          );
        });
  }

  upload_photos() async {
    //loop and upload all photos
    for (String imagePath in widget.allImages) {
      if (widget.uploadedImages.contains(imagePath)) {
        continue;
      }
      ImageModelLocal img = ImageModelLocal();
      img.media_path = imagePath;
      img.ready_to_upload = "Yes";
      img.media_path = imagePath;
      img.src = imagePath;
      img.thumbnail = imagePath;
      img.parent_id = widget.parent_id;
      img.product_id = widget.parent_id;
      img.local_parent_id = widget.parent_id;
      img.online_parent_id = '0';
      img.type = widget.type;
      img.parent_endpoint = widget.type;
      img.item_type = widget.type;
      img.note = widget.type;
      await img.save();
      if (await img.uploadSelf()) {
        widget.uploadedImages.add(imagePath);
        setState(() {});
      }
    }
  }

  /*Future<void> upload_photo(String imagePath) async {
    if(widget.uploadedImages.contains(imagePath)){
      return;
    }
    ImageModelLocal img = ImageModelLocal();
    img.media_path = imagePath;
    img.ready_to_upload = "Yes";
    img.media_path = imagePath;
    img.src = imagePath;
    img.thumbnail = imagePath;
    img.parent_id = widget.parent_id;
    img.product_id = widget.parent_id;
    img.local_parent_id = widget.parent_id;
    img.online_parent_id = '0';
    img.type = 'TrainingSession';
    img.parent_endpoint = 'TrainingSession';
    img.item_type = 'TrainingSession';
    img.note = 'TrainingSession';
    await img.save();
    if(await img.uploadSelf()){
      widget.uploadedImages.add(imagePath);
      setState(() {});
    }
  }*/

  do_pick_image(String source) async {
    Utils.toast(source);

    final ImagePicker picker = ImagePicker();
    if (source == "camera") {

    } else {

    }
  }
}
