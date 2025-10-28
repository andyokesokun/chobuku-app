import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/screens/product_details.dart';
import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
class MiniProductCard extends StatefulWidget { 
  final int id;
  final String image;
  final String name;
  final String main_price;
  final String stroked_price;
  final bool has_discount;

  MiniProductCard({Key? key, required this.id, required this.image, required this.name, required this.main_price,required this.stroked_price,required this.has_discount })
      : super(key: key);

  @override
  _MiniProductCardState createState() => _MiniProductCardState();
}

class _MiniProductCardState extends State<MiniProductCard> { 
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ProductDetails(id: widget.id);
         }));
      },
      child: Container(
        width: 135,
        decoration: BoxDecorations.buildBoxDecoration_1(),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                    width: double.infinity,
                    child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(6), bottom: Radius.zero),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/placeholder.png',
                          image:  widget.image,
                          fit: BoxFit.cover,
                        ))),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 6),
                child: Text(
                  widget.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w400),
                ),
              ),
              widget.has_discount ? Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Text(
                  widget.stroked_price,
                  maxLines: 1,
                  style: TextStyle(
                      decoration:TextDecoration.lineThrough,
                      color: MyTheme.medium_grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ):Container(),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Text(
                  widget.main_price,
                  maxLines: 1,
                  style: TextStyle(
                      color: MyTheme.accent_color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),

            ]),
      ),
    );
  }
}
