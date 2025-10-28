import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/enum_classes.dart';
import 'package:active_ecommerce_flutter/custom/lang_text.dart';
import 'package:active_ecommerce_flutter/custom/style.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/data_model/customer_package_response.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/customer_package_repository.dart';
import 'package:active_ecommerce_flutter/screens/checkout.dart';
import 'package:flutter/material.dart';

class UpdatePackage extends StatefulWidget { 
  const UpdatePackage({Key? key }) : super(key: key);

  @override
  State<UpdatePackage> createState() => _UpdatePackageState();
}

class _UpdatePackageState extends State<UpdatePackage> { 
  List<Package> _packages = [];
  bool _isFetchAllData = false;


  Future<bool> getPackageList() async {
    var response = await CustomerPackageRepository().getList();
    _packages.addAll(response.data);
    setState(() { });
    return true;
  }





  Future<bool> sendFreePackageReq(id) async { 
    // var response = await ShopRepository().purchaseFreePackageRequest(id);
    // ToastComponent.showDialog(response.message,
    //     gravity: Toast.center, duration: Toast.lengthLong);
    // setState(() { });
    return true;
  }



  Future<bool> fetchData() async { 

    await getPackageList();
    _isFetchAllData = true;
    setState(() { });
    return true;
  }

  clearData() { 
    _isFetchAllData = false;
    _packages = [];
    setState(() { });
  }

  Future<bool> resetData() { 
    clearData();
    return fetchData();
   }

  Future<void> refresh() async { 
    await resetData();
    return Future.delayed(const Duration(seconds: 0));
   }


  @override
  void initState() { 
    fetchData();
    super.initState();
   }

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 0,
              backgroundColor: MyTheme.white,
              title:Text( LangText( context)
                  .local
                  .package_screen_title,
                style: MyStyle.appBarStyle,
              ),
        //leadingWidth: 20,
        leading: UsefulElements.backButton(context),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: buildList(),
          ),
        ),
      ),
    );
   }

 Widget buildList() { 
  return _isFetchAllData
      ? ListView.separated(
          padding: EdgeInsets.only(top: 10),
          separatorBuilder: (context,index){
            return SizedBox(height: 10,);
          },
          itemCount: _packages.length,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) { 
            return packageItem(
              index,
              context,
              _packages[index].logo,
              _packages[index].name,
              _packages[index].amount,
              _packages[index].productUploadLimit.toString(),
              _packages[index].price,
              _packages[index].id,
            );
          },
        )
      : loadingShimmer();
}


  Widget loadingShimmer() { 
    return ShimmerHelper().buildListShimmer(item_count: 10, item_height: 170.0);
   }

  Widget packageItem(int index,BuildContext context, String url, String packageName,
      String packagePrice, String packageProduct, price,package_id) { 
    print(url);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12,vertical: 12),
        decoration: BoxDecorations.buildBoxDecoration_1(),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            UsefulElements.roundImageWithPlaceholder(width: 30.0, height: 30.0, url: url,backgroundColor: MyTheme.noColor),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                packageName,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                width: DeviceInfo(context).width / 2,

                decoration: BoxDecoration(
                    color: MyTheme.accent_color,
                  borderRadius: BorderRadius.circular(6)
                ),
                padding: EdgeInsets.symmetric(vertical: 10),
                child: InkWell(
                    onTap: () {
                      if(double.parse(price.toString())<=0){
                        sendFreePackageReq(package_id);
                        return;
                       }else{ 
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Checkout(title: "Purchase Package",rechargeAmount: double.parse(price.toString()),paymentFor: PaymentFor.PackagePay,)));
                       }
                    },
                    radius: 3.0,
                    child: Text(
                      packagePrice,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: MyTheme.white),
                      textAlign: TextAlign.center,
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                width: DeviceInfo(context).width / 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: MyTheme.accent_color,
                      size: 11,
                    ),
                    Text(
                      packageProduct +
                          " " +
                          LangText( context)
                              .local
                              .package_screen_product_upload_limit,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

}
