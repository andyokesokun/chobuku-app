import 'dart:convert';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/payment_repository.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:active_ecommerce_flutter/screens/order_list.dart';
import 'package:active_ecommerce_flutter/screens/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:toast/toast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaytmScreen extends StatefulWidget {
  final double amount;
  final String payment_type;
  final String payment_method_key;
  final dynamic package_id;

  PaytmScreen({
    Key? key,
    this.amount = 0.0,
    this.payment_type = "",
    this.package_id = "0",
    this.payment_method_key = "",
  }) : super(key: key);

  @override
  _PaytmScreenState createState() => _PaytmScreenState();
}

class _PaytmScreenState extends State<PaytmScreen> {
  int _combined_order_id = 0;
  bool _order_init = false;

  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    // Initialize WebViewController
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (page) {
            if (page.contains("/paytm/payment/callback")) {
              getData();
            }
          },
          onWebResourceError: (error) {
            print("WebView error: $error");
          },
        ),
      );

    // Check phone availability before creating order
    checkPhoneAvailability().then((val) {
      if (widget.payment_type == "cart_payment") {
        createOrder();
      }
    });
  }

  createOrder() async {
    var orderCreateResponse =
        await PaymentRepository().getOrderCreateResponse(widget.payment_method_key);

    if (!orderCreateResponse.result) {
      ToastComponent.showDialog(orderCreateResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }

    _combined_order_id = orderCreateResponse.combined_order_id;
    _order_init = true;
    setState(() {});
  }

  checkPhoneAvailability() async {
    var phoneEmailAvailabilityResponse =
        await ProfileRepository().getPhoneEmailAvailabilityResponse();

    if (!phoneEmailAvailabilityResponse.phone_available) {
      ToastComponent.showDialog(
          phoneEmailAvailabilityResponse.phone_available_message,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      Navigator.of(context).pop();
    }
  }

  void getData() {
    _webViewController.runJavaScriptReturningResult("document.body.innerText").then((data) {
      Map<String, dynamic> responseJSON = jsonDecode(data.toString());

      if (responseJSON["result"] == false) {
        Toast.show(responseJSON["message"],
            duration: Toast.lengthLong, gravity: Toast.center);
        Navigator.pop(context);
      } else if (responseJSON["result"] == true) {
        Toast.show(responseJSON["message"],
            duration: Toast.lengthLong, gravity: Toast.center);

        if (widget.payment_type == "cart_payment") {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => OrderList(from_checkout: true)));
        } else if (widget.payment_type == "wallet_payment") {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Wallet(from_recharge: true)));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    String initial_url =
        "${AppConfig.BASE_URL}/paytm/payment/pay?payment_type=${widget.payment_type}&combined_order_id=$_combined_order_id&amount=${widget.amount}&user_id=${user_id.$}&package_id=${widget.package_id}";

    if (!_order_init && _combined_order_id == 0 && widget.payment_type == "cart_payment") {
      return Center(
        child: Text(AppLocalizations.of(context)!.common_creating_order),
      );
    }

    if (_order_init) {
      _webViewController.loadRequest(Uri.parse(initial_url));
    }

    return SizedBox.expand(
      child: WebViewWidget(controller: _webViewController),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        AppLocalizations.of(context)!.paytm_screen_pay_with_paytm,
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
