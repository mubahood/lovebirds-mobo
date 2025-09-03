import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

import '../../../../utils/AppConfig.dart';
import '../../../../utils/Utilities.dart';

class ColorPickerScreen extends StatefulWidget {
  List<String> selected = [];

  ColorPickerScreen(this.selected, {super.key});

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Select Colours"),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.close,
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
            Expanded(
              child: ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: FxContainer(
                        bordered: true,
                        width: 40,
                        borderRadiusAll: 30,
                        height: 40,
                        color: Utils.getColor(AppConfig.COLORS[index]),
                      ),
                      trailing:
                          widget.selected.contains(AppConfig.COLORS[index])
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                )
                              : null,
                      title: FxText.titleLarge(
                        AppConfig.COLORS[index], color: Colors.white,),
                      onTap: () {
                        if (widget.selected.contains(AppConfig.COLORS[index])) {
                          widget.selected.remove(AppConfig.COLORS[index]);
                        } else {
                          widget.selected.add(AppConfig.COLORS[index]);
                        }
                        setState(() {});
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                  itemCount: AppConfig.COLORS.length),
            ),
            Container(
              width: double.infinity,
              padding: FxSpacing.xy(16, 8),
              child: FxButton(
                onPressed: () {
                  Navigator.pop(context, widget.selected);
                },
                borderRadiusAll: 4,
                splashColor: FxAppTheme.theme.colorScheme.primary,
                elevation: 0,
                child: FxText.labelLarge(
                  "Done",
                  color: FxAppTheme.theme.colorScheme.onPrimary,
                  fontWeight: 600,
                  fontSize: 20,
                ),
              ),
            )
          ],
        ));
  }
}
