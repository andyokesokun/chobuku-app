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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class NagadScreen extends StatefulWidget { 
  final double amount;
  final String payment_type;
  final String payment_method_key;
  final String package_id;
  NagadScreen(
      {Key? key,
       this.amount = 0.00,
       this.payment_type = "",
         this.package_id="0",
       this.payment_method_key = "" })
      : super(key: key);

  @override
  _NagadScreenState createState() => _NagadScreenState();
}

class _NagadScreenState extends State<NagadScreen> {
  int _combined_order_id = 0;
  bool _order_init = false;
  String _initial_url = "";
  bool _initial_url_fetched = false;

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
            if (page.contains("/nagad/verify/") || page.contains('/check-out/confirm-payment/')) {
              getData();
            }
          },
          onWebResourceError: (error) {
            print("WebView error: $error");
          },
        ),
      );

    if (widget.payment_type == "cart_payment") {
      createOrder();
    } else {
      getSetInitialUrl();
    }
  }

  createOrder() async {
    var orderCreateResponse = await PaymentRepository().getOrderCreateResponse(widget.payment_method_key);

    if (!orderCreateResponse.result) {
      ToastComponent.showDialog(orderCreateResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }

    _combined_order_id = orderCreateResponse.combined_order_id;
    _order_init = true;
    setState(() {});
    getSetInitialUrl();
  }

  getSetInitialUrl() async {
    var nagadUrlResponse = await PaymentRepository().getNagadBeginResponse(
        widget.payment_type, _combined_order_id, widget.package_id, widget.amount);

    if (!nagadUrlResponse.result) {
      ToastComponent.showDialog(nagadUrlResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }

    _initial_url = nagadUrlResponse.url;
    _initial_url_fetched = true;
    setState(() {});
  }

  void getData() async {
    try {
      final Object rawData = await _webViewController.runJavaScriptReturningResult("document.body.innerText");
      String dataStr = rawData.toString();

      // Remove extra quotes if JS added them
      if (dataStr.startsWith('"') && dataStr.endsWith('"')) {
        dataStr = dataStr.substring(1, dataStr.length - 1);
        dataStr = dataStr.replaceAll(r'\"', '"');
      }

      final Map<String, dynamic> responseJSON = jsonDecode(dataStr);

      if (!responseJSON["result"]) {
        Toast.show(responseJSON["message"], duration: Toast.lengthLong, gravity: Toast.center);
        Navigator.pop(context);
      } else {
        final paymentDetails = responseJSON['payment_details'];
        onPaymentSuccess(paymentDetails);
      }
    } catch (e) {
      print("Error parsing payment data: $e");
    }
  }

  onPaymentSuccess(paymentDetails) async {
    var nagadPaymentProcessResponse = await PaymentRepository()
        .getNagadPaymentProcessResponse(widget.payment_type, widget.amount, _combined_order_id, paymentDetails);

    if (!nagadPaymentProcessResponse.result) {
      Toast.show(nagadPaymentProcessResponse.message, duration: Toast.lengthLong, gravity: Toast.center);
      Navigator.pop(context);
      return;
    }

    Toast.show(nagadPaymentProcessResponse.message, duration: Toast.lengthLong, gravity: Toast.center);

    if (widget.payment_type == "cart_payment") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => OrderList(from_checkout: true)));
    } else if (widget.payment_type == "wallet_payment") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => Wallet(from_recharge: true)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: (_order_init || widget.payment_type != "cart_payment") && _initial_url_fetched
          ? WebViewWidget(controller: _webViewController..loadRequest(Uri.parse(_initial_url)))
          : Center(
              child: Text(
                  AppLocalizations.of(context)!.nagad_screen_fetching_nagad_url),
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
        AppLocalizations.of(context)!.nagad_screen_pay_with_nagad,
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
