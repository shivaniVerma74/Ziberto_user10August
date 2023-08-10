import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/AppBtn.dart';
import 'package:eshop_multivendor/Helper/SimBtn.dart';
import 'package:eshop_multivendor/Helper/widget.dart';
import 'package:eshop_multivendor/Model/FreeProductModel.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/FavoriteProvider.dart';
import 'package:eshop_multivendor/Provider/HomeProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:tuple/tuple.dart';

import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import 'HomePage.dart';
import 'Login.dart';
import 'Product_Detail.dart';

class ProductList extends StatefulWidget {
  final String? name, id;
  final bool? tag, fromSeller, weeklyOffer, fromSale;
  final int? dis;
  final subCatId;
  final buyOneOffer;
  final sellerId;

  const ProductList(
      {Key? key,
      this.id,
      this.name,
      this.tag,
      this.fromSeller,
      this.dis,
      this.subCatId, this.weeklyOffer, this.fromSale, this.buyOneOffer, this.sellerId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StateProduct();
}

class StateProduct extends State<ProductList> with TickerProviderStateMixin {
  bool _isLoading = true, _isProgress = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Product> productList = [];
  List<Product> tempList = [];
  List<FreeProductModel> tList = [];
  List<FreeProductModel> freeProductList = [];
  String sortBy = 'p.id', orderBy = "DESC";
  int offset = 0;
  int total = 0;
  String? totalProduct;
  bool isLoadingmore = true;
  ScrollController controller = new ScrollController();
  var filterList;
  String minPrice = "0", maxPrice = "0";
  List<String>? attnameList;
  List<String>? attsubList;
  List<String>? attListId;
  bool _isNetworkAvail = true;
  List<String> selectedId = [];
  bool _isFirstLoad = true;
  bool isPressed = false;

  String selId = "";
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool listType = true;
  List<TextEditingController> _controller = [];
  List<String>? tagList = [];
  ChoiceChip? tagChip, choiceChip;
  RangeValues? _currentRangeValues;
  bool notDeliver = false;

  DateTime date = DateTime.now();
  late String dateFormat;

  Future validatePin(String pin, productId, bool first) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {ZIPCODE: pin, PRODUCT_ID: productId};
        Response response =
            await post(checkDeliverableApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        print(getdata);
        if (error) {
          return true;
        } else {
          if (pin != context.read<UserProvider>().curPincode) {
            context.read<HomeProvider>().setSecLoading(true);
          }
          context.read<UserProvider>().setPincode(pin);
          //setPrefrence(PINCODE, curPin);
          /*  setState(() {
            CUR_PINCODE = pin;
          });*/
          return false;
        }
        if (!first) {
          Navigator.pop(context);
          setSnackbar(msg!, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  // late UserProvider userProvider;

  @override
  void initState() {
    super.initState();

    dateFormat = DateFormat('EEEE').format(date);
    print("CURRENT DAY=====" + dateFormat.toString());

    controller.addListener(_scrollListener);
//if(widget.buyOneOffer== false) {
  getProduct("0");
// }else{
//   getBuyOne();
// }
    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(new CurvedAnimation(
      parent: buttonController!,
      curve: new Interval(
        0.0,
        0.150,
      ),
    ));
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        if (mounted)
          setState(() {
            isLoadingmore = true;

            if (offset < total) getProduct("0");
          });
      }
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    controller.removeListener(() {});
    for (int i = 0; i < _controller.length; i++) _controller[i].dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    // userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
        appBar: widget.fromSeller! ? null : getAppBar(widget.name!, context),
        key: _scaffoldKey,
        body: _isNetworkAvail
            ? _isLoading
                ? shimmer(context)
                : Stack(
                    children: <Widget>[
                      _showForm(context),
                      showCircularProgress(_isProgress, colors.primary),
                    ],
                  )
            : noInternet(context));
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();
              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  offset = 0;
                  total = 0;
                 // if(widget.buyOneOffer== false) {
                    getProduct("0");
                  // }else{
                  //   getBuyOne();
                  // }
                } else {
                  await buttonController!.reverse();
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  noIntBtn(BuildContext context) {
    double width = deviceWidth!;
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: 10.0, top: 50.0),
        child: Center(
            child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: colors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80.0)),
          ),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => super.widget));
          },
          child: Ink(
            child: Container(
              constraints: BoxConstraints(maxWidth: width / 1.2, minHeight: 45),
              alignment: Alignment.center,
              child: Text(getTranslated(context, 'TRY_AGAIN_INT_LBL')!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: Theme.of(context).colorScheme.white,
                      fontWeight: FontWeight.normal)),
            ),
          ),
        )));
  }

  Widget listItem(int index) {
    print(index);
    Product model = productList[index];
    String id = "";
    String cartCount = "";
    String name = "";
    String image = "";
    String attrName = "";
    String disPrice = "";
    String availability = "";
    if (index < productList.length){
    if(model.id != null){
      id = model.id!;
    }

    if(model.name != null){
      name = model.name!;
    }

    if(model.availability != null){
      availability = model.availability!;
    }
    if(model.image != null){
      image = model.image!;
    }
    // if(model.prVarientList != null){
    //  attrName =  model.prVarientList![model.selVarient!]
    //       .attr_name!;
    // }
    // if(model.prVarientList != null) {
    //   double price =
    //   double.parse(model.prVarientList![model.selVarient!].disPrice!);
    //   if (price == 0) {
    //     price = double.parse(model.prVarientList![model.selVarient!].price!);
    //   }
    // }
    // if(model.prVarientList != null) {
    //   double off = 0;
    //   if (model.prVarientList![model.selVarient!].disPrice! != "0") {
    //     off = (double.parse(model.prVarientList![model.selVarient!].price!) -
    //         double.parse(model.prVarientList![model.selVarient!].disPrice!))
    //         .toDouble();
    //     off = off *
    //         100 /
    //         double.parse(model.prVarientList![model.selVarient!].price!);
    //   }
    // }

   // if (index < productList.length &&  model.prVarientList != null && model.prVarientList![model.selVarient!].cartCount !=  null) {



      totalProduct = model.total;

      if (_controller.length < index + 1)
        _controller.add(new TextEditingController());


      _controller[index].text = "0";
          if(model.prVarientList != null && model.prVarientList!.length > 0){
            _controller[index].text =    model.prVarientList![model.selVarient!].cartCount!;
          }

      List att = [], val = [];
      //
        if (model.prVarientList != null && model.prVarientList!.length > 0 &&  model.prVarientList![model.selVarient!].attr_name != null) {
          att = model.prVarientList![model.selVarient!].attr_name!.split(',');
          val =
              model.prVarientList![model.selVarient!].varient_value!.split(',');
        }
      // }

      double price =  0.00;
        if(model.prVarientList != null && model.prVarientList!.length > 0){
          price =  double.parse(model.prVarientList![model.selVarient!].disPrice!);
        }

      if (price == 0 && model.prVarientList != null && model.prVarientList!.length > 0) {
        price = double.parse(model.prVarientList![model.selVarient!].price!);
      }

      double off = 0;
      if (model.prVarientList != null && model.prVarientList!.length > 0 &&  model.prVarientList![model.selVarient!].disPrice! != "0") {
        off = (double.parse(model.prVarientList![model.selVarient!].price!) -
                double.parse(model.prVarientList![model.selVarient!].disPrice!))
            .toDouble();
        off = off *
            100 /
            double.parse(model.prVarientList![model.selVarient!].price!);
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                child: Stack(children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Hero(
                          tag: id,
                          //"ProList$index${model.id}",
                          child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10)),
                              child: Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 80,
                                        width: 85,
                                        child: FadeInImage(
                                          image: CachedNetworkImageProvider(
                                              image),
                                          height: 50.0,
                                          width: 50.0,
                                          fit: BoxFit.fill,
                                          imageErrorBuilder:
                                              (context, error, stackTrace) =>
                                                  erroWidget(125),
                                          placeholder: placeHolder(125),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned.fill(
                                      child:
                                      availability == "0"
                                          ? Container(
                                              height: 55,
                                              color: Colors.white70,
                                              // width: double.maxFinite,
                                              padding: EdgeInsets.all(2),
                                              child: Center(
                                                child: Text(
                                                  getTranslated(context,
                                                      'OUT_OF_STOCK_LBL')!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption!
                                                      .copyWith(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            )
                                          : Container()),
                                  (off != 0 || off != 0.0 || off != 0.00)
                                      ? Container(
                                          decoration: BoxDecoration(
                                              color: colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                             off.toStringAsFixed(2) + "%",
                                              style: TextStyle(
                                                  color: colors.whiteTemp,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 9),
                                            ),
                                          ),
                                          margin: EdgeInsets.all(5),
                                        )
                                      : Container()
                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //       color: colors.red,
                                  //       borderRadius:
                                  //           BorderRadius.circular(10)),
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.all(5.0),
                                  //     child: Text(
                                  //       off.toStringAsFixed(2) + "%",
                                  //       style: TextStyle(
                                  //           color: colors.whiteTemp,
                                  //           fontWeight: FontWeight.bold,
                                  //           fontSize: 9),
                                  //     ),
                                  //   ),
                                  //   margin: EdgeInsets.all(5),
                                  // )
                                ],
                              ))),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            //mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                name,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // model.prVarientList![model.selVarient!]
                              //                 .attr_name !=
                              //             null &&
                              //         model.prVarientList![model.selVarient!]
                              //             .attr_name!.isNotEmpty
                              attrName != null && attrName.isNotEmpty
                                  ?
                              ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:
                                          att.length >= 2 ? 2 : att.length,
                                      itemBuilder: (context, index) {
                                        return Row(children: [
                                          Flexible(
                                            child: Text(
                                              att[index].trim() + ":",
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .lightBlack),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(
                                                start: 5.0),
                                            child: Text(
                                              val[index],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .lightBlack,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          )
                                        ]);
                                      }) : Container(),
                              (model.rating! == "0" || model.rating! == "0.0")
                                  ? Container()
                                  : Row(
                                      children: [
                                        RatingBarIndicator(
                                          rating: double.parse(model.rating!),
                                          itemBuilder: (context, index) => Icon(
                                            Icons.star_rate_rounded,
                                            color: Colors.amber,
                                            //color: colors.primary,
                                          ),
                                          unratedColor:
                                              Colors.grey.withOpacity(0.5),
                                          itemCount: 5,
                                          itemSize: 18.0,
                                          direction: Axis.horizontal,
                                        ),
                                        Text(
                                          " (" + model.noOfRating! + ")",
                                          style: Theme.of(context)
                                              .textTheme
                                              .overline,
                                        )
                                      ],
                                    ),
                              Row(
                                children: <Widget>[
                                  Text(
                                      CUR_CURRENCY! +
                                          " " +
                                          price.toString() +
                                          " ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor,
                                              fontWeight: FontWeight.bold)),
                                  Text(
                                    // double.parse(model
                                    //             .prVarientList![
                                    //                 model.selVarient!]
                                    //             .disPrice!)
                                        disPrice!=
                                            0
                                        ? CUR_CURRENCY! +
                                            "" +
                                           price.toString()
                                        : "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .overline!
                                        .copyWith(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            letterSpacing: 0),
                                  ),
                                ],
                              ),
                              _controller[index].text != "0" || _controller[index].text != null
                                  ? Row(
                                      children: [
                                        //Spacer(),
                                        model.availability == "0"
                                            ? Container()
                                            : cartBtnList
                                                ? Container()
                                                : Container(),

                                     // isPressed == true ?
                                       // _isProgress == true  ?
                                      //  _isProgress == true
                                        _controller[index].text == "0" ||  _controller[index].text == null ?
                                        Container()
                                            :
                                        Row(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                GestureDetector(
                                                  child: Card(
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          50),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.all(
                                                          8.0),
                                                      child: Icon(
                                                        Icons.remove,
                                                        size: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    if (_isProgress == false &&
                                                        (int.parse(_controller[
                                                        index]
                                                            .text) >
                                                            0))
                                                      removeFromCart(index);
                                                  },
                                                ),
                                                Container(
                                                  width: 26,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: colors.white70,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        5),
                                                  ),
                                                  child: TextField(
                                                    textAlign: TextAlign.center,
                                                    readOnly: true,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .fontColor),
                                                    controller:
                                                    _controller[index],
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  child: Card(
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          50),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.all(
                                                          8.0),
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    if (_isProgress == false)
                                                      addToCart(
                                                          index,

                                                          (int.parse(model
                                                              .prVarientList![
                                                          model
                                                              .selVarient!]
                                                              .cartCount!)
                                                          +
                                                              int.parse(model
                                                                  .qtyStepSize!))
                                                              .toString());
                                                  },
                                                )
                                              ],
                                            ),
                                          ],
                                        )
                                        // : Container(),
                                      ],
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  // model.availability == "0"
                  //     ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                  //         style: Theme.of(context)
                  //             .textTheme
                  //             .subtitle2!
                  //             .copyWith(
                  //                 color: Colors.red,
                  //                 fontWeight: FontWeight.bold))
                  //     : Container(),
                ]),
                onTap: () {
                  print(CUR_CURRENCY);
                  Product model = productList[index];
                  if(widget.buyOneOffer){
                    print("BUY ONE OFFER");
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (_, __, ___) => ProductDetail(
                            freePro: true,
                            model: model,
                            index: index,
                            secPos: 0,
                            list: true,
                            sellerId: widget.id,
                          )),
                    );
                  } else {
                    print("NO OFFER");
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (_, __, ___) => ProductDetail(
                            freePro: false,
                            model: model,
                            index: index,
                            secPos: 0,
                            list: true,
                            sellerId: widget.id,
                          )),
                    );
                  }

                },
              ),
            ),
            widget.fromSale == true ? Container() : _controller[index].text == "0" ||  _controller[index].text == null
                ? Positioned.directional(
                    textDirection: Directionality.of(context),
                    bottom: -15,
                    end: 45,
                    child: InkWell(
                      onTap: () {
                        if(model.id == index ){
                          isPressed = true;
                        }

                        if (_isProgress == false)
                          addToCart(
                              index,
                              (int.parse(_controller[index].text) +
                                      int.parse(model.qtyStepSize!))
                                  .toString());
                      },
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("ADD +" , style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.bold
                          ),),
                        ),
                      ),
                    ),
                  )
                : Container(),
            Positioned.directional(
                textDirection: Directionality.of(context),
                bottom: -15,
                end: 0,
                child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: model.isFavLoading!
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 0.7,
                                )),
                          )
                        : Selector<FavoriteProvider, List<String?>>(
                            builder: (context, data, child) {
                              return InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    !data.contains(model.id)
                                        ? Icons.favorite_border
                                        : Icons.favorite,
                                    size: 20,
                                  ),
                                ),
                                onTap: () {
                                  if (CUR_USERID != null) {
                                    !data.contains(model.id)
                                        ? _setFav(-1, model)
                                        : _removeFav(-1, model);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()),
                                    );
                                  }
                                },
                              );
                            },
                            selector: (_, provider) => provider.favIdList,
                          ))),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: productList[index].indicator.toString()=="null"?
                      Container():productList[index].indicator.toString()=="1"?
                  Image.asset("assets/images/veg.png",height: 15,):productList[index].indicator.toString()=="2"?Image.asset("assets/images/non_veg.jpg",height: 15,):Image.asset("assets/images/egg.png",height: 15,),
                ),
              ],
            ),
          ],
        ),
      );
    } else
      return Container();
  }
  // Widget freeListItem(int index) {
  //   print(index);
  //  // print(freeProductList[index]);
  //   var model = freeProductList[index];
  //   if (index < freeProductList.length ) {
  //
  //
  //   //  print("model value ${model} and ${model.attrIds} and ${model.name} ${model.selVarient}");
  //
  //    // totalProduct = model.total;
  //
  //     if (_controller.length < index + 1)
  //       _controller.add(new TextEditingController());
  //
  //
  //     _controller[index].text =
  //     model.data[index].variants[index].cartCount;
  //
  //     List att = [], val = [];
  //     //
  //     if (model.data[index].variants[index].attrName != null) {
  //       att = model.data[index].variants[index].attrName.split(',');
  //       val =
  //           model.data[index].variants[index].variantValues.split(',');
  //     }
  //     // }
  //
  //     // double price =
  //     // double.parse(model.data[index].variants[index].price.disPrice!);
  //     // if (price == 0) {
  //     //   price = double.parse(model.prVarientList![model.selVarient!].price!);
  //     // }
  //
  //     // double off = 0;
  //     // if (model.prVarientList![model.selVarient!].disPrice! != "0") {
  //     //   off = (double.parse(model.prVarientList![model.selVarient!].price!) -
  //     //       double.parse(model.prVarientList![model.selVarient!].disPrice!))
  //     //       .toDouble();
  //     //   off = off *
  //     //       100 /
  //     //       double.parse(model.data[index].variants[0].price);
  //     // }
  //     return Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
  //       child: Stack(
  //         clipBehavior: Clip.none,
  //         children: [
  //           Card(
  //             elevation: 0,
  //             child: InkWell(
  //               borderRadius: BorderRadius.circular(4),
  //               child: Stack(children: <Widget>[
  //                 Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: <Widget>[
  //                     Hero(
  //                         tag: "ProList$index${model.data[index].id}",
  //                         child: ClipRRect(
  //                             borderRadius: BorderRadius.only(
  //                                 topLeft: Radius.circular(10),
  //                                 bottomLeft: Radius.circular(10)),
  //                             child: Stack(
  //                               children: [
  //                                 Column(
  //                                   mainAxisAlignment: MainAxisAlignment.center,
  //                                   children: [
  //                                     SizedBox(
  //                                       height: 80,
  //                                       width: 85,
  //                                       child: FadeInImage(
  //                                         image: CachedNetworkImageProvider(
  //                                             model.data[index].image),
  //                                         height: 50.0,
  //                                         width: 50.0,
  //                                         fit: BoxFit.fill,
  //                                         imageErrorBuilder:
  //                                             (context, error, stackTrace) =>
  //                                             erroWidget(125),
  //                                         placeholder: placeHolder(125),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 Positioned.fill(
  //                                     child: model.data[index].availability == "0"
  //                                         ? Container(
  //                                       height: 55,
  //                                       color: Colors.white70,
  //                                       // width: double.maxFinite,
  //                                       padding: EdgeInsets.all(2),
  //                                       child: Center(
  //                                         child: Text(
  //                                           getTranslated(context,
  //                                               'OUT_OF_STOCK_LBL')!,
  //                                           style: Theme.of(context)
  //                                               .textTheme
  //                                               .caption!
  //                                               .copyWith(
  //                                             color: Colors.red,
  //                                             fontWeight:
  //                                             FontWeight.bold,
  //                                           ),
  //                                           textAlign: TextAlign.center,
  //                                         ),
  //                                       ),
  //                                     )
  //                                         : Container()),
  //                                 // (off != 0 || off != 0.0 || off != 0.00)
  //                                 //     ?
  //                                 Container(
  //                                   decoration: BoxDecoration(
  //                                       color: colors.red,
  //                                       borderRadius:
  //                                       BorderRadius.circular(10)),
  //                                   child: Padding(
  //                                     padding: const EdgeInsets.all(5.0),
  //                                     child: Text(
  //                                       model.data[index].minMaxPrice.discountInPercentage.toString() + "%",
  //                                       style: TextStyle(
  //                                           color: colors.whiteTemp,
  //                                           fontWeight: FontWeight.bold,
  //                                           fontSize: 9),
  //                                     ),
  //                                   ),
  //                                   margin: EdgeInsets.all(5),
  //                                 )
  //                                    // : Container()
  //                                 // Container(
  //                                 //   decoration: BoxDecoration(
  //                                 //       color: colors.red,
  //                                 //       borderRadius:
  //                                 //           BorderRadius.circular(10)),
  //                                 //   child: Padding(
  //                                 //     padding: const EdgeInsets.all(5.0),
  //                                 //     child: Text(
  //                                 //       off.toStringAsFixed(2) + "%",
  //                                 //       style: TextStyle(
  //                                 //           color: colors.whiteTemp,
  //                                 //           fontWeight: FontWeight.bold,
  //                                 //           fontSize: 9),
  //                                 //     ),
  //                                 //   ),
  //                                 //   margin: EdgeInsets.all(5),
  //                                 // )
  //                               ],
  //                             ))),
  //                     Expanded(
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Column(
  //                           mainAxisSize: MainAxisSize.min,
  //                           //mainAxisAlignment: MainAxisAlignment.center,
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: <Widget>[
  //                             Text(
  //                               model.data[index].name,
  //                               style: Theme.of(context)
  //                                   .textTheme
  //                                   .subtitle1!
  //                                   .copyWith(
  //                                   color: Theme.of(context)
  //                                       .colorScheme
  //                                       .lightBlack),
  //                               maxLines: 1,
  //                               overflow: TextOverflow.ellipsis,
  //                             ),
  //                             model.data[index].variants[0].attrName != null &&
  //                                 model.data[index].variants[0].attrName
  //                                     .isNotEmpty
  //                                 ?
  //                             ListView.builder(
  //                                 physics: NeverScrollableScrollPhysics(),
  //                                 shrinkWrap: true,
  //                                 itemCount:
  //                                 att.length >= 2 ? 2 : att.length,
  //                                 itemBuilder: (context, index) {
  //                                   return Row(children: [
  //                                     Flexible(
  //                                       child: Text(
  //                                         att[index].trim() + ":",
  //                                         overflow: TextOverflow.ellipsis,
  //                                         style: Theme.of(context)
  //                                             .textTheme
  //                                             .subtitle2!
  //                                             .copyWith(
  //                                             color: Theme.of(context)
  //                                                 .colorScheme
  //                                                 .lightBlack),
  //                                       ),
  //                                     ),
  //                                     Padding(
  //                                       padding: EdgeInsetsDirectional.only(
  //                                           start: 5.0),
  //                                       child: Text(
  //                                         val[index],
  //                                         style: Theme.of(context)
  //                                             .textTheme
  //                                             .subtitle2!
  //                                             .copyWith(
  //                                             color: Theme.of(context)
  //                                                 .colorScheme
  //                                                 .lightBlack,
  //                                             fontWeight:
  //                                             FontWeight.bold),
  //                                       ),
  //                                     )
  //                                   ]);
  //                                 }) : Container(),
  //                             (model.data[index].rating == "0" || model.data[index].rating == "0.0")
  //                                 ? Container()
  //                                 : Row(
  //                               children: [
  //                                 RatingBarIndicator(
  //                                   rating: double.parse(model.data[index].rating),
  //                                   itemBuilder: (context, index) => Icon(
  //                                     Icons.star_rate_rounded,
  //                                     color: Colors.amber,
  //                                     //color: colors.primary,
  //                                   ),
  //                                   unratedColor:
  //                                   Colors.grey.withOpacity(0.5),
  //                                   itemCount: 5,
  //                                   itemSize: 18.0,
  //                                   direction: Axis.horizontal,
  //                                 ),
  //                                 Text(
  //                                   " (" + model.data[index].noOfRatings + ")",
  //                                   style: Theme.of(context)
  //                                       .textTheme
  //                                       .overline,
  //                                 )
  //                               ],
  //                             ),
  //                             Row(
  //                               children: <Widget>[
  //                                 Text(
  //                                     CUR_CURRENCY! +
  //                                         " " +
  //                                         model.data[index].variants[index].price.toString() +
  //                                         " ",
  //                                     style: Theme.of(context)
  //                                         .textTheme
  //                                         .subtitle2!
  //                                         .copyWith(
  //                                         color: Theme.of(context)
  //                                             .colorScheme
  //                                             .fontColor,
  //                                         fontWeight: FontWeight.bold)),
  //                                 // Text(
  //                                 //   double.parse(model
  //                                 //       .prVarientList![
  //                                 //   model.selVarient!]
  //                                 //       .disPrice!) !=
  //                                 //       0
  //                                 //       ? CUR_CURRENCY! +
  //                                 //       "" +
  //                                 //       model
  //                                 //           .prVarientList![
  //                                 //       model.selVarient!]
  //                                 //           .price!
  //                                 //       : "",
  //                                 //   style: Theme.of(context)
  //                                 //       .textTheme
  //                                 //       .overline!
  //                                 //       .copyWith(
  //                                 //       decoration:
  //                                 //       TextDecoration.lineThrough,
  //                                 //       letterSpacing: 0),
  //                                 // ),
  //                               ],
  //                             ),
  //                             _controller[index].text != "0" || _controller[index].text != null
  //                                 ? Row(
  //                               children: [
  //                                 //Spacer(),
  //                                 model.data[index].availability == "0"
  //                                     ? Container()
  //                                     : cartBtnList
  //                                     ? Container()
  //                                     : Container(),
  //
  //                                 // isPressed == true ?
  //                                 // _isProgress == true  ?
  //                                 //  _isProgress == true
  //                                 _controller[index].text == "0" ||  _controller[index].text == null ?
  //                                 Container()
  //                                     :
  //                                 Row(
  //                                   children: <Widget>[
  //                                     Row(
  //                                       children: <Widget>[
  //                                         GestureDetector(
  //                                           child: Card(
  //                                             shape:
  //                                             RoundedRectangleBorder(
  //                                               borderRadius:
  //                                               BorderRadius.circular(
  //                                                   50),
  //                                             ),
  //                                             child: Padding(
  //                                               padding:
  //                                               const EdgeInsets.all(
  //                                                   8.0),
  //                                               child: Icon(
  //                                                 Icons.remove,
  //                                                 size: 15,
  //                                               ),
  //                                             ),
  //                                           ),
  //                                           onTap: () {
  //                                             if (_isProgress == false &&
  //                                                 (int.parse(_controller[
  //                                                 index]
  //                                                     .text) >
  //                                                     0))
  //                                               removeFromCart(index);
  //                                           },
  //                                         ),
  //                                         Container(
  //                                           width: 26,
  //                                           height: 20,
  //                                           decoration: BoxDecoration(
  //                                             color: colors.white70,
  //                                             borderRadius:
  //                                             BorderRadius.circular(
  //                                                 5),
  //                                           ),
  //                                           child: TextField(
  //                                             textAlign: TextAlign.center,
  //                                             readOnly: true,
  //                                             style: TextStyle(
  //                                                 fontSize: 12,
  //                                                 color: Theme.of(context)
  //                                                     .colorScheme
  //                                                     .fontColor),
  //                                             controller:
  //                                             _controller[index],
  //                                             decoration: InputDecoration(
  //                                               border: InputBorder.none,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                         GestureDetector(
  //                                           child: Card(
  //                                             shape:
  //                                             RoundedRectangleBorder(
  //                                               borderRadius:
  //                                               BorderRadius.circular(
  //                                                   50),
  //                                             ),
  //                                             child: Padding(
  //                                               padding:
  //                                               const EdgeInsets.all(
  //                                                   8.0),
  //                                               child: Icon(
  //                                                 Icons.add,
  //                                                 size: 15,
  //                                               ),
  //                                             ),
  //                                           ),
  //                                           onTap: () {
  //                                             if (_isProgress == false)
  //                                               addToCart(
  //                                                   index,
  //                                                   (int.parse(model.data[index].variants[0].cartCount) +
  //                                                       int.parse(model.data[index].quantityStepSize))
  //                                                       .toString());
  //                                           },
  //                                         )
  //                                       ],
  //                                     ),
  //                                   ],
  //                                 )
  //                                 // : Container(),
  //                               ],
  //                             )
  //                                 : Container(),
  //                           ],
  //                         ),
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //                 // model.availability == "0"
  //                 //     ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL')!,
  //                 //         style: Theme.of(context)
  //                 //             .textTheme
  //                 //             .subtitle2!
  //                 //             .copyWith(
  //                 //                 color: Colors.red,
  //                 //                 fontWeight: FontWeight.bold))
  //                 //     : Container(),
  //               ]),
  //               onTap: () {
  //                 print(CUR_CURRENCY);
  //                 FreeProductModel model = freeProductList[index];
  //                 if(widget.buyOneOffer){
  //                   print("BUY ONE OFFER");
  //                   Navigator.push(
  //                     context,
  //                     PageRouteBuilder(
  //                         pageBuilder: (_, __, ___) => ProductDetail(
  //                           freePro: true,
  //                           model: model,
  //                           index: index,
  //                           secPos: 0,
  //                           list: true,
  //                           sellerId: widget.id,
  //                         )),
  //                   );
  //                 } else {
  //                   print("NO OFFER");
  //                   Navigator.push(
  //                     context,
  //                     PageRouteBuilder(
  //                         pageBuilder: (_, __, ___) => ProductDetail(
  //                           freePro: false,
  //                           model: model,
  //                           index: index,
  //                           secPos: 0,
  //                           list: true,
  //                           sellerId: widget.id,
  //                         )),
  //                   );
  //                 }
  //
  //               },
  //             ),
  //           ),
  //           widget.fromSale == true ? Container() : _controller[index].text == "0" ||  _controller[index].text == null
  //               ? Positioned.directional(
  //             textDirection: Directionality.of(context),
  //             bottom: -15,
  //             end: 45,
  //             child: InkWell(
  //               onTap: () {
  //
  //
  //                 if (_isProgress == false)
  //                   addToCart(
  //                       index,
  //                       (int.parse(_controller[index].text) +
  //                           int.parse(model.data[index].quantityStepSize))
  //                           .toString());
  //               },
  //               child: Card(
  //                 elevation: 1,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(50),
  //                 ),
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Text("ADD +" , style: TextStyle(
  //                       color: colors.primary,
  //                       fontWeight: FontWeight.bold
  //                   ),),
  //                 ),
  //               ),
  //             ),
  //           )
  //               : Container(),
  //           Positioned.directional(
  //               textDirection: Directionality.of(context),
  //               bottom: -15,
  //               end: 0,
  //               child: Card(
  //                   elevation: 1,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(50),
  //                   ),
  //                   child: model.data[index].isFavorite == "0"
  //                       ?
  //               Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Container(
  //                         height: 20,
  //                         width: 20,
  //                         child: CircularProgressIndicator(
  //                           strokeWidth: 0.7,
  //                         )),
  //                   )
  //                       : Selector<FavoriteProvider, List<String?>>(
  //                     builder: (context, data, child) {
  //                       return InkWell(
  //                         child: Padding(
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: Icon(
  //                             !data.contains(model.data[index].id)
  //                                 ? Icons.favorite_border
  //                                 : Icons.favorite,
  //                             size: 20,
  //                           ),
  //                         ),
  //                         onTap: () {
  //                           if (CUR_USERID != null) {
  //                             // !data.contains(model.data[index].id)
  //                             //     ? _setFav(-1, model!)
  //                             //     : _removeFav(-1, model);
  //                           } else {
  //                             Navigator.push(
  //                               context,
  //                               MaterialPageRoute(
  //                                   builder: (context) => Login()),
  //                             );
  //                           }
  //                         },
  //                       );
  //                     },
  //                     selector: (_, provider) => provider.favIdList,
  //                   ))),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.end,
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: freeProductList[index].data[index].indicator.toString()=="null"?
  //                 Container():freeProductList[index].data[index].indicator.toString()=="1"?
  //                 Image.asset("assets/images/veg.png",height: 15,):freeProductList[index].data[index].indicator.toString()=="2"?Image.asset("assets/images/non_veg.jpg",height: 15,):Image.asset("assets/images/egg.png",height: 15,),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     );
  //   } else
  //     return Container();
  // }

  _setFav(int index, Product model) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = true
                : productList[index].isFavLoading = true;
          });

        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: model.id};
        print(parameter);
        Response response =
            await post(setFavoriteApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          index == -1 ? model.isFav = "1" : productList[index].isFav = "1";

          context.read<FavoriteProvider>().addFavItem(model);
        } else {
          setSnackbar(msg!, context);
        }

        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = false
                : productList[index].isFavLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  _removeFav(int index, Product model) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = true
                : productList[index].isFavLoading = true;
          });

        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: model.id};
        Response response =
            await post(removeFavApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          index == -1 ? model.isFav = "0" : productList[index].isFav = "0";
          context
              .read<FavoriteProvider>()
              .removeFavItem(model.prVarientList![0].id!);
        } else {
          setSnackbar(msg!, context);
        }

        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = false
                : productList[index].isFavLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  // /*_setFav(Product model) async {
  //    _isNetworkAvail = await isNetworkAvailable();
  //   if (_isNetworkAvail) {
  //     if (mounted)
  //       setState(() {
  //         model.isFavLoading = true;
  //       });

  //     var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: model.id};

  //     apiBaseHelper.postAPICall(setFavoriteApi, parameter).then((getdata) {
  //       bool error = getdata["error"];
  //       String? msg = getdata["message"];
  //       if (!error) {
  //         model.isFav = "1";
  //         context.read<FavoriteProvider>().addFavItem(model);
  //       } else {
  //         setSnackbar(msg!, context);
  //       }

  //       if (mounted)
  //         setState(() {
  //           model.isFavLoading = false;
  //         });
  //     }, onError: (error) {
  //       setSnackbar(error.toString(), context);
  //     });
  //   } else {
  //     if (mounted)
  //       setState(() {
  //         _isNetworkAvail = false;
  //       });
  //   }
  // }

  // _removeFav(Product model) async {
  //   _isNetworkAvail = await isNetworkAvailable();
  //   if (_isNetworkAvail) {
  //     if (mounted)
  //       setState(() {
  //         model.isFavLoading = true;
  //       });

  //     var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: model.id};

  //     apiBaseHelper.postAPICall(removeFavApi, parameter).then((getdata) {
  //       bool error = getdata["error"];
  //       String? msg = getdata["message"];
  //       if (!error) {
  //         model.isFav = "0";

  //         /*  favList.removeWhere((item) =>
  //         item.productList![0].prVarientList![0].id ==
  //             widget.model!.prVarientList![0].id);*/
  //       } else {
  //         setSnackbar(msg!, context);
  //       }

  //       if (mounted)
  //         setState(() {
  //           model.isFavLoading = false;
  //         });
  //     }, onError: (error) {
  //       setSnackbar(error.toString(), context);
  //     });
  //   } else {
  //     if (mounted)
  //       setState(() {
  //         _isNetworkAvail = false;
  //       });
  //   }
  // }*/

  removeFromCart(int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        if (mounted)
          setState(() {
            _isProgress = true;
          });

        int qty;

        qty =
            /*      (int.parse(productList[index]
                .prVarientList![productList[index].selVarient!]
                .cartCount!)*/
            (int.parse(_controller[index].text) -
                int.parse(productList[index].qtyStepSize!));

        if (qty < productList[index].minOrderQuntity!) {
          qty = 0;
        }

        var parameter = {
          PRODUCT_VARIENT_ID: productList[index]
              .prVarientList![productList[index].selVarient!]
              .id,
          USER_ID: CUR_USERID,
          QTY: qty.toString(),
          "seller_id": "${widget.id}"
        };

        apiBaseHelper.postAPICall(manageCartApi, parameter).then(
            (getdata) async {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String? qty = data['total_quantity'];
            // CUR_CART_COUNT = ;

            context.read<UserProvider>().setCartCount(data['cart_count']);
            productList[index]
                .prVarientList![productList[index].selVarient!]
                .cartCount = qty.toString();

            var cart = getdata["cart"];
            List<SectionModel> cartList = (cart as List)
                .map((cart) => new SectionModel.fromCart(cart))
                .toList();
            context.read<CartProvider>().setCartlist(cartList);
            _isProgress = false;
          } else {
            var data = await clearCart(context, msg);
            if (data) {
              setState(() {
                if (mounted)
                  setState(() {
                    context.read<UserProvider>().setCartCount(0.toString());
                    _isProgress = false;
                  });
              });
            } else {
              if (mounted)
                setState(() {
                  _isProgress = false;
                });
            }
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          setState(() {
            _isProgress = false;
          });
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  void getProduct(String top) {
    // _currentRangeValues.start.round().toString(),
    // _currentRangeValues.end.round().toString(),
    Map parameter = {
     // ATTRIBUTE_VALUE_ID: attListId,
      SORT: sortBy,
      ORDER: orderBy,
      SUB_CAT_ID: widget.subCatId ?? "",
      LIMIT: perPage.toString(),
      OFFSET: offset.toString(),
      TOP_RETAED: top,
      // "day": dateFormat.toString(),
    };
    var param = {
      "seller_id": widget.sellerId
    };

    if (selId != null && selId != "") {
      parameter[ATTRIBUTE_VALUE_ID] = selId;
    }
    if (widget.tag!) parameter[TAG] = widget.name!;
    if (widget.fromSeller!) {
      parameter["seller_id"] = widget.id!;
    } else {
      parameter[CATID] = widget.id ?? '';
    }
    if(widget.weeklyOffer!){
      parameter["day"] = dateFormat.toString();
    }
    // if(widget.buyOneOffer){
    //   parameter["buy_one"] = "1";
    //   parameter["seller_id"] = widget.id;
    // }
    if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;

    if (widget.dis != null) parameter[DISCOUNT] = widget.dis.toString();

    if (_currentRangeValues != null &&
        _currentRangeValues!.start.round().toString() != "0") {
      parameter[MINPRICE] = _currentRangeValues!.start.round().toString();
    }
    if (_currentRangeValues != null &&
        _currentRangeValues!.end.round().toString() != "0") {
      parameter[MAXPRICE] = _currentRangeValues!.end.round().toString();
    }

    print(parameter);
    print(widget.buyOneOffer);

    apiBaseHelper.postAPICall(widget.buyOneOffer == false ? getProductApi : getBuyOneApi,widget.buyOneOffer == false ? parameter: param).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      print(getBuyOneApi.toString());
     // print(param.toString());
      if (!error) {
        total = int.parse(getdata["total"]);

        if (_isFirstLoad) {
          filterList = getdata["filters"];

          minPrice = getdata[MINPRICE];
          maxPrice = getdata[MAXPRICE];
          _currentRangeValues =
              RangeValues(double.parse(minPrice), double.parse(maxPrice));
          _isFirstLoad = false;
        }

        if ((offset) < total) {
          tempList.clear();

          var data = getdata["data"];
        //  widget.buyOneOffer == false ?
          tempList =
              (data as List).map((data) => new Product.fromJson(data)).toList();
          // : tList =
          //     (data as List).map((data) => new FreeProductModel.fromJson(data)).toList();

          if (getdata.containsKey(TAG)) {
            List<String> tempList = List<String>.from(getdata[TAG]);
            if (tempList != null && tempList.length > 0) tagList = tempList;
          }

          getAvailVarient();

          offset = offset + perPage;
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg!, context);
          isLoadingmore = false;
        }
      } else {
        isLoadingmore = false;
        if (msg != "Products Not Found !") setSnackbar(msg!, context);
      }

      setState(() {
        _isLoading = false;
      });
      // context.read<ProductListProvider>().setProductLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      setState(() {
        _isLoading = false;
      });
      //context.read<ProductListProvider>().setProductLoading(false);
    });
  }
  void getBuyOne() {
    // _currentRangeValues.start.round().toString(),
    // _currentRangeValues.end.round().toString(),
    // Map parameter = {
    //   // ATTRIBUTE_VALUE_ID: attListId,
    //   SORT: sortBy,
    //   ORDER: orderBy,
    //   SUB_CAT_ID: widget.subCatId ?? "",
    //   LIMIT: perPage.toString(),
    //   OFFSET: offset.toString(),
    //   TOP_RETAED: "",
    //   // "day": dateFormat.toString(),
    // };
    var param = {
      'seller_id' : widget.sellerId
    };
    // if (selId != null && selId != "") {
    //   parameter[ATTRIBUTE_VALUE_ID] = selId;
    // }
    // if (widget.tag!) parameter[TAG] = widget.name!;
    // if (widget.fromSeller!) {
    //   parameter["seller_id"] = widget.id!;
    // } else {
    //   parameter[CATID] = widget.id ?? '';
    // }
    // if(widget.weeklyOffer!){
    //   parameter["day"] = dateFormat.toString();
    // }
    // if(widget.buyOneOffer){
    //   parameter["buy_one"] = "1";
    //   parameter["seller_id"] = widget.id;
    // }
    // if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;
    //
    // if (widget.dis != null) parameter[DISCOUNT] = widget.dis.toString();
    //
    // if (_currentRangeValues != null &&
    //     _currentRangeValues!.start.round().toString() != "0") {
    //   parameter[MINPRICE] = _currentRangeValues!.start.round().toString();
    // }
    // if (_currentRangeValues != null &&
    //     _currentRangeValues!.end.round().toString() != "0") {
    //   parameter[MAXPRICE] = _currentRangeValues!.end.round().toString();
    // }
    //
    // print(parameter);

    apiBaseHelper.postAPICall(getBuyOneApi, param).then((getData) {
      bool error = getData["error"];
      String? msg = getData["message"];
       if (!error) {
        total = int.parse(getData["total"]);

        if (_isFirstLoad) {
          filterList = getData["filters"];

          minPrice = getData[MINPRICE];
          maxPrice = getData[MAXPRICE];
          _currentRangeValues =
              RangeValues(double.parse(minPrice), double.parse(maxPrice));
          _isFirstLoad = false;
        }

        if ((offset) < total) {
          tList.clear();

          List<FreeProductModel> data = getData["data"];
          freeProductList = data;
          tList =
              (data as List).map((data) =>  FreeProductModel.fromJson(data)).cast<FreeProductModel>().toList();
          // print(tList);
         // freeProductList = data;
        // var freeProductList = (data as List).map((data) => new FreeProductModel.fromJson(data)).toList() ;
         print(freeProductList);
          if (getData.containsKey(TAG)) {
            List<String> tempList = List<String>.from(getData[TAG]);
            if (tempList != null && tempList.length > 0) tagList = tempList;
          }

          getAvailVarient();

          offset = offset + perPage;
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg!, context);
          isLoadingmore = false;
        }
      } else {
        isLoadingmore = false;
        if (msg != "Products Not Found !") setSnackbar(msg!, context);
      }

      setState(() {
        _isLoading = false;
      });
      // context.read<ProductListProvider>().setProductLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      setState(() {
        _isLoading = false;
      });
      //context.read<ProductListProvider>().setProductLoading(false);
    });
  }

  void getAvailVarient() {
    for (int j = 0; j < tempList.length; j++) {
      if (tempList[j].stockType == "2") {
        for (int i = 0; i < tempList[j].prVarientList!.length; i++) {
          if (tempList[j].prVarientList![i].availability == "1") {
            tempList[j].selVarient = i;

            break;
          }
        }
      }
    }
    productList.addAll(tempList);
  }

/*  getAppbar() {
    String cartCount =
        Provider.of<UserProvider>(context, listen: false).curCartCount;
    return AppBar(
      titleSpacing: 0,
      iconTheme: IconThemeData(color: colors.primary),
      title: Text(
        widget.name!,
        style: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
        ),
      ),
      elevation: 5,
      backgroundColor: Theme.of(context).colorScheme.white,
      leading: Builder(builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.all(10),

          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 4.0),
              child: Icon( Icons.arrow_back_ios_rounded, color: colors.primary),
            ),
          ),
        );
      }),
      actions: <Widget>[
        */
  /*  Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: shadow(),
          child: Card(
            elevation: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Search(),
                    ));
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.search,
                  color: colors.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
        Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: shadow(),
            child: Card(
                elevation: 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          listType ? Icons.grid_view : Icons.list,
                          color: colors.primary,
                          size: 22,
                        ),
                      ),
                      onTap: () {
                        productList.length != 0
                            ? setState(() {
                                listType = !listType;
                              })
                            : null;
                      }),
                ))),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: shadow(),
          child: Card(
            elevation: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                CUR_USERID == null
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Login(),
                        ))
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Cart(),
                        ));
              },
              child: new Stack(children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SvgPicture.asset(
                      'assets/images/noti_cart.svg',
                    ),
                  ),
                ),
                (cartCount.isNotEmpty && cartCount != "0")
                    ? new Positioned(
                        top: 0.0,
                        right: 5.0,
                        bottom: 10,
                        child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.primary.withOpacity(0.5)),
                            child: new Center(
                              child: Padding(
                                padding: EdgeInsets.all(3),
                                child: new Text(
                                  cartCount,
                                  style: TextStyle(
                                      fontSize: 7, fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                      )
                    : Container()
              ]),
            ),
          ),
        ),
        Container(
            width: 40,
            margin: EdgeInsetsDirectional.only(top: 10, bottom: 10, end: 5),
            decoration: shadow(),
            child: Card(
                elevation: 0,
                child: Material(
                    color: Colors.transparent,
                    child: PopupMenuButton(
                      padding: EdgeInsets.zero,
                      onSelected: (dynamic value) {
                        switch (value) {
                          case 0:
                            return filterDialog();

                          case 1:
                            return sortDialog();
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                        PopupMenuItem(
                          value: 0,
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsetsDirectional.only(
                                start: 0.0, end: 0.0),
                            leading: Icon(
                              Icons.tune,
                              color: Theme.of(context).colorScheme.fontColor,
                              size: 20,
                            ),
                            title: Text('Filter'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 1,
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsetsDirectional.only(
                                start: 0.0, end: 0.0),
                            leading: Icon(Icons.sort,
                                color: Theme.of(context).colorScheme.fontColor, size: 20),
                            title: Text('Sort'),
                          ),
                        ),
                      ],
                    )))),*/
  /*
      ],
    );
  }*/

  Widget productItem(int index, bool pad) {
    if (index < productList.length) {
      Product model = productList[index];

      double price =
          double.parse(model.prVarientList![model.selVarient!].disPrice!);
      if (price == 0) {
        price = double.parse(model.prVarientList![model.selVarient!].price!);
      }

      double off = 0;
      if (model.prVarientList![model.selVarient!].disPrice! != "0") {
        off = (double.parse(model.prVarientList![model.selVarient!].price!) -
                double.parse(model.prVarientList![model.selVarient!].disPrice!))
            .toDouble();
        off = off *
            100 /
            double.parse(model.prVarientList![model.selVarient!].price!);
      }

      if (_controller.length < index + 1)
        _controller.add(new TextEditingController());

      _controller[index].text =
          model.prVarientList![model.selVarient!].cartCount!;

      List att = [], val = [];
      if (model.prVarientList![model.selVarient!].attr_name != null) {
        att = model.prVarientList![model.selVarient!].attr_name!.split(',');
        val = model.prVarientList![model.selVarient!].varient_value!.split(',');
      }
      double width = deviceWidth! * 0.5;

      return InkWell(
        child: Card(
          elevation: 0.2,
          margin: EdgeInsetsDirectional.only(
              bottom: 10, end: 10, start: pad ? 10 : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      child: Hero(
                        tag: "ProGrid$index${model.id}",
                        child: FadeInImage(
                          fadeInDuration: Duration(milliseconds: 150),
                          image: CachedNetworkImageProvider(model.image!),
                          height: 50.0,
                          width: 50.0,
                          fit: extendImg ? BoxFit.fill : BoxFit.fitHeight,
                          placeholder: placeHolder(width),
                          imageErrorBuilder: (context, error, stackTrace) =>
                              erroWidget(width),
                        ),
                      ),
                    ),
                    Positioned.fill(
                        child: model.availability == "0"
                            ? Container(
                                height: 55,
                                color: Colors.white70,
                                // width: double.maxFinite,
                                padding: EdgeInsets.all(2),
                                child: Center(
                                  child: Text(
                                    getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : Container()),
                    // Align(
                    //   alignment: AlignmentDirectional.center,
                    //   child: model.availability == "0"
                    //       ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                    //           style: Theme.of(context)
                    //               .textTheme
                    //               .subtitle2!
                    //               .copyWith(
                    //                   color: Colors.red,
                    //                   fontWeight: FontWeight.bold))
                    //       : Container(),
                    // ),
                    (off != 0 || off != 0.0 || off != 0.00)
                        ? Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: colors.red,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  off.toStringAsFixed(2) + "%",
                                  style: TextStyle(
                                      color: colors.whiteTemp,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9),
                                ),
                              ),
                              margin: EdgeInsets.all(5),
                            ),
                          )
                        : Container(),

                    // Align(
                    //   alignment: Alignment.topLeft,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //         color: colors.red,
                    //         borderRadius: BorderRadius.circular(10)),
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(5.0),
                    //       child: Text(
                    //         off.toStringAsFixed(2) + "%",
                    //         style: TextStyle(
                    //             color: colors.whiteTemp,
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 9),
                    //       ),
                    //     ),
                    //     margin: EdgeInsets.all(5),
                    //   ),
                    // ),
                    Divider(
                      height: 1,
                    ),
                    Positioned.directional(
                      textDirection: Directionality.of(context),
                      end: 0,
                      // bottom: -18,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //Todo undo comment

                          model.availability == "0" && !cartBtnList
                              ? Container()
                              : _controller[index].text == "0" ||  _controller[index].text == null
                                  ? InkWell(
                                      onTap: () {
                                        if (_isProgress == false)
                                          addToCart(
                                              index,
                                              (int.parse(_controller[index]
                                                          .text) +
                                                      int.parse(
                                                          model.qtyStepSize!))
                                                  .toString());
                                      },
                                      child: Card(
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.shopping_cart_outlined,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          start: 3.0, bottom: 5, top: 3),
                                      child: Row(
                                        children: <Widget>[
                                          GestureDetector(
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              if (_isProgress == false &&
                                                  (int.parse(_controller[index]
                                                          .text) >
                                                      0)) removeFromCart(index);
                                            },
                                          ),
                                          Container(
                                            width: 26,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: colors.white70,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: TextField(
                                              textAlign: TextAlign.center,
                                              readOnly: true,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor),
                                              controller: _controller[index],
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ), // ),
                                          GestureDetector(
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              if (_isProgress == false)
                                                addToCart(
                                                    index,
                                                    (int.parse(_controller[
                                                                    index]
                                                                .text) +
                                                            int.parse(model
                                                                .qtyStepSize!))
                                                        .toString());
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                          Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: model.isFavLoading!
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: 15,
                                          width: 15,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 0.7,
                                          )),
                                    )
                                  : Selector<FavoriteProvider, List<String?>>(
                                      builder: (context, data, child) {
                                        return InkWell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              !data.contains(model.id)
                                                  ? Icons.favorite_border
                                                  : Icons.favorite,
                                              size: 15,
                                            ),
                                          ),
                                          onTap: () {
                                            if (CUR_USERID != null) {
                                              !data.contains(model.id)
                                                  ? _setFav(-1, model)
                                                  : _removeFav(-1, model);
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Login()),
                                              );
                                            }
                                          },
                                        );
                                      },
                                      selector: (_, provider) =>
                                          provider.favIdList,
                                    )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              (model.rating! == "0" || model.rating! == "0.0")
                  ? Container()
                  : Row(
                      children: [
                        RatingBarIndicator(
                          rating: double.parse(model.rating!),
                          itemBuilder: (context, index) => Icon(
                            Icons.star_rate_rounded,
                            color: Colors.amber,
                            //color: colors.primary,
                          ),
                          unratedColor: Colors.grey.withOpacity(0.5),
                          itemCount: 5,
                          itemSize: 12.0,
                          direction: Axis.horizontal,
                          itemPadding: EdgeInsets.all(0),
                        ),
                        Text(
                          " (" + model.noOfRating! + ")",
                          style: Theme.of(context).textTheme.overline,
                        )
                      ],
                    ),
              Row(
                children: [
                  Text(" " + CUR_CURRENCY! + " " + price.toString() + " ",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold)),
                  double.parse(model
                              .prVarientList![model.selVarient!].disPrice!) !=
                          0
                      ? Flexible(
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  double.parse(model
                                              .prVarientList![model.selVarient!]
                                              .disPrice!) !=
                                          0
                                      ? CUR_CURRENCY! +
                                          "" +
                                          model
                                              .prVarientList![model.selVarient!]
                                              .price!
                                      : "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline!
                                      .copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          letterSpacing: 0),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container()
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  children: [
                    Expanded(
                      child: model.prVarientList![model.selVarient!]
                                      .attr_name !=
                                  null &&
                              model.prVarientList![model.selVarient!].attr_name!
                                  .isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: att.length >= 2 ? 2 : att.length,
                              itemBuilder: (context, index) {
                                return Row(children: [
                                  Flexible(
                                    child: Text(
                                      att[index].trim() + ":",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .lightBlack),
                                    ),
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.only(
                                          start: 5.0),
                                      child: Text(
                                        val[index],
                                        maxLines: 1,
                                        overflow: TextOverflow.visible,
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightBlack,
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                ]);
                              })
                          : Container(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.only(start: 5.0, bottom: 5),
                child: Text(
                  model.name!,
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: Theme.of(context).colorScheme.lightBlack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          //),
        ),
        onTap: () {
          Product model = productList[index];
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ProductDetail(
                model: model,
                index: index,
                secPos: 0,
                list: true,
              ),
            ),
          );

        },
      );
    } else
      return Container();
  }

  void sortDialog() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.white,
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                        padding:
                            EdgeInsetsDirectional.only(top: 19.0, bottom: 16.0),
                        child: Text(
                          getTranslated(context, 'SORT_BY')!,
                          style: Theme.of(context).textTheme.headline6,
                        )),
                  ),
                  InkWell(
                    onTap: () {
                      sortBy = '';
                      orderBy = 'DESC';
                      if (mounted)
                        setState(() {
                          _isLoading = true;
                          total = 0;
                          offset = 0;
                          productList.clear();
                        });
                     // if(widget.buyOneOffer== false) {
                        getProduct("1");
                      // }else{
                      //   getBuyOne();
                      // }
                      Navigator.pop(context, 'option 1');
                    },
                    child: Container(
                      width: deviceWidth,
                      color: sortBy == ''
                          ? colors.primary
                          : Theme.of(context).colorScheme.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(getTranslated(context, 'TOP_RATED')!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color: sortBy == ''
                                      ? Theme.of(context).colorScheme.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .fontColor)),
                    ),
                  ),
                  InkWell(
                      child: Container(
                          width: deviceWidth,
                          color: sortBy == 'p.date_added' && orderBy == 'DESC'
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: Text(getTranslated(context, 'F_NEWEST')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                      color: sortBy == 'p.date_added' &&
                                              orderBy == 'DESC'
                                          ? Theme.of(context).colorScheme.white
                                          : Theme.of(context)
                                              .colorScheme
                                              .fontColor))),
                      onTap: () {
                        sortBy = 'p.date_added';
                        orderBy = 'DESC';
                        if (mounted)
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                      //  if(widget.buyOneOffer== false) {
                          getProduct("0");
                        // }else{
                        //   getBuyOne();
                        // }
                        Navigator.pop(context, 'option 1');
                      }),
                  InkWell(
                      child: Container(
                          width: deviceWidth,
                          color: sortBy == 'p.date_added' && orderBy == 'ASC'
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: Text(
                            getTranslated(context, 'F_OLDEST')!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(
                                    color: sortBy == 'p.date_added' &&
                                            orderBy == 'ASC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                          )),
                      onTap: () {
                        sortBy = 'p.date_added';
                        orderBy = 'ASC';
                        if (mounted)
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                       // if(widget.buyOneOffer== false) {
                          getProduct("0");
                        // }else{
                        //   getBuyOne();
                        // }
                        Navigator.pop(context, 'option 2');
                      }),
                  InkWell(
                      child: Container(
                          width: deviceWidth,
                          color: sortBy == 'pv.price' && orderBy == 'ASC'
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: new Text(
                            getTranslated(context, 'F_LOW')!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(
                                    color: sortBy == 'pv.price' &&
                                            orderBy == 'ASC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                          )),
                      onTap: () {
                        sortBy = 'pv.price';
                        orderBy = 'ASC';
                        if (mounted)
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                       // if(widget.buyOneOffer== false) {
                          getProduct("0");
                        // }else{
                        //   getBuyOne();
                        // }
                        Navigator.pop(context, 'option 3');
                      }),
                  InkWell(
                      child: Container(
                          width: deviceWidth,
                          color: sortBy == 'pv.price' && orderBy == 'DESC'
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: new Text(
                            getTranslated(context, 'F_HIGH')!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(
                                    color: sortBy == 'pv.price' &&
                                            orderBy == 'DESC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                          )),
                      onTap: () {
                        sortBy = 'pv.price';
                        orderBy = 'DESC';
                        if (mounted)
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                       // if(widget.buyOneOffer== false) {
                          getProduct("0");
                        // }else{
                        //   getBuyOne();
                        // }
                        Navigator.pop(context, 'option 4');
                      }),
                ]),
          );
        });
      },
    );
  }

/*  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        if (mounted)
          setState(() {
            isLoadingmore = true;

            if (offset < total) getProduct("0");
          });
      }
    }
  }*/

  Future<void> addToCart(int index, String qty) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        if (mounted)
          setState(() {
            _isProgress = true;
          });

        if (int.parse(qty) < productList[index].minOrderQuntity!) {
          qty = productList[index].minOrderQuntity.toString();

          setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
        }
        var productVarId = "";
        if(productList[index].prVarientList != null && productList[index].prVarientList!.length > 0){
          productVarId = productList[index].prVarientList![productList[index].selVarient!].id!;
        }else{
          productVarId =  productList[index].id!;
        }
        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_VARIENT_ID: productVarId,
          QTY:  qty  ,
          "seller_id": "${widget.id}"
        };
        print("ADD TO CART PARAMETER =============== $parameter");
        apiBaseHelper.postAPICall(manageCartApi, parameter).then(
            (getdata) async {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];
            String? qty = data['total_quantity'];
            // CUR_CART_COUNT = data['cart_count'];

            context.read<UserProvider>().setCartCount(data['cart_count']);
            // if(productList[index]
            //     .prVarientList![productList[index].selVarient!]
            //     .cartCount != null ){
            //   qty = productList[index]
            //       .prVarientList![productList[index].selVarient!]
            //       .cartCount!;
            // }else{
            //   qty =  "1";
            // }
            // if(productList[index]
            //     .prVarientList![productList[index].selVarient!]
            //     .cartCount!= null){
            productList[index]
                .prVarientList![productList[index].selVarient!]
                .cartCount = qty.toString();
           // }

            var cart = getdata["cart"];
            List<SectionModel> cartList = (cart as List)
                .map((cart) => new SectionModel.fromCart(cart))
                .toList();
            context.read<CartProvider>().setCartlist(cartList);
          } else {
            var data = await clearCart(context, msg);
            if (data) {
              setState(() {
                if (mounted)
                  setState(() {
                    context.read<UserProvider>().setCartCount(0.toString());
                    _isProgress = false;
                  });
              });
            } else {
              if (mounted)
                setState(() {
                  _isProgress = false;
                });
            }
          }
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

/*  Future<Null>  _refresh() {

 */
  /*   if (mounted)
      setState(() {
        _isLoading = true;
        isLoadingmore = true;
        offset = 0;
        total = 0;
        productList.clear();
      });
    getProduct("0");*/ /*

  }*/

  _showForm(BuildContext context) {
    var checkOut = Provider.of<UserProvider>(context , listen: false);
    return /*RefreshIndicator(
        key: _refreshIndicatorKey,
        //onRefresh: _refresh,
        child: */
        Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.white,
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              if (widget.fromSeller!) Container() else _tags(),
              filterOptions(),
            ],
          ),
        ),
        // widget.buyOneOffer == false ?
        Expanded(
          child: productList.length == 0
              ? getNoItem(context)
              : listType
                  ? ListView.builder(
                      controller: controller,
                      itemCount: (offset < total)
                          ? productList.length + 1
                          : productList.length,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        print(productList.length);
                        return
                          (index == productList.length && isLoadingmore)
                            ? singleItemSimmer(context)
                            : listItem(index);
                      },
                    )
                  : GridView.count(
                      padding: EdgeInsetsDirectional.only(top: 5),
                      crossAxisCount: 2,
                      controller: controller,
                      childAspectRatio: 0.78,
                      physics: AlwaysScrollableScrollPhysics(),
                      children: List.generate(
                        (offset < total)
                            ? productList.length + 1
                            : productList.length,
                        (index) {
                          return (index == productList.length && isLoadingmore)
                              ? simmerSingleProduct(context)
                              : productItem(
                                  index, index % 2 == 0 ? true : false);
                        },
                      )),
        )
       // : Container(
       //    height: 350,
       //   child: ListView.builder(
       //      controller: controller,
       //      itemCount:
       //      // (offset < total)
       //      //     ? freeProductList.length + 1
       //      //     :
       //      freeProductList.length,
       //      physics: AlwaysScrollableScrollPhysics(),
       //      itemBuilder: (context, index) {
       //        print(freeProductList.length);
       //        return
       //          (index == freeProductList.length && isLoadingmore)
       //              ? singleItemSimmer(context)
       //              : freeListItem(index);
       //      },
       //    ),
       // ),
       // int.parse(checkOut.curCartCount) > 0 ?
       //  Container(
       //    height: MediaQuery.of(context).size.height*.08,
       //  ):Container()
      ],
    );
  }

  Widget _tags() {
    if (tagList != null && tagList!.length > 0) {
      List<Widget> chips = [];
      for (int i = 0; i < tagList!.length; i++) {
        tagChip = ChoiceChip(
          selected: false,
          label: Text(tagList![i],
              style: TextStyle(color: Theme.of(context).colorScheme.white)),
          backgroundColor: colors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          onSelected: (bool selected) {
            if (selected) if (mounted)
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductList(
                      name: tagList![i],
                      tag: true,
                      fromSeller: false,
                    ),
                  ));
          },
        );

        chips.add(Padding(
            padding: EdgeInsets.symmetric(horizontal: 5), child: tagChip));
      }

      return Container(
        height: 50,
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: chips),
      );
    } else {
      return Container();
    }
  }

  filterOptions() {
    return Container(
      color: Theme.of(context).colorScheme.gray,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: filterDialog,
            icon: Icon(
              Icons.filter_list,
              color: colors.primary,
            ),
            label: Text(
              getTranslated(context, 'FILTER')!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: sortDialog,
            icon: Icon(
              Icons.swap_vert,
              color: colors.primary,
            ),
            label: Text(
              getTranslated(context, 'SORT_BY')!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
              ),
            ),
          ),
          // InkWell(
          //   child: Icon(
          //     listType ? Icons.grid_view : Icons.list,
          //     color: colors.primary,
          //   ),
          //   onTap: () {
          //     productList.length != 0
          //         ? setState(() {
          //             listType = !listType;
          //           })
          //         : null;
          //   },
          // ),
        ],
      ),
    );
  }

  void filterDialog() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
                padding: const EdgeInsetsDirectional.only(top: 30.0),
                child: AppBar(
                  title: Text(
                    getTranslated(context, 'FILTER')!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontColor,
                    ),
                  ),
                  centerTitle: true,
                  elevation: 5,
                  backgroundColor: Theme.of(context).colorScheme.white,
                  leading: Builder(builder: (BuildContext context) {
                    return Container(
                      margin: EdgeInsets.all(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 4.0),
                          child: Icon(Icons.arrow_back_ios_rounded,
                              color: colors.primary),
                        ),
                      ),
                    );
                  }),
                )),
            Expanded(
                child: Container(
              color: Theme.of(context).colorScheme.lightWhite,
              padding:
                  EdgeInsetsDirectional.only(start: 7.0, end: 7.0, top: 7.0),
              child: filterList != null
                  ? ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsetsDirectional.only(top: 10.0),
                      itemCount: filterList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            children: [
                              Container(
                                  width: deviceWidth,
                                  child: Card(
                                      elevation: 0,
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Price Range',
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .lightBlack,
                                                    fontWeight:
                                                        FontWeight.normal),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          )))),
                              RangeSlider(
                                values: _currentRangeValues!,
                                min: double.parse(minPrice),
                                max: double.parse(maxPrice),
                                divisions: 10,
                                labels: RangeLabels(
                                  _currentRangeValues!.start.round().toString(),
                                  _currentRangeValues!.end.round().toString(),
                                ),
                                onChanged: (RangeValues values) {
                                  setState(() {
                                    _currentRangeValues = values;
                                  });
                                },
                              ),
                            ],
                          );
                        } else {
                          index = index - 1;
                          attsubList =
                              filterList[index]['attribute_values'].split(',');

                          attListId = filterList[index]['attribute_values_id']
                              .split(',');

                          List<Widget?> chips = [];
                          List<String> att =
                              filterList[index]['attribute_values']!.split(',');

                          List<String> attSType =
                              filterList[index]['swatche_type'].split(',');

                          List<String> attSValue =
                              filterList[index]['swatche_value'].split(',');

                          for (int i = 0; i < att.length; i++) {
                            Widget itemLabel;
                            if (attSType[i] == "1") {
                              String clr = (attSValue[i].substring(1));

                              String color = "0xff" + clr;

                              itemLabel = Container(
                                width: 25,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(int.parse(color))),
                              );
                            } else if (attSType[i] == "2") {
                              itemLabel = ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(attSValue[i],
                                      width: 80,
                                      height: 80,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              erroWidget(80)));
                            } else {
                              itemLabel = Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(att[i],
                                    style: TextStyle(
                                        color:
                                            selectedId.contains(attListId![i])
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .white
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .fontColor)),
                              );
                            }

                            choiceChip = ChoiceChip(
                              selected: selectedId.contains(attListId![i]),
                              label: itemLabel,
                              labelPadding: EdgeInsets.all(0),
                              selectedColor: colors.primary,
                              backgroundColor:
                                  Theme.of(context).colorScheme.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    attSType[i] == "1" ? 100 : 10),
                                side: BorderSide(
                                    color: selectedId.contains(attListId![i])
                                        ? colors.primary
                                        : colors.black12,
                                    width: 1.5),
                              ),
                              onSelected: (bool selected) {
                                attListId = filterList[index]
                                        ['attribute_values_id']
                                    .split(',');

                                if (mounted)
                                  setState(() {
                                    if (selected == true) {
                                      selectedId.add(attListId![i]);
                                    } else {
                                      selectedId.remove(attListId![i]);
                                    }
                                  });
                              },
                            );

                            chips.add(choiceChip);
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: deviceWidth,
                                child: Card(
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: new Text(
                                      filterList[index]['name'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor,
                                              fontWeight: FontWeight.normal),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              ),
                              chips.length > 0
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: new Wrap(
                                        children:
                                            chips.map<Widget>((Widget? chip) {
                                          return Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: chip,
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  : Container()

                              /*    (filter == filterList[index]["name"])
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                      NeverScrollableScrollPhysics(),
                                  itemCount: attListId!.length,
                                  itemBuilder: (context, i) {

                                    */ /*       return CheckboxListTile(
                                  dense: true,
                                  title: Text(attsubList![i],
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                              color: Theme.of(context).colorScheme.lightBlack,
                                              fontWeight:
                                                  FontWeight.normal)),
                                  value: selectedId
                                      .contains(attListId![i]),
                                  activeColor: colors.primary,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  onChanged: (bool? val) {
                                    if (mounted)
                                      setState(() {
                                        if (val == true) {
                                          selectedId.add(attListId![i]);
                                        } else {
                                          selectedId
                                              .remove(attListId![i]);
                                        }
                                      });
                                  },
                                );*/ /*
                                  })
                              : Container()*/
                            ],
                          );
                        }
                      })
                  : Container(),
            )),
            Container(
              color: Theme.of(context).colorScheme.white,
              child: SimBtn(
                  size: 1.0,
                  title: getTranslated(context, 'APPLY'),
                  onBtnSelected: () {
                    if (selectedId != null) {
                      selId = selectedId.join(',');
                    }

                    if (mounted)
                      setState(() {
                        _isLoading = true;
                        total = 0;
                        offset = 0;
                        productList.clear();
                      });
                   // if(widget.buyOneOffer== false) {
                      getProduct("0");
                    // }else{
                    //   getBuyOne();
                    // }
                    Navigator.pop(context, 'Product Filter');
                  }),
            )
          ]);
        });
      },
    );
  }
}
