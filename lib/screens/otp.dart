import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/screens/login.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Otp extends StatefulWidget {
  Otp({Key? key, required this.verify_by, required this.user_id})
      : super(key: key);
  final String verify_by;
  final int user_id;

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  TextEditingController _verificationCodeController = TextEditingController();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onTapResend() async {
    var resendCodeResponse =
        await AuthRepository().getResendCodeResponse(widget.user_id, widget.verify_by);

    ToastComponent.showDialog(resendCodeResponse.message,
        gravity: Toast.center, duration: Toast.lengthLong);
  }

  onPressConfirm() async {
    var code = _verificationCodeController.text.toString();

    if (code.isEmpty) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.otp_screen_verification_code_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    var confirmCodeResponse =
        await AuthRepository().getConfirmCodeResponse(widget.user_id, code);

    ToastComponent.showDialog(confirmCodeResponse.message,
        gravity: Toast.center, duration: Toast.lengthLong);

    if (confirmCodeResponse.result) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Login()));
    }
  }

  @override
  Widget build(BuildContext context) {
    String _verify_by = widget.verify_by;
    final _screen_width = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              width: _screen_width * (3 / 4),
              child: Image.asset(
                  "assets/splash_login_registration_background_image.png"),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  Container(
                    width: 75,
                    height: 75,
                    child: Image.asset('assets/login_registration_form_logo.png'),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "${AppLocalizations.of(context)!.otp_screen_verify_your} " +
                        (_verify_by == "email"
                            ? AppLocalizations.of(context)!.otp_screen_email_account
                            : AppLocalizations.of(context)!.otp_screen_phone_number),
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: _screen_width * (3 / 4),
                    child: Text(
                      _verify_by == "email"
                          ? AppLocalizations.of(context)!
                              .otp_screen_enter_verification_code_to_email
                          : AppLocalizations.of(context)!
                              .otp_screen_enter_verification_code_to_phone,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MyTheme.dark_grey, fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: _screen_width * (3 / 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 36,
                          child: TextField(
                            controller: _verificationCodeController,
                            autofocus: false,
                            decoration: InputDecorations.buildInputDecoration_1(
                                hint_text: "A X B 4 J H"),
                          ),
                        ),
                        SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: MyTheme.accent_color,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.otp_screen_confirm,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            onPressed: onPressConfirm,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 100),
                  InkWell(
                    onTap: onTapResend,
                    child: Text(
                      AppLocalizations.of(context)!.otp_screen_resend_code,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          decoration: TextDecoration.underline,
                          fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
