// lib/screens/account/AccountEditContactScreen.dart

import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/flutx.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/LoggedInUserModel.dart';
import '../../../models/RespondModel.dart';
import '../../../utils/CustomTheme.dart';
import '../../../utils/Utilities.dart'; // still named Utilities.dart, but class is Utils

class AccountEditContactScreen extends StatefulWidget {
  LoggedInUserModel user;

  AccountEditContactScreen({Key? key, required this.user}) : super(key: key);

  @override
  _AccountEditContactScreenState createState() =>
      _AccountEditContactScreenState();
}

class _AccountEditContactScreenState extends State<AccountEditContactScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late LoggedInUserModel _item;
  bool _isSaving = false;
  String _error = "";
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _item = widget.user;
  }

  Future<void> _pickAvatar() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _pickedImage = File(img.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      Utils.toast('Please fix errors first', color: Colors.red.shade700);
      return;
    }

    //validate , phone number mus start with +
    if (_item.phone_country_code.isEmpty) {
      Utils.toast('Please select a country code', color: Colors.red.shade700);
      return;
    }
    if (_item.phone_number.isEmpty) {
      Utils.toast('Please enter a phone number', color: Colors.red.shade700);
      return;
    }
    if (!_item.phone_number.startsWith('+')) {
      Utils.toast('Phone number must start with +', color: Colors.red.shade700);
      return;
    }
    if (_item.phone_number.length < 7) {
      Utils.toast('Phone number too short.', color: Colors.red.shade700);
      return;
    }
    if (_item.first_name.isEmpty) {
      Utils.toast('Please enter your first name', color: Colors.red.shade700);
      return;
    }
    if (_item.last_name.isEmpty) {
      Utils.toast('Please enter your last name', color: Colors.red.shade700);
      return;
    }

    //country is necessary
    if (_item.country.isEmpty) {
      Utils.toast('Please select a country', color: Colors.red.shade700);
      return;
    }

    setState(() {
      _isSaving = true;
      _error = "";
    });

    Map<String, dynamic> data = _item.toJson();
    data['temp_file_field'] = 'avatar';

    if (_pickedImage != null) {
      if (_pickedImage!.path.length > 3) {
        data['photo'] = await MultipartFile.fromFile(
          _pickedImage!.path,
          filename: _pickedImage!.path,
        );
      }
    }

    // TODO: upload avatar if picked

    final resp = RespondModel(await Utils.http_post('User', data));

    setState(() => _isSaving = false);
    if (resp.code != 1) {
      setState(() => _error = resp.message);
      Utils.toast('Failed to save', color: Colors.red.shade700);
      return;
    }

    LoggedInUserModel newUser = LoggedInUserModel.fromJson(resp.data);
    if (newUser.id < 1) {
      Utils.toast('Failed to save', color: Colors.red.shade700);
      return;
    }

    widget.user = newUser;
    await widget.user.save();

    Utils.toast('Updated account successfully.', color: Colors.green.shade700);
    Navigator.pop(context, _item);
  }

  InputDecoration _dec(String label, [IconData? icon]) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: CustomTheme.card,
    hintText: label,
    hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
    errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    prefixIcon: icon != null ? Icon(icon, color: CustomTheme.accent) : null,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: CustomTheme.primary, width: 1),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: CustomTheme.primary),
      borderRadius: BorderRadius.circular(8),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.background,
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CustomTheme.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: FxText.titleMedium(
          'Edit Contact Info',
          color: CustomTheme.accent,
          fontWeight: 700,
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(CustomTheme.accent),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: FxText.bodyLarge(
                'SAVE',
                color: CustomTheme.accent,
                fontWeight: 800,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              if (_error.isNotEmpty)
                Container(
                  width: double.infinity,
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: FxText.bodySmall(_error, color: Colors.redAccent),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      // avatar
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: CustomTheme.card,
                              backgroundImage:
                                  _pickedImage != null
                                      ? FileImage(_pickedImage!)
                                      : (_item.avatar.isNotEmpty
                                          ? NetworkImage(
                                            Utils.getImageUrl(_item.avatar),
                                          )
                                          : null),
                              child:
                                  _pickedImage == null && _item.avatar.isEmpty
                                      ? Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey[600],
                                      )
                                      : null,
                            ),
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: CustomTheme.cardDark,
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: CustomTheme.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // names
                      Row(
                        children: [
                          Expanded(
                            child: FormBuilderTextField(
                              name: 'first_name',
                              initialValue: _item.first_name,
                              decoration: _dec('First Name', Icons.person),
                              textCapitalization: TextCapitalization.words,
                              onChanged: (value) {
                                _item.first_name = value ?? "";
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FormBuilderTextField(
                              name: 'last_name',
                              initialValue: _item.last_name,
                              onChanged: (value) {
                                _item.last_name = value ?? "";
                              },
                              decoration: _dec('Last Name', Icons.person),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // email
                      FormBuilderTextField(
                        name: 'email',
                        initialValue: _item.email,
                        decoration: _dec('Email', Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          _item.email = value ?? "";
                        },
                      ),

                      const SizedBox(height: 16),

                      // country + phone
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: FxContainer(
                              padding: const EdgeInsets.symmetric(
                                vertical: 1,
                                horizontal: 0,
                              ),
                              border: Border.all(
                                color: Colors.grey.shade500,
                                width: 1,
                              ),
                              bordered: true,
                              margin: const EdgeInsets.only(right: 15),
                              child: CountryCodePicker(
                                onChanged: (code) {
                                  _item.country = code.name!;
                                  _item.phone_country_code = code.dialCode!;
                                  _item.phone_country_international =
                                      code.code!;
                                  _formKey.currentState!.patchValue({
                                    "phone_number":
                                        _item.phone_country_code.toString(),
                                  });
                                },
                                padding: EdgeInsets.zero,
                                dialogBackgroundColor: Colors.black,
                                backgroundColor: Colors.black,
                                barrierColor: CustomTheme.background
                                    .withValues(alpha: 0.5),
                                boxDecoration: BoxDecoration(
                                  color: CustomTheme.card,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                initialSelection: 'UG',
                                favorite: ['+256', 'UG'],
                                // optional. Shows only country name and flag
                                showCountryOnly: false,
                                // optional. Shows only country name and flag when popup is closed.
                                showOnlyCountryWhenClosed: false,
                                // optional. aligns the flag and the Text left
                                alignLeft: false,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: FormBuilderTextField(
                              name: 'phone_number',
                              initialValue: _item.phone_number,
                              decoration: _dec('Phone #', Icons.phone),
                              keyboardType: TextInputType.phone,
                              onChanged: (value) {
                                _item.phone_number = value ?? "";
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // alt phone
                      FormBuilderTextField(
                        name: 'phone_number_2',
                        initialValue: _item.phone_number_2,
                        decoration: _dec('Alt Phone', Icons.phone_android),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          _item.phone_number_2 = value ?? "";
                        },
                      ),
                      const SizedBox(height: 16),

                      // address
                      FormBuilderTextField(
                        name: 'address',
                        initialValue: _item.address,
                        decoration: _dec('Address', Icons.home),
                        keyboardType: TextInputType.streetAddress,
                        onChanged: (value) {
                          _item.address = value ?? "";
                        },
                      ),
                      true
                          ? SizedBox()
                          : FormBuilderTextField(
                            name: 'gps',
                            initialValue:
                                "${_item.latitude},${_item.longitude}",
                            decoration: _dec(
                              'Current GPS Location',
                              Icons.pin_drop_outlined,
                            ),
                            readOnly: true,
                            onTap: () {
                              Utils.getUniqueText();
                            },
                          ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
