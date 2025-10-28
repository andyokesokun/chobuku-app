
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
class LocaleProvider with ChangeNotifier{ 
  Locale _locale = const Locale('en', ''); // ✅ default fallback locale;
  Locale get locale {

    final code = app_mobile_language.$.isEmpty ? 'en' : app_mobile_language.$;
    _locale = Locale(code, '');
    return _locale;
  }

  void setLocale(String code){ 
    _locale = Locale(code,'');
    notifyListeners();
   }
}