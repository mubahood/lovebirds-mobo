import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/flutx.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

import '../../core/styles.dart';
import '../../models/LoggedInUserModel.dart';
import '../../models/RespondModel.dart';
import '../../src/features/app_introduction/view/splash_screen.dart';
import '../../utils/AppConfig.dart';
import '../../utils/CustomTheme.dart';
import '../../utils/Utilities.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({Key? key}) : super(key: key);

  @override
  PasswordResetScreenState createState() => PasswordResetScreenState();
}

class PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoaderVisible = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    Utils.init_theme();
  }

  final _fKey = GlobalKey<FormBuilderState>();
  String _name = '';
  String error_message = '';
  String _email = '';
  String _password = '';
  String _password_1 = '';
  bool isLoading = false;
  bool haveCode = false;

  @override
  Widget build(BuildContext context) {
    //isLoading = false;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: CustomTheme.primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: CustomTheme.primary,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Stack(
        children: [
          Image(
            image: const AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.fill,
            height: Get.height,
            width: Get.width,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: .9),
                  Colors.black.withValues(alpha: .6),
                ],
              ),
            ),
          ),
          FormBuilder(
            key: _fKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Image(
                      image: AssetImage(AppConfig.logo_1),
                      width: 150,
                      fit: BoxFit.fill,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Password Reset',
                      style: AppStyles.googleFontMontserrat.copyWith(
                        color: Colors.grey.shade300,
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20.0),
                          FormBuilderTextField(
                            decoration: CustomTheme.in_4(
                              'Email',
                              'Enter your email',
                            ),
                            style: AppStyles.googleFontMontserrat.copyWith(
                              color: Colors.grey.shade300,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            name: "email",
                            onChanged: (value) {
                              _email = value.toString();
                            },
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: "This field is required.",
                              ),
                              FormBuilderValidators.email(
                                errorText: "Invalid email.",
                              ),
                            ]),
                          ),
                          (!haveCode)
                              ? const SizedBox(height: 0)
                              : Column(
                                children: [
                                  const SizedBox(height: 20.0),
                                  FormBuilderTextField(
                                    decoration: CustomTheme.in_4(
                                      'Secret Code',
                                      'Secret Code',
                                    ),
                                    style: AppStyles.googleFontMontserrat
                                        .copyWith(
                                          color: Colors.grey.shade300,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                    name: "name",
                                    onChanged: (value) {
                                      _name = value.toString();
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(
                                        errorText: "This field is required.",
                                      ),
                                      FormBuilderValidators.minLength(3),
                                    ]),
                                  ),
                                  const SizedBox(height: 25.0),
                                  FormBuilderTextField(
                                    decoration: CustomTheme.in_4(
                                      'Password',
                                      'Enter your password',
                                    ),
                                    style: AppStyles.googleFontMontserrat
                                        .copyWith(
                                          color: Colors.grey.shade300,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                    name: "password",
                                    onChanged: (value) {
                                      _password = value.toString();
                                    },
                                    obscureText: true,
                                    keyboardType: TextInputType.visiblePassword,
                                    textInputAction: TextInputAction.next,
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(
                                        errorText: "This field is required.",
                                      ),
                                      FormBuilderValidators.minLength(
                                        4,
                                        errorText: "Password too short",
                                      ),
                                    ]),
                                  ),
                                  const SizedBox(height: 25.0),
                                  FormBuilderTextField(
                                    decoration: CustomTheme.in_4(
                                      'Re-Enter Password',
                                      'Enter your password',
                                    ),
                                    style: AppStyles.googleFontMontserrat
                                        .copyWith(
                                          color: Colors.grey.shade300,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                    name: "_password_1",
                                    onChanged: (value) {
                                      _password_1 = value.toString();
                                    },
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: true,
                                    textInputAction: TextInputAction.done,
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(
                                        errorText: "This field is required.",
                                      ),
                                      FormBuilderValidators.minLength(
                                        4,
                                        errorText: "Password too short",
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                          error_message.isEmpty
                              ? const SizedBox(height: 20)
                              : FxContainer(
                                bordered: true,
                                borderColor: Colors.red,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                color: Colors.red.shade50,
                                child: FxText.bodyMedium(
                                  error_message,
                                  color: Colors.red.shade900,
                                ),
                              ),
                          /*Align(
                            alignment: Alignment.centerRight,
                            child: FxButton.text(
                                onPressed: () {},
                                child: FxText.titleMedium(
                                  "Forgot Password?",
                                  color: Colors.yellow.shade300,
                                  fontWeight: 900,
                                )),
                          ),*/
                        ],
                      ),
                    ),
                    const SizedBox(height: 0),
                    isLoading
                        ? const CircularProgressIndicator(
                          color: CustomTheme.accent,
                          backgroundColor: Colors.white,
                          strokeWidth: 5,
                        )
                        : FxButton.block(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: CustomTheme.accent,
                          onPressed: () async {
                            setState(() {
                              error_message = "";
                            });
                            if (!_fKey.currentState!.saveAndValidate()) {
                              return;
                            }

                            if (!haveCode) {
                              request_code();
                              return;
                            }

                            if (_password != _password_1) {
                              error_message = "Passwords did not match";
                              Utils.toast(error_message, color: Colors.red);
                              return;
                            }

                            Map<String, dynamic> formDataMap = {};
                            _email = _fKey.currentState!.fields['email']!.value;
                            _password =
                                _fKey.currentState!.fields['password']!.value;
                            formDataMap = {
                              'email': _email,
                              'password': _password,
                              'code': _name,
                            };

                            Utils.toast("Loading....");
                            setState(() {
                              isLoading = true;
                            });
                            RespondModel resp = RespondModel(
                              await Utils.http_post(
                                'auth/password-reset',
                                formDataMap,
                              ),
                            );
                            setState(() {
                              isLoading = false;
                            });

                            if (resp.code != 1) {
                              error_message = resp.message;
                              Utils.toast(error_message);
                              setState(() {});
                              return;
                            }
                            if (resp.data['user'] == null) {
                              Utils.toast("User not found");
                              return;
                            }

                            LoggedInUserModel u = LoggedInUserModel.fromJson(
                              resp.data['user'],
                            );

                            if (u.id < 1) {
                              Utils.toast("User not found");
                              return;
                            }

                            if (!(await u.save())) {
                              Utils.toast('failed to log you in ');
                              return;
                            }

                            Get.off(() => const SplashScreen());
                          },
                          child: FxText.titleLarge(
                            haveCode ? 'Reset Password' : 'Request Secret Code',
                            fontWeight: 700,
                            color: Colors.white,
                          ),
                        ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          (!haveCode)
                              ? "Already have secret code?"
                              : "Don't have secret code?",
                          style: AppStyles.googleFontMontserrat.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade300,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.center,
                      child: Wrap(
                        children: [
                          const SizedBox(width: 3),
                          InkWell(
                            onTap: () {
                              haveCode = !haveCode;
                              setState(() {});
                            },
                            child: Text(
                              (!haveCode)
                                  ? 'Enter Secret Code'
                                  : 'Request Secret Code',
                              style: AppStyles.googleFontMontserrat.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: Colors.yellow,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  request_code() async {
    setState(() {
      error_message = "";
    });
    if (!_fKey.currentState!.saveAndValidate()) {
      return;
    }

    Map<String, dynamic> formDataMap = {};
    _email = _fKey.currentState!.fields['email']!.value;
    formDataMap = {'email': _email};

    Utils.toast("Loading....");
    setState(() {
      isLoading = true;
    });
    RespondModel resp = RespondModel(
      await Utils.http_post('auth/request-password-reset-code', formDataMap),
    );
    setState(() {
      isLoading = false;
    });

    if (resp.code != 1) {
      error_message = resp.message;
      Utils.toast(error_message);
      setState(() {});
      return;
    }
    Utils.toast("Secret code sent to your email.");
    haveCode = true;
    setState(() {});
  }
}
