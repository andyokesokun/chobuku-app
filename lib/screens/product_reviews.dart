import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:expandable/expandable.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/repositories/review_repositories.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:toast/toast.dart';

class ProductReviews extends StatefulWidget {
  final int id;

  ProductReviews({Key? key, required this.id}) : super(key: key);

  @override
  _ProductReviewsState createState() => _ProductReviewsState();
}

class _ProductReviewsState extends State<ProductReviews> {
  final TextEditingController _myReviewTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _innerScrollController = ScrollController();

  double _myRating = 0.0;
  List<dynamic> _reviewList = [];
  bool _isInitial = true;
  int _page = 1;
  int _totalData = 0;
  bool _showLoadingContainer = false;

  @override
  void initState() {
    super.initState();
    fetchData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          _page++;
          _showLoadingContainer = true;
        });
        fetchData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _innerScrollController.dispose();
    _myReviewTextController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    var reviewResponse = await ReviewRepository().getReviewResponse(
      widget.id,
      page: _page,
    );
    _reviewList.addAll(reviewResponse.reviews);
    _isInitial = false;
    _totalData = reviewResponse.meta.total;
    _showLoadingContainer = false;
    setState(() {});
  }

  void reset() {
    _reviewList.clear();
    _isInitial = true;
    _totalData = 0;
    _page = 1;
    _showLoadingContainer = false;
    _myRating = 0.0;
    _myReviewTextController.text = "";
    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchData();
  }

  void onTapReviewSubmit(BuildContext context) async {
    if (is_logged_in.$ == false) {
      ToastComponent.showDialog("You need to login to give a review",
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var myReviewText = _myReviewTextController.text.trim();
    if (myReviewText.isEmpty) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!
              .product_reviews_screen_review_empty_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    } else if (_myRating < 1.0) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.product_reviews_screen_star_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    var reviewSubmitResponse = await ReviewRepository()
        .getReviewSubmitResponse(widget.id, _myRating.toInt(), myReviewText);

    if (reviewSubmitResponse.result == false) {
      ToastComponent.showDialog(reviewSubmitResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    ToastComponent.showDialog(reviewSubmitResponse.message,
        gravity: Toast.center, duration: Toast.lengthLong);

    reset();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: Stack(
          children: [
            RefreshIndicator(
              color: MyTheme.accent_color,
              backgroundColor: Colors.white,
              onRefresh: _onRefresh,
              displacement: 0,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: buildProductReviewsList(),
                      ),
                      const SizedBox(height: 120),
                    ]),
                  )
                ],
              ),
            ),
            Align(alignment: Alignment.bottomCenter, child: buildBottomBar(context)),
            Align(alignment: Alignment.bottomCenter, child: buildLoadingContainer()),
          ],
        ),
      ),
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
        AppLocalizations.of(context)?.product_reviews_screen_reviews ?? '',
        style:  TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget buildBottomBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white54.withOpacity(0.6)),
          height: 120,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: buildGiveReviewSection(context),
          ),
        ),
      ),
    );
  }

  Widget buildProductReviewsList() {
    if (_isInitial && _reviewList.isEmpty) {
      return ShimmerHelper().buildListShimmer(item_count: 10, item_height: 75.0);
    } else if (_reviewList.isNotEmpty) {
      return ListView.builder(
        controller: _innerScrollController,
        itemCount: _reviewList.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: buildProductReviewsItem(index),
          );
        },
      );
    } else if (_totalData == 0) {
      return Container(
        height: 300,
        child: Center(
          child: Text(AppLocalizations.of(context)?.product_reviews_screen_no_reviews_yet ?? ""),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget buildProductReviewsItem(int index) {
    final review = _reviewList[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                border: Border.all(color: Color.fromRGBO(112, 112, 112, .3), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/placeholder.png',
                  image: review.avatar,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 180,
                  child: Text(
                    review.user_name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style:  TextStyle(
                        color: MyTheme.font_grey,
                        fontSize: 13,
                        height: 1.6,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  review.time,
                  style:  TextStyle(color: MyTheme.medium_grey),
                ),
              ],
            ),
            const Spacer(),
            RatingBar(
              itemSize: 12.0,
              ignoreGestures: true,
              initialRating: review.rating,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              ratingWidget: RatingWidget(
                full: const FaIcon(FontAwesomeIcons.solidStar, color: Colors.amber),
                half: const FaIcon(FontAwesomeIcons.starHalfStroke, color: Colors.amber),
                empty: const FaIcon(FontAwesomeIcons.star, color: Color.fromRGBO(224, 224, 225, 1)),
              ),
              itemPadding: const EdgeInsets.only(right: 1.0),
              onRatingUpdate: (_) {},
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 56.0, top: 4.0),
          child: buildExpandableDescription(index),
        )
      ],
    );
  }

  Widget buildExpandableDescription(int index) {
    final review = _reviewList[index];
    return ExpandableNotifier(
      child: ScrollOnExpand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expandable(
              collapsed: Container(
                  height: review.comment.length > 100 ? 32 : 16,
                  child: Text(review.comment, style:  TextStyle(color: MyTheme.font_grey))),
              expanded: Text(review.comment, style:  TextStyle(color: MyTheme.font_grey)),
            ),
            if (review.comment.length > 100)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Builder(
                    builder: (context) {
                      var controller = ExpandableController.of(context);
                      return TextButton(
                        child: Text(
                          !(controller?.expanded ?? false)
                              ? AppLocalizations.of(context)!.common_view_more
                              : AppLocalizations.of(context)!.common_show_less,
                          style:  TextStyle(color: MyTheme.font_grey, fontSize: 11),
                        ),
                        onPressed: () => controller?.toggle(),
                      );
                    },
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget buildLoadingContainer() {
    return Container(
      height: _showLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalData == _reviewList.length
            ? AppLocalizations.of(context)!.product_reviews_screen_no_more_reviews
            : AppLocalizations.of(context)!.product_reviews_screen_loading_more_reviews),
      ),
    );
  }

  Widget buildGiveReviewSection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: RatingBar.builder(
            itemSize: 20.0,
            initialRating: _myRating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            glowColor: Colors.amber,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (_, __) => const FaIcon(FontAwesomeIcons.star, color: Colors.amber),
            onRatingUpdate: (rating) {
              setState(() {
                _myRating = rating;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: (MediaQuery.of(context).size.width - 32) * (4 / 5),
              child: TextField(
                controller: _myReviewTextController,
                autofocus: false,
                maxLines: null,
                inputFormatters: [LengthLimitingTextInputFormatter(125)],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromRGBO(251, 251, 251, 1),
                  hintText: AppLocalizations.of(context)!
                      .product_reviews_screen_type_your_review_here,
                  hintStyle:  TextStyle(fontSize: 14.0, color: MyTheme.textfield_grey),
                  enabledBorder:  OutlineInputBorder(
                    borderSide: BorderSide(color: MyTheme.textfield_grey, width: 0.5),
                    borderRadius: BorderRadius.all(Radius.circular(35.0)),
                  ),
                  focusedBorder:  OutlineInputBorder(
                    borderSide: BorderSide(color: MyTheme.medium_grey, width: 0.5),
                    borderRadius: BorderRadius.all(Radius.circular(35.0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => onTapReviewSubmit(context),
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    color: MyTheme.accent_color,
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: const Color.fromRGBO(112, 112, 112, .3), width: 1),
                  ),
                  child: const Center(
                    child: Icon(Icons.send, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
