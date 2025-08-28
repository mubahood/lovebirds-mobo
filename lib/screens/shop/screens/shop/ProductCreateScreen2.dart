// lib/screens/products/ProductCreateScreen2.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/widgets/button/button.dart';
import 'package:flutx/widgets/text/text.dart';
import 'package:get/get.dart';

import '../../../../controllers/MainController.dart';
import '../../../../models/RespondModel.dart';
import '../../../../utils/CustomTheme.dart';
import '../../../../utils/Utilities.dart';
import '../../models/Product.dart';

class ProductCreateScreen2 extends StatefulWidget {
  final Product item;

  const ProductCreateScreen2(this.item, {Key? key}) : super(key: key);

  @override
  _ProductCreateScreen2State createState() => _ProductCreateScreen2State();
}

class _ProductCreateScreen2State extends State<ProductCreateScreen2> {
  bool isLoading = false;
  bool mainLoading = false;
  String errorMessage = '';
  late Future<void> _initFuture;
  final _formKey = GlobalKey<FormBuilderState>();
  final _ctrl = Get.find<MainController>();

  @override
  void initState() {
    super.initState();
    widget.item.productCategory.getAttributesList();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    if (_ctrl.userModel.id < 1) {
      Utils.toast("Please login first");
      Navigator.pop(context);
    }
  }

  Future<bool> _onWillPop() async {
    final quit = await Get.defaultDialog<bool>(
      title: "Discard changes?",
      middleText: "Quit without saving your product?",
      actions: [
        FxButton.outlined(
          onPressed: () => Get.back(result: false),
          borderColor: CustomTheme.color3,
          child: FxText.bodySmall("CANCEL", color: CustomTheme.color3),
        ),
        FxButton(
          backgroundColor: CustomTheme.primary,
          onPressed: () => Get.back(result: true),
          child: FxText.bodySmall("QUIT",
              color: Colors.white, fontWeight: 700),
        ),
      ],
    );
    return quit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        backgroundColor: CustomTheme.background,
        elevation: 1,
        iconTheme: IconThemeData(color: CustomTheme.accent),
        title: FxText.titleLarge(
          "More Details",
          color: CustomTheme.accent,
          fontWeight: 700,
        ),
      ),
      body: FutureBuilder(
        future: _initFuture,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                // step indicator
                Container(
                  color: CustomTheme.cardDark,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: _step("Basic Info", false)),
                      const SizedBox(width: 16),
                      Expanded(child: _step("More Details", true)),
                    ],
                  ),
                ),

                // loading overlay for mainLoading
                if (mainLoading)
                  LinearProgressIndicator(
                    backgroundColor: CustomTheme.cardDark,
                    valueColor: AlwaysStoppedAnimation(CustomTheme.primary),
                  ),

                // fields
                Expanded(child: _fieldsSection()),

                // error banner
                if (errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    child: FxText.bodySmall(
                      errorMessage,
                      color: Colors.redAccent,
                    ),
                  ),

                // submit button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: isLoading
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
                        CustomTheme.primary),
                  )
                      : FxButton.block(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16),
                    borderRadiusAll: 10,
                    backgroundColor: CustomTheme.primary,
                    onPressed: _submit,
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        FxText.titleLarge(
                          "SUBMIT",
                          color: Colors.white,
                          fontWeight: 800,
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          FeatherIcons.check,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _step(String label, bool active) {
    return Column(
      children: [
        FxText.bodyMedium(
          label,
          color:
          active ? CustomTheme.primary : CustomTheme.color2,
          fontWeight: 700,
        ),
        const SizedBox(height: 4),
        Container(
          height: 3,
          color:
          active ? CustomTheme.primary : CustomTheme.color4,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _fieldsSection() {
    // final attrs = widget.item.productCategory.attributesList;
    final attrs = [];
    if (attrs.isEmpty) {
      return Center(
        child: FxText.bodyLarge(
          "Your product is ready to upload!",
          fontWeight: 700,
          color: CustomTheme.color,
          textAlign: TextAlign.center,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.card,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30)),
      ),
      padding:
      const EdgeInsets.only(top: 30, left: 20, right: 20),
      child: ListView.builder(
        itemCount: attrs.length,
        itemBuilder: (_, i) {
          final key = attrs[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: FormBuilderTextField(
              name: key,
              initialValue: widget.item.productCategory
                  .attributesData[key]
                  ?.toString() ??
                  '',
              decoration: InputDecoration(
                labelText: key,
                labelStyle:
                TextStyle(color: CustomTheme.color2),
                filled: true,
                fillColor: CustomTheme.card,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                  BorderSide(color: CustomTheme.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                  BorderSide(color: CustomTheme.primary),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: i == attrs.length - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
              onChanged: (v) {
                widget.item.productCategory.attributesData
                    .update(key, (_) => v ?? '',
                    ifAbsent: () => v ?? '');
              },
            ),
          );
        },
      ),
    );
  }


  bool is_loading = false;
  uploadPics() async {
    if (is_loading) {
      return;
    }
    is_loading = true;
    for (var x in widget.item.local_photos) {
      if (uploadedPics.contains(x.src)) {
        continue;
      }
      if (await x.uploadSelf()) {
        uploadedPics.add(x.src);
      }
      setState(() {});
      is_loading = false;
      uploadPics();
      break;
    }
  }

  List<String> uploadedPics = [];
  List<String> photosToUpload = [];


  Future<void> _submit() async {
    setState(() {
      is_loading = true;
    });
    uploadPics();

    var data = widget.item.toJson();
    data['category_id'] = widget.item.productCategory.id;
    widget.item.productCategory.getAttributesList();
    if (widget.item.productCategory.attributesData.isNotEmpty) {
      try {
        data['data'] = jsonEncode(widget.item.productCategory.attributesData);
      } catch (e) {}
    }

    if (widget.item.id > 0) {
      data['id'] = widget.item.id;
      data['is_edit'] = 'Yes';
      data['local_id'] = Utils.getUniqueText();
    } else {
      data['is_edit'] = 'No';
      widget.item.local_id = Utils.getUniqueText();
    }

    data['has_sizes'] = widget.item.has_sizes;
    data['has_colors'] = widget.item.has_colors;
    data['colors'] = widget.item.colors;
    data['sizes'] = widget.item.sizes;
    if (widget.item.p_type == 'Yes') {
      if (widget.item.pricesList.isEmpty) {
        Utils.toast('Please add prices');
        setState(() {
          is_loading = false;
        });
        return;
      }
      data['keywords'] = json.encode(widget.item.pricesList);
      data['price_1'] = '';
      data['price_1'] = '';
    } else {
      data['price_1'] = widget.item.price_1;
      data['price_1'] = widget.item.price_2;
      //keywords
      data['keywords'] = '';
    }

    String error_message = '';
    setState(() {
      error_message = '';
    });

    RespondModel? resp;

    Utils.showLoader(true);
    try {
      resp = RespondModel(await Utils.http_post('product-create', data));
    } catch (e) {
      Utils.toast('Failed to save product');
      error_message = e.toString();
      setState(() {
        is_loading = false;
      });
      return;
    }
    Utils.hideLoader();
    setState(() {
      is_loading = false;
    });


    if (resp.code != 1) {
      error_message = resp.message;
      Utils.toast(resp.message, color: Colors.red.shade700, isLong: true);
      setState(() {
        is_loading = false;
      });
      return;
    }

    setState(() {
      is_loading = false;
    });

    Product ? newPro = null;
    try {
      newPro = Product.fromJson(resp.data);
    } catch (e) {
      Utils.toast('Failed to parse product');
      error_message = e.toString();
      setState(() {
        is_loading = false;
      });
      return;
    }

    if (newPro == null) {
      Utils.toast('Failed to parse product');
      error_message = 'Failed to parse product';
      setState(() {
        is_loading = false;
      });
      return;
    }

    if (newPro.id < 1) {
      Utils.toast('Failed to parse product');
      error_message = 'Failed to parse product';
      setState(() {
        is_loading = false;
      });
      return;
    }
    await newPro.save();

    if (resp.code != 1) {
      return;
    }

    Utils.toast(resp.message);
    Utils.toast('Please wait');
    await Product.getOnlineItems();
    Product.getItems();
    Get.back(result: {'done': 'done'});

    Utils.toast(resp.message, color: Colors.red.shade700, isLong: true);
  }

  Future<void> _uploadPics() async {
    for (var x in widget.item.local_photos) {
      if (await x.uploadSelf()) {
        setState(() {});
        await _uploadPics();
        break;
      }
    }
  }
}