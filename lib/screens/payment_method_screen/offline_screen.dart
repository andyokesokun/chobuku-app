import 'package:active_ecommerce_flutter/custom/enum_classes.dart';
import 'package:active_ecommerce_flutter/repositories/offline_wallet_recharge_repository.dart';
import 'package:active_ecommerce_flutter/screens/wallet.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:active_ecommerce_flutter/repositories/file_repository.dart';
import 'package:active_ecommerce_flutter/repositories/offline_payment_repository.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:active_ecommerce_flutter/screens/order_details.dart';
import 'package:active_ecommerce_flutter/helpers/file_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OfflineScreen extends StatefulWidget { 
  final int order_id;
  final String paymentInstruction;
  final PaymentFor offLinePaymentFor;
  final int offline_payment_id;
  final double rechargeAmount;
  final String packageId;

  OfflineScreen(
      {Key? key,
      required this.order_id,
      required this.paymentInstruction,
        required this.offLinePaymentFor,
      required this.offline_payment_id,
         this.packageId="0",
      required this.rechargeAmount })
      : super(key: key);

  @override
  _OfflineState createState() => _OfflineState();
}

class _OfflineState extends State<OfflineScreen> {
  final ScrollController _mainScrollController = ScrollController();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _trxIdController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _photoFile;
  String _photoPath = "";
  int _photoUploadId = 0;
  BuildContext? _loadingContext;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.rechargeAmount.toString();
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _amountController.dispose();
    _nameController.dispose();
    _trxIdController.dispose();
    super.dispose();
  }

  Future<void> _onPageRefresh() async => reset();

  void reset() {
    _amountController.clear();
    _nameController.clear();
    _trxIdController.clear();
    _photoPath = "";
    _photoUploadId = 0;
    setState(() {});
  }

  Future<void> onPressSubmit() async {
    final amount = _amountController.text.trim();
    final name = _nameController.text.trim();
    final trxId = _trxIdController.text.trim();

    if (amount.isEmpty || name.isEmpty || trxId.isEmpty) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.offline_screen_amount_name_trxid_warning,
        gravity: Toast.center,
        duration: Toast.lengthLong,
      );
      return;
    }

    if (_photoPath.isEmpty || _photoUploadId == 0) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.offline_screen_photo_warning,
        gravity: Toast.center,
        duration: Toast.lengthLong,
      );
      return;
    }

    loading();

    if (widget.offLinePaymentFor == PaymentFor.WalletRecharge) {
      final submitResponse = await OfflineWalletRechargeRepository()
          .getOfflineWalletRechargeResponse(
              amount: amount, name: name, trx_id: trxId, photo: _photoUploadId);

      Navigator.pop(_loadingContext!);

      ToastComponent.showDialog(submitResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);

      if (submitResponse.result) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => Wallet(from_recharge: true)));
      }
    } else if (widget.offLinePaymentFor == PaymentFor.ManualPayment) {
      final submitResponse = await OfflinePaymentRepository()
          .getOfflinePaymentSubmitResponse(
              order_id: widget.order_id,
              amount: amount,
              name: name,
              trx_id: trxId,
              photo: _photoUploadId);

      Navigator.pop(_loadingContext!);

      ToastComponent.showDialog(submitResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);

      if (submitResponse.result) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => OrderDetails(id: widget.order_id, go_back: false)));
      }
    }
  }

  Future<void> onPickPhoto(BuildContext context) async {
    final status = await Permission.photos.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      showDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                title: Text(AppLocalizations.of(context)!.common_photo_permission),
                content: Text(AppLocalizations.of(context)!.common_app_needs_permission),
                actions: [
                  CupertinoDialogAction(
                    child: Text(AppLocalizations.of(context)!.common_deny),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoDialogAction(
                    child: Text(AppLocalizations.of(context)!.common_settings),
                    onPressed: () => openAppSettings(),
                  ),
                ],
              ));
      return;
    }

    if (status.isGranted) {
      _photoFile = await _picker.pickImage(source: ImageSource.gallery);
      if (_photoFile == null) return;

      final base64Image = FileHelper.getBase64FormateFile(_photoFile!.path);
      final fileName = _photoFile!.path.split("/").last;

      final imageUpdateResponse =
          await FileRepository().getSimpleImageUploadResponse(base64Image, fileName);

      if (imageUpdateResponse.result) {
        _photoPath = imageUpdateResponse.path;
        _photoUploadId = imageUpdateResponse.upload_id;
      }

      ToastComponent.showDialog(imageUpdateResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);

      setState(() {});
    }
  }

  void loading() {
    showDialog(
        context: context,
        builder: (context) {
          _loadingContext = context;
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 10),
                Text(AppLocalizations.of(context)!.loading_text),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: is_logged_in.$ 
            ? RefreshIndicator(
                color: MyTheme.accent_color,
                onRefresh: _onPageRefresh,
                child: CustomScrollView(
                  controller: _mainScrollController,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Html(data: widget.paymentInstruction),
                        ),
                        const Divider(height: 24),
                        buildProfileForm(context),
                      ]),
                    ),
                  ],
                ),
              )
            : Center(
                child: Text(
                  AppLocalizations.of(context)!.common_login_warning,
                  style:  TextStyle(color: MyTheme.font_grey),
                ),
              ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) => AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.offline_screen_offline_payment,
          style:  TextStyle(fontSize: 16, color: MyTheme.accent_color),
        ),
        elevation: 0,
        titleSpacing: 0,
      );

  Widget buildProfileForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.offline_screen_fields_mandatory,
          style:  TextStyle(
              color: MyTheme.grey_153, fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.offline_screen_fill_up_necessary_info,
          style:  TextStyle(color: MyTheme.grey_153, fontSize: 14),
        ),
        const SizedBox(height: 16),
        buildTextField(context, AppLocalizations.of(context)!.offline_screen_amount,
            _amountController, "12,000 or Twelve Thousand Only"),
        buildTextField(context, AppLocalizations.of(context)!.offline_screen_name,
            _nameController, "John Doe"),
        buildTextField(context, AppLocalizations.of(context)!.offline_screen_transaction_id,
            _trxIdController, "BNI-4654321354"),
        const SizedBox(height: 8),
        Text(
          "${AppLocalizations.of(context)!.offline_screen_photo_proof}* (${AppLocalizations.of(context)!.offline_screen_only_image_file_allowed})",
          style: TextStyle(
              color: MyTheme.accent_color, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => onPickPhoto(context),
              child: Text(AppLocalizations.of(context)!.offline_screen_photo_proof),
              style: ElevatedButton.styleFrom(
                  backgroundColor: MyTheme.medium_grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(width: 8),
            if (_photoPath.isNotEmpty)
              Text(AppLocalizations.of(context)!.common_selected),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: onPressSubmit,
              child: Text(AppLocalizations.of(context)!.common_submit),
              style: ElevatedButton.styleFrom(
                  backgroundColor: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildTextField(
      BuildContext context, String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label*",
            style: TextStyle(
                color: MyTheme.accent_color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 36,
            child: TextField(
              controller: controller,
              decoration: InputDecorations.buildInputDecoration_1(hint_text: hint),
            ),
          ),
        ],
      ),
    );
  }
}
