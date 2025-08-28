import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/flutx.dart';
import 'package:get/get.dart';

import '../../../../utils/CustomTheme.dart';


class SizesPickerScreen extends StatefulWidget {
  List<String> selected = [];

  SizesPickerScreen(this.selected, {super.key});

  @override
  State<SizesPickerScreen> createState() => _SizesPickerScreenState();
}

class _SizesPickerScreenState extends State<SizesPickerScreen> {
  String size = "";
  final _fKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Enter Sizes"),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.check,
                size: 35,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: Column(
          children: [
            Container(
              color: Colors.grey.shade300,
              padding: FxSpacing.xy(16, 8),
              child: Row(
                children: [
                  FormBuilder(
                    key: _fKey,
                    child: Container(
                      width: Get.width / 1.8,
                      child: FormBuilderTextField(
                        decoration: CustomTheme.input_decoration(
                          labelText: 'Enter size',
                        ),
                        name: 'sizes',
                        onChanged: (x) {
                          size = x.toString();
                        },
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ),
                  FxSpacing.width(16),
                  Container(
                    width: Get.width / 3.5,
                    child: FxButton(
                      onPressed: () {
                        if (size.isNotEmpty) {
                          widget.selected.add(size);
                          setState(() {});
                          _fKey.currentState!.patchValue({
                            'sizes': '',
                          });
                        }
                      },
                      borderRadiusAll: 4,
                      padding: FxSpacing.xy(16, 16),
                      splashColor: FxAppTheme.theme.colorScheme.primary,
                      elevation: 0,
                      child: FxText.labelLarge(
                        "Add",
                        color: FxAppTheme.theme.colorScheme.onPrimary,
                        fontWeight: 600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: FxText.titleLarge(widget.selected[index]),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            widget.selected.removeAt(index);
                            setState(() {});
                          },
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider();
                    },
                    itemCount: widget.selected.length)),
          ],
        ));
  }
}
