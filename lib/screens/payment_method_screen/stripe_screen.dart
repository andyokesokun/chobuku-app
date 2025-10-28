import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/repositories/payment_repository.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/screens/order_list.dart';
import 'package:active_ecommerce_flutter/screens/wallet.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StripeScreen extends StatefulWidget {
  final double amount;
  final String payment_type;
  final String payment_method_key;
  final String package_id;

  StripeScreen({
    Key? key,
    this.amount = 0.0,
    this.payment_type = "",
    this.payment_method_key = "",
    this.package_id = "0",
  }) : super(key: key);

  @override
  _StripeScreenState createState() => _StripeScreenState();
}

class _StripeScreenState extends State<StripeScreen> {
  int _combined_order_id = 0;
  bool _order_init = false;

  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (page) {
            if (page.contains("/stripe/success")) {
              getData();
            } else if (page.contains("/stripe/cancel")) {
              ToastComponent.showDialog(
                AppLocalizations.of(context)!.common_payment_cancelled,
                gravity: Toast.center,
                duration: Toast.lengthLong,
              );
              Navigator.of(context).pop();
            }
          },
          onWebResourceError: (error) {
            print("WebView error: $error");
          },
        ),
      );

    if (widget.payment_type == "cart_payment") {
      createOrder();
    }
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

    // Load initial URL after order is created
    String initialUrl =
        "${AppConfig.BASE_URL}/stripe?payment_type=${widget.payment_type}&combined_order_id=$_combined_order_id&amount=${widget.amount}&user_id=${user_id.$}&package_id=${widget.package_id}";
    _webViewController.loadRequest(Uri.parse(initialUrl));
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
            context,
            MaterialPageRoute(builder: (context) => OrderList(from_checkout: true)),
          );
        } else if (widget.payment_type == "wallet_payment") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Wallet(from_recharge: true)),
          );
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
    if (!_order_init && widget.payment_type == "cart_payment") {
      return Center(
        child: Text(AppLocalizations.of(context)!.common_creating_order),
      );
    } else {
      return SizedBox.expand(
        child: WebViewWidget(controller: _webViewController),
      );
    }
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
        AppLocalizations.of(context)!.stripe_screen_pay_with_stripe,
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
