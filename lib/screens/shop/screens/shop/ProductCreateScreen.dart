// lib/screens/products/ProductCreateScreen.dart

import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutx/widgets/button/button.dart';
import 'package:flutx/widgets/container/container.dart';
import 'package:flutx/widgets/text/text.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../controllers/MainController.dart';
import '../../../../models/RespondModel.dart';
import '../../../../utils/AppConfig.dart';
import '../../../../utils/CustomTheme.dart';
import '../../../../utils/Utilities.dart';
import '../../models/ImageModelLocal.dart';
import '../../models/Product.dart';
import '../../models/ProductCategory.dart';
import 'ColorPickerScreen.dart';
import 'HtmlEditorScreen.dart';
import 'PricesEntryScreen.dart';
import 'ProductCreateScreen2.dart';
import 'SizesPickerScreen.dart';

class ProductCreateScreen extends StatefulWidget {
  final Map<String, dynamic> params;

  const ProductCreateScreen(this.params, {Key? key}) : super(key: key);

  @override
  _ProductCreateScreenState createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen>
    with SingleTickerProviderStateMixin {
  late Product item;
  bool isLoading = false, mainLoading = false, isEdit = false;
  late Future<void> futureInit;
  final _fKey = GlobalKey<FormBuilderState>();
  final mainController = Get.find<MainController>();
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    item =
        widget.params['item'] is Product
            ? widget.params['item'] as Product
            : Product();
    if (item.local_id.length < 3) item.local_id = Utils.getUniqueText();
    if (item.id > 0) isEdit = true;
    futureInit = _initialize();
  }

  Future<void> _initialize() async {
    if (mainController.userModel.id < 1) {
      Utils.toast("Please login first");
      Navigator.pop(context);
      return;
    }
    if (item.category.isNotEmpty) {
      final cats = await ProductCategory.getItems(
        where: 'id = ${item.category}',
      );
      if (cats.isNotEmpty) {
        item.productCategory = cats.first;
      }
    }
    if (isEdit) {
      await item.getOnlinePhotos();
      setState(() {});
    }

    await mainController.getCategories();
    if (mainController.categories.isEmpty) {
      await mainController.getCategories();
    }
    if (mainController.categories.isEmpty) {
      Utils.toast("No categories found");
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
          child: FxText.bodySmall("QUIT", color: Colors.white, fontWeight: 700),
        ),
      ],
    );
    return quit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: CustomTheme.background,
        appBar: AppBar(
          backgroundColor: CustomTheme.background,
          elevation: 1,
          iconTheme: IconThemeData(color: CustomTheme.accent),
          title: FxText.titleLarge(
            isEdit ? "Edit Product" : "New Product",
            color: CustomTheme.accent,
            fontWeight: 700,
          ),
        ),
        body: FutureBuilder<void>(
          future: futureInit,
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildForm();
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return FormBuilder(
      key: _fKey,
      child: Stack(
        children: [
          Column(children: [_buildSteps(), Expanded(child: _buildFields())]),
          if (mainLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(CustomTheme.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSteps() {
    return Container(
      color: CustomTheme.cardDark,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _step("Basic Info", true)),
          const SizedBox(width: 16),
          Expanded(child: _step("Details", false)),
        ],
      ),
    );
  }

  Widget _step(String label, bool active) {
    return Column(
      children: [
        FxText.bodyMedium(
          label,
          color: active ? CustomTheme.primary : CustomTheme.color2,
          fontWeight: 700,
        ),
        const SizedBox(height: 4),
        Container(
          height: 3,
          color: active ? CustomTheme.primary : CustomTheme.color4,
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildFields() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          _addPhotoButton(),
          SizedBox(height: 15),
          if (item.local_photos.isNotEmpty) _localPhotosList(),
          if (isEdit && item.online_photos.isNotEmpty) _onlinePhotosList(),
          const SizedBox(height: 20),

          // Product Name
          FormBuilderTextField(
            name: 'name',
            initialValue: item.name,
            decoration: InputDecoration(
              labelText: 'Product Name',
              labelStyle: TextStyle(color: CustomTheme.color2),
              filled: true,
              fillColor: CustomTheme.card,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: CustomTheme.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: CustomTheme.primary),
              ),
            ),
            validator: FormBuilderValidators.required(),
            onChanged: (v) => item.name = v ?? "",
          ),
          const SizedBox(height: 16),

          // Weight
          FormBuilderTextField(
            name: 'url',
            initialValue: item.url,
            decoration: InputDecoration(
              labelText: 'Weight (kg)',
              labelStyle: TextStyle(color: CustomTheme.color2),
              filled: true,
              fillColor: CustomTheme.card,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: CustomTheme.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: CustomTheme.primary),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.numeric(),
            ]),
            onChanged: (v) => item.url = v ?? "",
          ),
          const SizedBox(height: 16),

          // Category
          FormBuilderTextField(
            name: 'category_text',
            initialValue: item.category_text,
            readOnly: true,
            onTap: _showCategoryPicker,
            decoration: InputDecoration(
              labelText: 'Category',
              labelStyle: TextStyle(color: CustomTheme.color2),
              filled: true,
              fillColor: CustomTheme.card,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: CustomTheme.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: CustomTheme.primary),
              ),
            ),
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 16),

          // Color options
          FormBuilderRadioGroup<String>(
            name: 'has_colors',
            initialValue: item.has_colors,
            decoration: InputDecoration(
              labelText: 'Has Color Options?',
              labelStyle: TextStyle(color: CustomTheme.color2),
              filled: true,
              fillColor: CustomTheme.card,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: CustomTheme.primary),
              ),
            ),
            options: const [
              FormBuilderFieldOption(value: 'Yes'),
              FormBuilderFieldOption(value: 'No'),
            ],
            onChanged: (v) {
              item.has_colors = v!;
              setState(() {});
            },
            validator: FormBuilderValidators.required(),
          ),
          if (item.has_colors == 'Yes') ...[
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'colors',
              initialValue: item.colors,
              readOnly: true,
              onTap: () async {
                await Get.bottomSheet(
                  ColorPickerScreen(item.colorList),
                  backgroundColor: CustomTheme.card,
                );
                item.colors = jsonEncode(item.colorList);
                _fKey.currentState!.patchValue({'colors': item.colors});
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Pick Colors',
                labelStyle: TextStyle(color: CustomTheme.color2),
                filled: true,
                fillColor: CustomTheme.card,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: CustomTheme.primary),
                ),
              ),
              validator: FormBuilderValidators.required(),
            ),
          ],
          const SizedBox(height: 16),

          // Sizes
          FormBuilderRadioGroup<String>(
            name: 'has_sizes',
            initialValue: item.has_sizes,
            decoration: InputDecoration(
              labelText: 'Multiple Sizes?',
              labelStyle: TextStyle(color: CustomTheme.color2),
              filled: true,
              fillColor: CustomTheme.card,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: CustomTheme.primary),
              ),
            ),
            options: const [
              FormBuilderFieldOption(value: 'Yes'),
              FormBuilderFieldOption(value: 'No'),
            ],
            onChanged: (v) {
              item.has_sizes = v!;
              setState(() {});
            },
            validator: FormBuilderValidators.required(),
          ),
          if (item.has_sizes == 'Yes') ...[
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'sizes',
              initialValue: item.sizes,
              readOnly: true,
              onTap: () async {
                await Get.bottomSheet(
                  SizesPickerScreen(item.sizesList),
                  backgroundColor: CustomTheme.card,
                );
                item.sizes = jsonEncode(item.sizesList);
                _fKey.currentState!.patchValue({'sizes': item.sizes});
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Pick Sizes',
                labelStyle: TextStyle(color: CustomTheme.color2),
                filled: true,
                fillColor: CustomTheme.card,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: CustomTheme.primary),
                ),
              ),
              validator: FormBuilderValidators.required(),
            ),
          ],
          const SizedBox(height: 16),

          // Prices
          FormBuilderRadioGroup<String>(
            name: 'p_type',
            initialValue: item.p_type,
            decoration: InputDecoration(
              labelText: 'Multiple Prices?',
              labelStyle: TextStyle(color: CustomTheme.color2),
              filled: true,
              fillColor: CustomTheme.card,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: CustomTheme.primary),
              ),
            ),
            options: const [
              FormBuilderFieldOption(value: 'Yes'),
              FormBuilderFieldOption(value: 'No'),
            ],
            onChanged: (v) {
              item.p_type = v!;
              setState(() {});
            },
            validator: FormBuilderValidators.required(),
          ),
          if (item.p_type == 'Yes') ...[
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'prices',
              initialValue: item.get_price_text(),
              readOnly: true,
              onTap: () async {
                await Get.bottomSheet(
                  FractionallySizedBox(
                    heightFactor: 0.9,
                    child: PricesEntryScreen(selected: item.pricesList),
                  ),
                  backgroundColor: CustomTheme.card,
                );
                _fKey.currentState!.patchValue({
                  'prices': item.get_price_text(),
                });
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Set Prices',
                labelStyle: TextStyle(color: CustomTheme.color2),
                filled: true,
                fillColor: CustomTheme.card,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: CustomTheme.primary),
                ),
              ),
              validator: FormBuilderValidators.required(),
            ),
          ] else ...[
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'price_2',
              initialValue: item.price_2,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Original Price (${AppConfig.CURRENCY})',
                labelStyle: TextStyle(color: CustomTheme.color2),
                filled: true,
                fillColor: CustomTheme.card,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: CustomTheme.primary),
                ),
              ),
              onChanged: (v) => item.price_2 = v ?? "",
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'price_1',
              initialValue: item.price_1,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Selling Price (${AppConfig.CURRENCY})',
                labelStyle: TextStyle(color: CustomTheme.color2),
                filled: true,
                fillColor: CustomTheme.card,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: CustomTheme.primary),
                ),
              ),
              onChanged: (v) => item.price_1 = v ?? "",
              validator: FormBuilderValidators.required(),
            ),
          ],
          const SizedBox(height: 24),

          // Description
          FxContainer(
            paddingAll: 12,
            color: CustomTheme.card,
            width: double.infinity,
            borderRadiusAll: 12,
            child: InkWell(
              onTap: () async {
                final res = await Get.to(
                  () => HtmlEditorScreen(
                    data: item.description,
                    title: 'Description',
                  ),
                );
                if (res != null) {
                  item.description = res;
                  setState(() {});
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FxText.titleSmall(
                    "Description",
                    color: CustomTheme.color,
                    fontWeight: 700,
                  ),
                  const SizedBox(height: 8),
                  Html(
                    data: item.description,
                    style: {
                      '*': Style(color: CustomTheme.color2),
                      'strong': Style(color: CustomTheme.primary),
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (!_keyboardVisible) _nextButton(),
        ],
      ),
    );
  }

  Widget _addPhotoButton() {
    return GestureDetector(
      onTap: _addPhotos,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: CustomTheme.primary.withValues(alpha: .1),
          border: Border.all(color: CustomTheme.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FeatherIcons.camera, color: CustomTheme.primary),
            const SizedBox(width: 8),
            FxText.bodyMedium(
              "Add Photos",
              color: CustomTheme.primary,
              fontWeight: 700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _localPhotosList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: item.local_photos.length,
        itemBuilder: (_, i) => _singleLocalImage(item.local_photos[i].src, i),
      ),
    );
  }

  Widget _onlinePhotosList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FxText.titleMedium(
          "Uploaded Photos",
          color: CustomTheme.color,
          fontWeight: 700,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: item.online_photos.length,
            itemBuilder:
                (_, i) => _singleOnlineImage(item.online_photos[i].src, i),
          ),
        ),
      ],
    );
  }

  Widget _singleLocalImage(String path, int i) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: CustomTheme.primary, width: 3),
            color: CustomTheme.primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.file(File(path), fit: BoxFit.cover, width: 100),
          ),
        ),
        Positioned(
          right: 0,
          child: Center(
            child: FxContainer(
              paddingAll: 5,
              width: 35,
              height: 35,
              color:
                  uploadedPics.contains(path)
                      ? Colors.green.shade700
                      : Colors.white.withValues(alpha: .6),
              borderRadiusAll: 100,
              child:
                  uploadedPics.contains(path)
                      ? const Icon(Icons.check, color: Colors.white)
                      : const CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          CustomTheme.primary,
                        ),
                      ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _singleOnlineImage(String src, int i) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: CustomTheme.primary, width: 3),
            color: CustomTheme.primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CachedNetworkImage(
              imageUrl: '${AppConfig.DASHBOARD_URL}/storage/$src',
              fit: BoxFit.cover,
              width: 100,
              placeholder:
                  (_, __) => const Center(child: CircularProgressIndicator()),
              errorWidget:
                  (_, __, ___) => const Icon(Icons.broken_image, size: 48),
            ),
          ),
        ),
        Positioned(
          right: 0,
          child: GestureDetector(
            onTap: () => _confirmDeleteOnline(i),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showCategoryPicker() async {
    if (mainController.categories.isEmpty) {
      Utils.toast("Please wait...");
      await mainController.getCategories();
    } else {
      mainController.getCategories();
    }
    if (mainController.categories.isEmpty) {
      Utils.toast("No categories found");
      return;
    }

    showModalBottomSheet(
      context: context,
      barrierColor: CustomTheme.background.withValues(alpha: .5),
      builder:
          (_) => Container(
            decoration: BoxDecoration(
              color: CustomTheme.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FxText.titleMedium(
                        "Select Category",
                        color: CustomTheme.accent,
                        fontWeight: 700,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(FeatherIcons.x, color: CustomTheme.color2),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.grey),
                Expanded(
                  child: ListView.builder(
                    itemCount: mainController.categories.length,
                    itemBuilder: (_, idx) {
                      final cat = mainController.categories[idx];
                      return ListTile(
                        onTap: () {
                          item.productCategory = cat;
                          item.category = cat.id.toString();
                          _fKey.currentState!.patchValue({
                            'category_text': cat.category,
                          });
                          setState(() {});
                          Navigator.pop(context);
                        },
                        title: FxText.bodyMedium(
                          cat.category,
                          color: CustomTheme.color,
                        ),
                        trailing:
                            cat.id == item.productCategory.id
                                ? Icon(
                                  Icons.check_circle,
                                  color: CustomTheme.primary,
                                )
                                : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _confirmDeleteOnline(int i) {
    Get.defaultDialog(
      title: "Delete photo?",
      middleText: "Are you sure?",
      actions: [
        FxButton.outlined(
          onPressed: () => Navigator.pop(context),
          borderColor: CustomTheme.color3,
          child: FxText.bodySmall("CANCEL", color: CustomTheme.color3),
        ),
        FxButton(
          backgroundColor: Colors.redAccent,
          onPressed: () async {
            Navigator.pop(context);
            final resp = RespondModel(
              await Utils.http_post("images-delete", {
                'id': item.online_photos[i].id,
              }),
            );
            if (resp.code == 1) {
              item.online_photos.removeAt(i);
              setState(() {});
            }
          },
          child: FxText.bodySmall("DELETE", color: Colors.white),
        ),
      ],
    );
  }

  Future<void> _addPhotos() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: CustomTheme.cardDark,
      builder:
          (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: CustomTheme.primary),
                title: FxText.bodyMedium(
                  "Use Camera",
                  color: CustomTheme.color,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: CustomTheme.primary),
                title: FxText.bodyMedium(
                  "From Gallery",
                  color: CustomTheme.color,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
    );
  }

  Future<void> _pickFromCamera() async {
    final pic = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pic != null) {
      await _saveLocalImage(pic.path);
      setState(() {});
    }
  }

  Future<void> _pickFromGallery() async {
    final pics = await ImagePicker().pickMultiImage();
    for (var x in pics) {
      await _saveLocalImage(x.path);
    }
    setState(() {});
  }

  Future<void> _saveLocalImage(String path) async {
    final img = ImageModel();
    img.type = 'Product';
    img.src = path;
    img.parent_id = item.id.toString();
    img.parent_local_id = item.local_id;
    photosToUpload.add(img.src);
    await img.save();
    item.local_photos.add(img);
    uploadPics();
  }

  bool isUploading = false;
  List<String> uploadedPics = [];
  uploadPics() async {
    if (isUploading) {
      return;
    }
    isUploading = true;
    for (var x in item.local_photos) {
      if (uploadedPics.contains(x.src)) {
        continue;
      }
      if (await x.uploadSelf()) {
        uploadedPics.add(x.src);
      }
      setState(() {});
      isUploading = false;
      uploadPics();
      break;
    }
  }

  //1747403076646680106113325254908656464228434278588696997

  void _removeLocal(String path, int i) async {
    item.local_photos.removeAt(i);
    await ImageModel().delete(); // your delete logic
    setState(() {});
  }

  List<String> photosToUpload = [];

  Widget _nextButton() {
    return FxButton(
      block: true,
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderRadiusAll: 10,
      onPressed: _submit,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FxText.titleLarge("NEXT", fontWeight: 800, color: Colors.white),
          const SizedBox(width: 8),
          Icon(FeatherIcons.arrowRight, color: Colors.white),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_fKey.currentState!.validate()) {
      Utils.toast("Fix errors before proceeding.");
      return;
    }
    if (item.productCategory.id < 1) {
      Utils.toast("Please select a category.");
      return;
    }
    if (item.local_photos.isEmpty && item.online_photos.isEmpty) {
      Utils.toast("Add at least one image.");
      return;
    }
    if (Utils.int_parse(item.price_2) < Utils.int_parse(item.price_1)) {
      Utils.toast("Original price should exceed selling price.");
      return;
    }
    // sizes/colors/prices validations omitted for brevity...
    final result = await Get.to(() => ProductCreateScreen2(item));
    if (result?['done'] == 'done') {
      Get.back(result: {'done': 'done'});
    }
  }
}
