import 'dart:convert';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:active_ecommerce_flutter/helpers/file_helper.dart';
import 'package:active_ecommerce_flutter/custom/lang_text.dart';

class ProfileEdit extends StatefulWidget {
  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final ScrollController _mainScrollController = ScrollController();

  final TextEditingController _nameController =
      TextEditingController(text: "${user_name.$}");
  final TextEditingController _phoneController =
      TextEditingController(text: "${user_phone.$}");
  final TextEditingController _emailController =
      TextEditingController(text: "${user_email.$}");
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _file;

  @override
  void dispose() {
    _mainScrollController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> chooseAndUploadImage(BuildContext context) async {
    var status = await Permission.photos.request();

    if (status.isDenied) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: Text(
                    AppLocalizations.of(context)!.common_photo_permission),
                content: Text(
                    AppLocalizations.of(context)!.common_app_needs_permission),
                actions: [
                  CupertinoDialogAction(
                    child: Text(AppLocalizations.of(context)!.common_deny),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoDialogAction(
                    child: Text(AppLocalizations.of(context)!.common_settings),
                    onPressed: () => openAppSettings(),
                  ),
                ],
              ));
    } else if (status.isGranted) {
      _file = await _picker.pickImage(source: ImageSource.gallery);
      if (_file == null) return;

      String base64Image = FileHelper.getBase64FormateFile(_file!.path);
      String fileName = _file!.path.split("/").last;

      var response = await ProfileRepository().getProfileImageUpdateResponse(
        base64Image,
        fileName,
      );

      ToastComponent.showDialog(response.message,
          gravity: Toast.center, duration: Toast.lengthLong);

      if (response.result) {
        avatar_original.$ = response.path;
        setState(() {});
      }
    } else {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.common_give_photo_permission,
          gravity: Toast.center,
          duration: Toast.lengthLong);
    }
  }

  Future<void> _onPageRefresh() async {}

  Future<void> onPressUpdate() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.profile_edit_screen_name_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    if (phone.isEmpty) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.profile_edit_screen_phone_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    var postBody = jsonEncode({"name": name, "phone": phone});

    var response =
        await ProfileRepository().getProfileUpdateResponse(post_body: postBody);

    ToastComponent.showDialog(response.message,
        gravity: Toast.center, duration: Toast.lengthLong);

    if (response.result) {
      user_name.$ = name;
      user_phone.$ = phone;
      setState(() {});
    }
  }

  Future<void> onPressUpdatePassword() async {
    String password = _passwordController.text.trim();
    String confirmPassword = _passwordConfirmController.text.trim();

    bool changePassword = password.isNotEmpty || confirmPassword.isNotEmpty;

    if (!changePassword) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!
              .profile_edit_screen_password_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    if (password.length < 6) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!
              .password_otp_screen_password_length_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    if (password != confirmPassword) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.profile_edit_screen_password_match_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    var postBody = jsonEncode({"password": password});
    var response =
        await ProfileRepository().getProfileUpdateResponse(post_body: postBody);

    ToastComponent.showDialog(response.message,
        gravity: Toast.center, duration: Toast.lengthLong);

    if (response.result) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildBody(context),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        AppLocalizations.of(context)!.profile_edit_screen_edit_profile,
        style:
            TextStyle(fontSize: 16, color: MyTheme.dark_font_grey, fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
    );
  }

  Widget buildBody(BuildContext context) {
    if (!is_logged_in.$) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.profile_edit_screen_login_warning,
          style: TextStyle(color: MyTheme.font_grey),
        ),
      );
    }

    return RefreshIndicator(
      color: MyTheme.accent_color,
      onRefresh: _onPageRefresh,
      child: CustomScrollView(
        controller: _mainScrollController,
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              buildTopSection(),
              buildProfileForm(context),
            ]),
          )
        ],
      ),
    );
  }

  Widget buildTopSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Stack(
        children: [
          UsefulElements.roundImageWithPlaceholder(
            url: avatar_original.$,
            height: 120,
            width: 120,
            borderRadius: BorderRadius.circular(60),
            elevation: 6.0,
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: SizedBox(
              width: 24,
              height: 24,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: MyTheme.light_grey,
                  shape: CircleBorder(
                      side: BorderSide(color: MyTheme.light_grey, width: 1)),
                ),
                onPressed: () => chooseAndUploadImage(context),
                child: Icon(Icons.edit, color: Colors.white, size: 14),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildProfileForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildBasicInfo(context),
          buildChangePassword(context),
        ],
      ),
    );
  }

  Widget buildBasicInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.profile_edit_screen_basic_information,
          style: TextStyle(
              color: MyTheme.font_grey, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecorations.buildInputDecoration_1(hint_text: "John Doe")
              .copyWith(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: MyTheme.accent_color)),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecorations.buildInputDecoration_1(hint_text: "+01xxxxxxxxxx")
              .copyWith(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: MyTheme.accent_color)),
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecorations.buildBoxDecoration_1(),
          child: Text(
            _emailController.text,
            style: TextStyle(fontSize: 12, color: MyTheme.grey_153),
          ),
        ),
        SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: DeviceInfo(context).width / 2.5,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: MyTheme.accent_color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
              ),
              onPressed: onPressUpdate,
              child: Text(
                AppLocalizations.of(context)!.profile_edit_screen_btn_update_profile,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildChangePassword(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            LangText(context).local.profile_edit_screen_password_changes,
            style: TextStyle(
                fontSize: 16, color: MyTheme.accent_color, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration: InputDecorations.buildInputDecoration_1(hint_text: "• • • • • • • •")
              .copyWith(
            suffixIcon: InkWell(
              onTap: () {
                setState(() => _showPassword = !_showPassword);
              },
              child: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
                color: MyTheme.accent_color,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _passwordConfirmController,
          obscureText: !_showConfirmPassword,
          decoration: InputDecorations.buildInputDecoration_1(hint_text: "• • • • • • • •")
              .copyWith(
            suffixIcon: InkWell(
              onTap: () {
                setState(() => _showConfirmPassword = !_showConfirmPassword);
              },
              child: Icon(
                _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                color: MyTheme.accent_color,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 150,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: MyTheme.accent_color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
              ),
              onPressed: onPressUpdatePassword,
              child: Text(
                AppLocalizations.of(context)!.profile_edit_screen_btn_update_password,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
