import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'dart:convert';
import 'package:active_ecommerce_flutter/repositories/payment_repository.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:active_ecommerce_flutter/screens/order_list.dart';
import 'package:active_ecommerce_flutter/screens/wallet.dart';
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class IyzicoScreen extends StatefulWidget { 
  final double amount;
  final String payment_type;
  final String payment_method_key;
  final String package_id;
  IyzicoScreen(
      {Key? key,
       this.amount = 0.00,
       this.payment_type = "",
         this.package_id="0",
       this.payment_method_key = "" })
      : super(key: key);

  @override
  _IyzicoScreenState createState() => _IyzicoScreenState();
}

class _IyzicoScreenState extends State<IyzicoScreen> {
  int _combined_order_id = 0;
  bool _order_init = false;

  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    // Initialize controller
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (page) {
            print(page);
            getData();
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
      ToastComponent.showDialog(
          orderCreateResponse.message,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }

    _combined_order_id = orderCreateResponse.combined_order_id;
    _order_init = true;
    setState(() {});
  }

  void getData() async {
    try {
      final Object rawData =
          await _webViewController.runJavaScriptReturningResult("document.body.innerText");
      String dataStr = rawData.toString();

      // Remove extra quotes if present
      if (dataStr.startsWith('"') && dataStr.endsWith('"')) {
        dataStr = dataStr.substring(1, dataStr.length - 1);
        dataStr = dataStr.replaceAll(r'\"', '"');
      }

      final Map<String, dynamic> responseJSON = jsonDecode(dataStr);

      if (responseJSON["result"] == false) {
        Toast.show(responseJSON["message"],
            duration: Toast.lengthLong, gravity: Toast.center);
        Navigator.pop(context);
      } else if (responseJSON["result"] == true) {
        final paymentDetails = responseJSON['payment_details'];
        onPaymentSuccess(paymentDetails);
      }
    } catch (e) {
      print("Error parsing payment data: $e");
    }
  }

  onPaymentSuccess(paymentDetails) async {
    var iyzicoPaymentSuccessResponse = await PaymentRepository()
        .getIyzicoPaymentSuccessResponse(
            widget.payment_type, widget.amount, _combined_order_id, paymentDetails);

    if (!iyzicoPaymentSuccessResponse.result) {
      Toast.show(iyzicoPaymentSuccessResponse.message,
          duration: Toast.lengthLong, gravity: Toast.center);
      Navigator.pop(context);
      return;
    }

    Toast.show(iyzicoPaymentSuccessResponse.message,
        duration: Toast.lengthLong, gravity: Toast.center);

    if (widget.payment_type == "cart_payment") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => OrderList(from_checkout: true)));
    } else if (widget.payment_type == "wallet_payment") {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => Wallet(from_recharge: true)));
    }
  }

  @override
  Widget build(BuildContext context) {
    String initialUrl =
        "${AppConfig.BASE_URL}/iyzico/init?payment_type=${widget.payment_type}&combined_order_id=$_combined_order_id&amount=${widget.amount}&user_id=${user_id.$}&package_id=${widget.package_id}";

    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: _order_init || widget.payment_type != "cart_payment"
            ? WebViewWidget(controller: _webViewController..loadRequest(Uri.parse(initialUrl)))
            : Center(child: Text(AppLocalizations.of(context)!.common_creating_order)),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        AppLocalizations.of(context)!.iyzico_screen_pay_with_iyzico,
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
