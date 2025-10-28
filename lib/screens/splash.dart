
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';

class Splash extends StatefulWidget { 
  @override
  _SplashState createState() => _SplashState();
 }

class _SplashState extends State<Splash> { 
  PackageInfo _packageInfo = PackageInfo(
    appName: AppConfig.app_name,
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    super.initState();
    _initPackageInfo();
   }

  @override
  void dispose() { 
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
   }

  Future<void> _initPackageInfo() async { 
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
     });
  }

  Future<Widget> loadFromFuture() async { 

    // <fetch data from server. ex. login>

    return Future.value( Main());
   }

  @override
  Widget build(BuildContext context) { 
    return CustomSplashScreen(
      //comment this
      seconds: 3,


      //comment this
      navigateAfterSeconds: Main(),


      //navigateAfterFuture: loadFromFuture(), //uncomment this
      title: Text(
        "V " + _packageInfo.version,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.white),
      ),
      useLoader: false,
      loadingText: Text(
        AppConfig.copyright_text,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 13.0,
          color: Colors.white,
        ),
      ),
      image: Image.asset("assets/splash_screen_logo.png"),
      backgroundImage:
          Image.asset("assets/splash_login_registration_background_image.png"),
      backgroundColor: MyTheme.splash_screen_color,
      photoSize: 60.0,
      backgroundPhotoSize: 140.0,
    );
   }
}

class CustomSplashScreen extends StatefulWidget {
  final int? seconds;
  final Text? title;
  final Color? backgroundColor;
  final TextStyle? styleTextUnderTheLoader;
  final dynamic navigateAfterSeconds;
  final double? photoSize;
  final double? backgroundPhotoSize;
  final dynamic onClick;
  final Color? loaderColor;
  final Image? image;
  final Image? backgroundImage;
  final Text? loadingText;
  final ImageProvider? imageBackground;
  final Gradient? gradientBackground;
  final bool? useLoader;
  final Route? pageRoute;
  final String? routeName;
  final Future<dynamic>? navigateAfterFuture;

  CustomSplashScreen({
    this.seconds,
    this.title,
    this.backgroundColor,
    this.styleTextUnderTheLoader,
    this.navigateAfterSeconds,
    this.photoSize,
    this.backgroundPhotoSize,
    this.onClick,
    this.loaderColor,
    this.image,
    this.backgroundImage,
    this.loadingText,
    this.imageBackground,
    this.gradientBackground,
    this.useLoader,
    this.pageRoute,
    this.routeName,
    this.navigateAfterFuture,
  });

  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.navigateAfterFuture != null) {
      widget.navigateAfterFuture!.then((navigateTo) {
        if (navigateTo is String) {
          Navigator.of(context).pushReplacementNamed(navigateTo);
        } else if (navigateTo is Widget) {
          Navigator.of(context).pushReplacement(
            widget.pageRoute ??
                MaterialPageRoute(
                  settings: widget.routeName != null
                      ? RouteSettings(name: widget.routeName)
                      : null,
                  builder: (context) => navigateTo,
                ),
          );
        } else {
          throw ArgumentError(
              'widget.navigateAfterFuture must either be a String or Widget');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: InkWell(
          onTap: widget.onClick,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  image: widget.imageBackground != null
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: widget.imageBackground!,
                        )
                      : null,
                  gradient: widget.gradientBackground,
                  color: widget.backgroundColor ?? MyTheme.splash_screen_color,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.backgroundImage != null)
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Hero(
                        tag: "backgroundImageInSplash",
                        child: widget.backgroundImage!,
                      ),
                      radius: widget.backgroundPhotoSize ?? 140.0,
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 120.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.image != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 60.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Hero(
                                  tag: "splashscreenImage",
                                  child: widget.image!,
                                ),
                                radius: widget.photoSize ?? 60.0,
                              ),
                            ),
                          widget.title ?? const SizedBox.shrink(),
                          const SizedBox(height: 10),
                          widget.loadingText ?? const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
