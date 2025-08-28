import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class HtmlEditorScreen extends StatefulWidget {
  final String title;
  String data;

  HtmlEditorScreen({Key? key, required this.title, required this.data})
    : super(key: key);

  @override
  _HtmlEditorScreenState createState() => _HtmlEditorScreenState();
}

class _HtmlEditorScreenState extends State<HtmlEditorScreen> {
  final HtmlEditorController controller = HtmlEditorController();

  String results = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //ensure builder is called only once
    futureInit = my_init();
  }

  bool initialized = false;

  Future<dynamic> my_init() async {
    setState(() {});
    return [];
  }

  late Future<dynamic> futureInit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () async {
              Get.back(result: widget.data);
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: futureInit,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return GestureDetector(
            onTap: () {
              if (!kIsWeb) {
                controller.clearFocus();
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child:
                  true
                      ? FormBuilderTextField(
                        decoration: const InputDecoration(
                          labelText: null,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none
                        ),
                        maxLines: 50,
                        minLines: 20,
                        autofocus: true,
                        initialValue: widget.data,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.text,
                        name: 'name',
                        onChanged: (x) {
                          widget.data = x.toString();
                        },
                        textInputAction: TextInputAction.next,
                      )
                      : HtmlEditor(
                        controller: controller,
                        htmlEditorOptions: const HtmlEditorOptions(
                          hint: 'Your text here...',
                          shouldEnsureVisible: true,
                          //initialText: "<p>text content initial, if any</p>",
                        ),
                        htmlToolbarOptions: HtmlToolbarOptions(
                          toolbarPosition: ToolbarPosition.belowEditor,
                          //by default
                          toolbarType: ToolbarType.nativeScrollable,
                          //by default
                          onButtonPressed: (
                            ButtonType type,
                            bool? status,
                            Function? updateStatus,
                          ) {
                            print(
                              "button '${describeEnum(type)}' pressed, the current selected status is $status",
                            );
                            return true;
                          },
                          onDropdownChanged: (
                            DropdownType type,
                            dynamic changed,
                            Function(dynamic)? updateSelectedItem,
                          ) {
                            print(
                              "dropdown '${describeEnum(type)}' changed to $changed",
                            );
                            return true;
                          },
                          mediaLinkInsertInterceptor: (
                            String url,
                            InsertFileType type,
                          ) {
                            print(url);
                            return true;
                          },
                        ),
                        otherOptions: OtherOptions(height: Get.height * 0.86),
                        callbacks: Callbacks(
                          onBeforeCommand: (String? currentHtml) {},
                          onChangeContent: (String? changed) {
                            results = changed!;
                          },
                          onInit: () {
                            controller.setText(widget.data);
                          },
                          onImageUploadError: (
                            FileUpload? file,
                            String? base64Str,
                            UploadError error,
                          ) {
                            print(base64Str ?? '');
                            if (file != null) {
                              print(file.name);
                              print(file.size);
                              print(file.type);
                            }
                          },
                          onKeyDown: (int? keyCode) {
                            print('$keyCode key downed');
                            print(
                              'current character count: ${controller.characterCount}',
                            );
                          },
                          onKeyUp: (int? keyCode) {
                            print('$keyCode key released');
                          },
                          onMouseDown: () {
                            print('mouse downed');
                          },
                          onMouseUp: () {
                            print('mouse released');
                          },
                          onNavigationRequestMobile: (String url) {
                            print(url);
                            return NavigationActionPolicy.ALLOW;
                          },
                          onPaste: () {
                            print('pasted into editor');
                          },
                          onScroll: () {
                            print('editor scrolled');
                          },
                        ),
                        plugins: [
                          SummernoteAtMention(
                            getSuggestionsMobile: (String value) {
                              var mentions = <String>[
                                'test1',
                                'test2',
                                'test3',
                              ];
                              return mentions
                                  .where((element) => element.contains(value))
                                  .toList();
                            },
                            mentionsWeb: ['test1', 'test2', 'test3'],
                            onSelect: (String value) {
                              print(value);
                            },
                          ),
                        ],
                      ),
            ),
          );
        },
      ),
    );
  }
}
