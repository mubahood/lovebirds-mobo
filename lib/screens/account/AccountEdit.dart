// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/flutx.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/LoggedInUserModel.dart';
import '../../models/RespondModel.dart';
import '../../models/img.dart';
import '../../utils/AppConfig.dart';
import '../../utils/CustomTheme.dart';
import '../../utils/Utilities.dart';
import '../../utils/my_colors.dart';
import '../../widget/widgets.dart';
import '../shop/screens/shop/widgets.dart';

class AccountEdit extends StatefulWidget {
  const AccountEdit({
    Key? key,
  }) : super(key: key);

  @override
  AccountEditState createState() => AccountEditState();
}

class AccountEditState extends State<AccountEdit>
    with SingleTickerProviderStateMixin {
  // ignore: non_constant_identifier_names
  bool is_loading = false;

  // ignore: non_constant_identifier_names
  bool miain_loading = false;

  String text = "";

  var initFuture;
  String image_path = "";

  @override
  void initState() {
    super.initState();
    initFuture = init_form();
  }

  LoggedInUserModel item = LoggedInUserModel();
  final _fKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        systemOverlayStyle: Utils.overlay(),
        actions: [
          is_loading
              ? const Padding(
                  padding: EdgeInsets.only(right: 20, top: 10, bottom: 10),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : FxButton.text(
                  onPressed: () {
                    save_form();
                  },
                  child: FxText.titleMedium(
                    "SAVE",
                    color: Colors.white,
                    fontWeight: 900,
                  ))
        ],
        title: const Text(
          "Updating profile",
        ),
      ),
      body: FutureBuilder(
          future: initFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return FormBuilder(
              key: _fKey,
              child: Stack(
                children: [
                  miain_loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        )
                      : CustomScrollView(
                          slivers: [
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return Container(
                                      padding: const EdgeInsets.all(0),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(
                                              left: 15,
                                              top: 10,
                                              right: 15,
                                            ),
                                            child: Column(
                                              children: [
                                                const SizedBox(height: 10),
                                                error_message.isEmpty
                                                    ? const SizedBox()
                                                    : FxContainer(
                                                        margin: const EdgeInsets
                                                            .only(bottom: 10),
                                                        color:
                                                            Colors.red.shade50,
                                                        child: Text(
                                                          error_message,
                                                        ),
                                                      ),
                                                FormBuilderTextField(
                                                  decoration: CustomTheme.in_3(
                                                    label: "First name",
                                                  ),
                                                  validator: MyWidgets
                                                      .my_validator_field_required(
                                                          context,
                                                          'This field '),
                                                  initialValue: item.first_name,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  name: "first_name",
                                                  onChanged: (x) {
                                                    item.first_name =
                                                        x.toString();
                                                    item.save();
                                                  },
                                                  textInputAction:
                                                      TextInputAction.next,
                                                ),
                                                const SizedBox(height: 15),
                                                FormBuilderTextField(
                                                  decoration: CustomTheme.in_3(
                                                    label: "Last name",
                                                  ),
                                                  validator: MyWidgets
                                                      .my_validator_field_required(
                                                          context,
                                                          'This field '),
                                                  initialValue: item.last_name,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  name: "last_name",
                                                  onChanged: (x) {
                                                    item.last_name =
                                                        x.toString();
                                                    item.save();
                                                  },
                                                  textInputAction:
                                                      TextInputAction.next,
                                                ),
                                                const SizedBox(height: 15),
                                                FormBuilderTextField(
                                                  decoration: CustomTheme.in_3(
                                                    label: "Phone number",
                                                  ),
                                                  initialValue:
                                                      item.phone_number,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  name: "phone_number",
                                                  onChanged: (x) {
                                                    item.phone_number =
                                                        x.toString();
                                                    item.save();
                                                  },
                                                  keyboardType:
                                                      TextInputType.phone,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                ),
                                                const SizedBox(height: 15),
                                                FormBuilderTextField(
                                                  decoration: CustomTheme.in_3(
                                                    label: "Email address",
                                                  ),
                                                  initialValue: item.email,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  name: "email",
                                                  onChanged: (x) {
                                                    item.email = x.toString();
                                                    item.save();
                                                  },
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  validator:
                                                      FormBuilderValidators
                                                          .compose([
                                                    FormBuilderValidators
                                                        .email(),
                                                  ]),
                                                ),
                                                const SizedBox(height: 15),
                                                const SizedBox(height: 15),
                                                FormBuilderTextField(
                                                  decoration: CustomTheme.in_3(
                                                    label: "Address",
                                                  ),
                                                  initialValue: item.name,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  name: "address",
                                                  onChanged: (x) {
                                                    item.name = x.toString();
                                                    item.save();
                                                  },
                                                  keyboardType: TextInputType
                                                      .streetAddress,
                                                  textInputAction:
                                                      TextInputAction.done,
                                                ),
                                                const SizedBox(height: 15),
                                                FxContainer(
                                                  onTap: () {
                                                    _show_bottom_sheet_photo();
                                                  },
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade700),
                                                  bordered: true,
                                                  child: Row(
                                                    children: [
                                                      FxContainer(
                                                        paddingAll: 0,
                                                        borderRadiusAll: 10,
                                                        border: Border.all(
                                                            color: Colors
                                                                .grey.shade700),
                                                        bordered: true,
                                                        color:
                                                            CustomTheme.primary,
                                                        child:
                                                            image_path
                                                                    .isNotEmpty
                                                                ? ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    child: Image
                                                                        .file(
                                                                      File(
                                                                          image_path),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: Get
                                                                              .width /
                                                                          4.1,
                                                                      height:
                                                                          Get.width /
                                                                              4.1,
                                                                    ),
                                                                  )
                                                                : ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    child: item.avatar.length >
                                                                            4
                                                                        ? CachedNetworkImage(
                                                                            fit:
                                                                                BoxFit.fill,
                                                                            height:
                                                                                100,
                                                                            width:
                                                                                100,
                                                                            imageUrl:
                                                                                "${AppConfig.MAIN_SITE_URL}/storage/${item.avatar}",
                                                                            placeholder: (context, url) =>
                                                                                ShimmerLoadingWidget(height: Get.width / 2),
                                                                            errorWidget: (context, url, error) =>
                                                                                const Image(
                                                                              image: AssetImage(
                                                                                AppConfig.NO_IMAGE,
                                                                              ),
                                                                              fit: BoxFit.cover,
                                                                              height: 100,
                                                                              width: 100,
                                                                            ),
                                                                          )
                                                                        : Image
                                                                            .asset(
                                                                            Img.get('logo.png'),
                                                                            width:
                                                                                100,
                                                                            height:
                                                                                100,
                                                                          ),
                                                                  ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child:
                                                            FxText.titleLarge(
                                                          item.avatar.length > 4
                                                              ? "Change Profile Photo"
                                                              : "Add Profile Photo",
                                                          textAlign:
                                                              TextAlign.center,
                                                          fontWeight: 800,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ));
                                },
                                childCount: 1, // 1000 list items
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            );
          }),
    );
  }

  String error_message = "";

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
                      leading:
                          const Icon(Icons.camera_alt, color: MyColors.primary),
                      title: FxText.bodyLarge("Use Camera", fontWeight: 600),
                    ),
                    ListTile(
                        dense: false,
                        onTap: () {
                          Navigator.pop(context);
                          do_pick_image("gallery");
                        },
                        leading: const Icon(Icons.photo_library_sharp,
                            color: MyColors.primary),
                        title: FxText.bodyLarge("Pick from Gallery",
                            fontWeight: 600)),
                  ],
                ),
              ),
            ),
          );
        });
  }

  do_pick_image(String source) async {
    Utils.toast(source);

    final ImagePicker picker = ImagePicker();
    if (source == "camera") {
      final XFile? pic =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
      if (pic != null) {
        image_path = pic.path;
        setState(() {});
      }
    } else {
      final XFile? pic = await picker.pickImage(
          source: ImageSource.gallery, imageQuality: 100);
      if (pic != null) {
        image_path = pic.path;
        setState(() {});
      }
    }
  }

  // ignore: non_constant_identifier_names
  save_form() async {
    item = await LoggedInUserModel.getLoggedInUser();

    if (!_fKey.currentState!.validate()) {
      Utils.toast('Fix some errors first.', color: Colors.red.shade700);
      return;
    }
    setState(() {
      error_message = "";
      is_loading = true;
    });

    Utils.toast('Updating profile...', color: Colors.green.shade700);

    Map<String, dynamic> formDataMap = {
      'first_name': item.first_name,
      'last_name': item.last_name,
      'phone_number': item.phone_number,
      'email': item.email,
      'address': item.name,
    };

    if (image_path.isNotEmpty) {
      try {
        formDataMap['file'] =
            await dio.MultipartFile.fromFile(image_path, filename: image_path);
      } catch (e) {}
    }

    RespondModel resp =
        RespondModel(await Utils.http_post('update-profile', formDataMap));

    /*   await LoggedInUserModel.getOnlineItems();
    await LoggedInUserModel.getOnlineItems();
    mainController.getLoggedInUser();*/

    setState(() {
      error_message = "";
      is_loading = false;
    });

    if (resp.code != 1) {
      is_loading = false;
      error_message = resp.message;
      setState(() {});
      Utils.toast('Failed', color: Colors.red.shade700);
      return;
    }

    Utils.toast('Profile updated successfully!');

    Navigator.pop(context);
    return;
  }

  Future<bool> init_form() async {
    setState(() {
      miain_loading = true;
    });
    item = await LoggedInUserModel.getLoggedInUser();
    setState(() {
      miain_loading = false;
    });
    return true;
  }
}
