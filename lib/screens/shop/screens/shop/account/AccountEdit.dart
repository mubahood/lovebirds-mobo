// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/flutx.dart';
import 'package:lovebirds_app/models/LoggedInUserModel.dart';

import '../../../../../models/RespondModel.dart';
import '../../../../../utils/CustomTheme.dart';
import '../../../../../utils/Utilities.dart';
import '../widgets.dart';


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
      backgroundColor: CustomTheme.primary,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: CustomTheme.primary,
        systemOverlayStyle: Utils.overlay(),
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child:  const Icon(
            Icons.arrow_back_outlined,
            color : CustomTheme.accent
          ),
        ),
        actions: [
          is_loading
              ? const Padding(
                  padding:
                      EdgeInsets.only(right: 20, top: 10, bottom: 10),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(CustomTheme.primary),
                    ),
                  ),
                )
              : FxButton.text(
                  onPressed: () {
                    save_form();
                  },
                  child: FxText.bodyLarge(
                    "SAVE",
                    color : CustomTheme.secondary,
                    fontWeight : 800,
                  ))
        ],
        title: FxText.titleMedium(
          "Editing profile",
          fontSize: 20,
          color: CustomTheme.accent,
          fontWeight : 700,
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
                                                        margin: const EdgeInsets.only(
                                                            bottom: 10),
                                                        color :
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
                                                  initialValue: item.name,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  name: "first_name",
                                                  onChanged: (x) {
                                                    item.name =
                                                        x.toString();
                                                  },
                                                  textInputAction:
                                                      TextInputAction.next,
                                                ),
                                                const SizedBox(height: 15),
                                                FormBuilderTextField(
                                                  decoration: CustomTheme.in_3(
                                                    label: "Middle name",
                                                  ),
                                                  initialValue:
                                                      item.name,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  name: "middle_name",
                                                  onChanged: (x) {
                                                    item.name =
                                                        x.toString();
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
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  name: "last_name",
                                                  onChanged: (x) {
                                                    item.name =
                                                        x.toString();
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
                                                      item.name,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  name: "phone_number_1",
                                                  onChanged: (x) {
                                                    item.name =
                                                        x.toString();
                                                  },
                                                  keyboardType:
                                                      TextInputType.phone,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                ),
                                                const SizedBox(height: 15),
                                                FormBuilderTextField(
                                                  decoration: CustomTheme.in_3(
                                                    label:
                                                        "Alternative Phone number",
                                                  ),
                                                  initialValue:
                                                  item.phone_number,
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  name: "phone_number",
                                                  onChanged: (x) {
                                                    item.phone_number =
                                                        x.toString();
                                                  },
                                                  keyboardType:
                                                      TextInputType.phone,
                                                  textInputAction:
                                                      TextInputAction.next,
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
                                                  },
                                                  keyboardType: TextInputType
                                                      .streetAddress,
                                                  textInputAction:
                                                      TextInputAction.done,
                                                ),
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


  // ignore: non_constant_identifier_names
  save_form() async {
    item = await LoggedInUserModel.getLoggedInUser();

    if (!_fKey.currentState!.validate()) {
      Utils.toast('Fix some errors first.', color :Colors.red.shade700);
      return;
    }
    setState(() {
      error_message = "";
      is_loading = true;
    });

    Utils.toast('Updating profile...', color :Colors.green.shade700);

    RespondModel resp = RespondModel(await Utils.http_post('update-profile', {
      'first_name': item.name,
      'address': item.name,
    }));

    setState(() {
      error_message = "";
      is_loading = false;
    });

    if (resp.code != 1) {
      is_loading = false;
      error_message = resp.message;
      setState(() {});
      Utils.toast('Failed', color :Colors.red.shade700);
      return;
    }

    Utils.toast('Profile updated successfully!');

    Navigator.pop(context);
    return;
  }

  Future<bool> init_form() async {
    item = await LoggedInUserModel.getLoggedInUser();
    return true;
  }

}
