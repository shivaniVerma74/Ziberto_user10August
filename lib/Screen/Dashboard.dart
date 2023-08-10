import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/PushNotificationService.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Add_Address.dart';
import 'package:eshop_multivendor/Screen/Favorite.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:eshop_multivendor/Screen/MyProfile.dart';
import 'package:eshop_multivendor/Screen/Product_Detail.dart';
import 'package:eshop_multivendor/Screen/search_location.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'All_Category.dart';
import 'Cart.dart';
import 'HomePage.dart';
import 'NotificationLIst.dart';
import 'Sale.dart';
import 'Search.dart';

class Dashboard extends StatefulWidget {
  int? from;
  Dashboard({Key? key, this.from}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Dashboard> with TickerProviderStateMixin {
  var _selBottom = 0;
  late TabController _tabController;
  var currentAddress = TextEditingController();
  var pinController = TextEditingController();
  Future<void> getCurrentLoc() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var loc = Provider.of<LocationProvider>(context, listen: false);
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(mylatitude, latitude.toString());
    await preferences.setString(mylongitude, longitude.toString());
    List<Placemark> placemark = await placemarkFromCoordinates(
        double.parse(latitude!), double.parse(longitude!),
        localeIdentifier: "en");

    pinController.text = placemark[0].postalCode!;
    if (mounted) {
      setState(() {
        pinController.text = placemark[0].postalCode!;
        currentAddress.text =
        "${placemark[0].street}, ${placemark[0].subLocality} , ${placemark[0].locality}";
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
        loc.lng = position.longitude.toString();
        loc.lat = position.latitude.toString();
      });
    }
  }
  bool _isNetworkAvail = true;
  Logger _log = Logger();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
    getCurrentLoc();
    setBottom();
    initDynamicLinks();
    _tabController = TabController(
      initialIndex: 0,
      length: 5,
      vsync: this,
    );

    final pushNotificationService = PushNotificationService(
        context: context, tabController: _tabController);
    pushNotificationService.initialise();

    _tabController.addListener(
      () {
        Future.delayed(Duration(seconds: 0)).then(
          (value) {
            if (_tabController.index == 3) {
              if (CUR_USERID == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                );
                _tabController.animateTo(0);
              }
            }
          },
        );

        setState(
          () {
            _selBottom = _tabController.index;
          },
        );
      },
    );
    getCurrentLoc();
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      if (deepLink != null) {
        if (deepLink.queryParameters.length > 0) {
          int index = int.parse(deepLink.queryParameters['index']!);

          int secPos = int.parse(deepLink.queryParameters['secPos']!);

          String? id = deepLink.queryParameters['id'];

          String? list = deepLink.queryParameters['list'];

          getProduct(id!, index, secPos, list == "true" ? true : false);
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      if (deepLink.queryParameters.length > 0) {
        int index = int.parse(deepLink.queryParameters['index']!);

        int secPos = int.parse(deepLink.queryParameters['secPos']!);

        String? id = deepLink.queryParameters['id'];

        // String list = deepLink.queryParameters['list'];

        getProduct(id!, index, secPos, true);
      }
    }
  }

  Future<void> getProduct(String id, int index, int secPos, bool list) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          ID: id,
        };

        // if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
        Response response =
            await post(getProductApi, headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          List<Product> items = [];

          items =
              (data as List).map((data) => new Product.fromJson(data)).toList();

          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProductDetail(
                    index: list ? int.parse(id) : index,
                    model: list
                        ? items[0]
                        : sectionList[secPos].productList![index],
                    secPos: secPos,
                    list: list,
                  )));
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      {
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_tabController.index != 0) {
          _tabController.animateTo(0);
          return false;
        }
        return true;
      },
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.lightWhite,
          // appBar: _getAppBar(),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              HomePage(),
              AllCategory(),
              Sale(),
              Cart(
                fromBottom: true,
              ),
              MyProfile(),
            ],
          ),
          //fragments[_selBottom],
          bottomNavigationBar: _getBottomBar(),
          // bottomNavigationBar: _getBottomNavigator(),
        ),
      ),
    );
  }

   _getAppBar() {
    String? title;
    if (_selBottom == 1)
      title = getTranslated(context, 'CATEGORY');
    else if (_selBottom == 0)
      title = getTranslated(context, 'RES_BY_SELLER');
    else if (_selBottom == 3)
      title = getTranslated(context, 'MYBAG');
    else if (_selBottom == 4) title = getTranslated(context, 'PROFILE');

    return AppBar(
      toolbarHeight:_selBottom == 2? 0:50,
      centerTitle: _selBottom == 2 ? true : false,
      title: _selBottom == 2
          // ? Image.asset(
          //     'assets/images/titleicon.png',
          ? SizedBox(
            child: _deliverLocation(),
          )
          //height: 40,

          //   width: 200,
          // height: MediaQuery.of(context).size.height * 0.11,

          // color: colors.primary,
          // width: 45,
          // )
          : Text(
              title!,
              style: TextStyle(
                  color: colors.primary, fontWeight: FontWeight.normal , fontSize: 12),
            ),

      // leading: _selBottom == 0
      //     ?
      // InkWell(
      //         child: Center(
      //             child: SvgPicture.asset(
      //           imagePath + "search.svg",
      //           height: 20,
      //           color: colors.primary,
      //         )),
      //         onTap: () {
      //           Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context) => Search(),
      //               ));
      //         },
      //       )
      //     : null,
      // iconTheme: new IconThemeData(color: colors.primary),
      // centerTitle:_curSelected == 0? false:true,
      actions: <Widget>[
        _selBottom == 2?
             IconButton(onPressed: (){
               Navigator.push(
                   context, MaterialPageRoute(builder: (context) => Search()));
             }, icon: Icon(Icons.search , color: colors.primary,)):Container(),
        _selBottom == 2 || _selBottom == 4
            ? Container()
            : IconButton(
                icon: SvgPicture.asset(
                  imagePath + "search.svg",
                  height: 20,
                  color: colors.primary,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Search(),
                      ));
                }),
        _selBottom == 4
            ? Container()
            : IconButton(
                icon: SvgPicture.asset(
                  imagePath + "desel_notification.svg",
                  color: colors.primary,
                ),
                onPressed: () {
                  CUR_USERID != null
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationList(),
                          ))
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ));
                },
              ),
        _selBottom == 4
            ? Container()
            : IconButton(
                padding: EdgeInsets.all(0),
                icon: SvgPicture.asset(
                  imagePath + "desel_fav.svg",
                  color: colors.primary,
                ),
                onPressed: () {
                  CUR_USERID != null
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Favorite(),
                          ))
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ));
                },
              ),
      ],
      backgroundColor: Theme.of(context).colorScheme.white,
    );
  }

  _deliverLocation() {
    var loc = Provider.of<LocationProvider>(context, listen: false);
    String curpin = context.read<UserProvider>().curPincode;
    return GestureDetector(
      child: Row(
        children: [
          Icon(
            Icons.location_pin,
            size: 18,
            color: colors.primary,
          ),
          Selector<UserProvider, String>(
            builder: (context, data, child) {
              return Expanded(
                child: Text(
                  currentAddress.text.isEmpty
                      ? getTranslated(context, 'SELOC')!
                      : getTranslated(context, 'DELIVERTO')! +
                          currentAddress.text,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                  // style:
                  //     TextStyle(color: Theme.of(context).colorScheme.fontColor),
                ),
              );
            },
            selector: (_, provider) => provider.curPincode,
          ),
          // Icon(
          //   Icons.keyboard_arrow_right,
          //   size: 15,
          // )
        ],
      ),
      // child: Card(
      //   elevation: 0,
      //   // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      //   child: ListTile(
      //     dense: true,
      //     // minLeadingWidth: 10,
      //     leading: Icon(
      //       Icons.location_pin,
      //     ),
      // title: Selector<UserProvider, String>(
      //   builder: (context, data, child) {
      //     return Text(
      //       data != ''
      //           ? getTranslated(context, 'SELOC')!
      //           : getTranslated(context, 'DELIVERTO')! +
      //               currentAddress.text,
      //       style:
      //           TextStyle(color: Theme.of(context).colorScheme.fontColor),
      //     );
      //   },
      //   selector: (_, provider) => provider.curPincode,
      // ),
      //   trailing: Icon(Icons.keyboard_arrow_right),
      // ),
      // ),
      // onTap: _pincodeCheck,
      onTap: () async {
        List<dynamic> data = await Navigator.push(context,
            MaterialPageRoute(builder: (context) => SearchLocationPage()));
        print(data);
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.setString(mylatitude, latitude.toString());
        await preferences.setString(mylongitude, longitude.toString());
        if (data.isNotEmpty) {

          List<Placemark> place = data[0];
          setState(() {
            pinController.text = place[0].postalCode.toString();
            curpin = place[0].postalCode.toString();
            currentAddress.text =
                "${place[0].street}, ${place[0].subLocality} , ${place[0].locality}";
            _log.d("${place[0]}");
            latitude = data[1].toString();
            longitude = data[2].toString();
            loc.lat = data[1];
            loc.lng = data[2];
            print(latitude);
            // sellerList.clear();
            print(longitude);
            // getSeller();
          });
          setState(() {

          });
        }
      },
    );
  }

  Widget _getBottomBar() {
    return Material(
        color: Theme.of(context).colorScheme.white,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.white,
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).colorScheme.black26, blurRadius: 10)
            ],
          ),
          child: TabBar(
            onTap: (_) {
              if (_tabController.index == 3) {
                if (CUR_USERID == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ),
                  );
                  _tabController.animateTo(0);
                }
              }
            },
            controller: _tabController,
            tabs: [
              Tab(
                icon: _selBottom == 0
                    ? SvgPicture.asset(
                        imagePath + "sel_home.svg",
                        color: colors.primary,
                      )
                    : SvgPicture.asset(
                        imagePath + "desel_home.svg",
                        color: colors.primary,
                      ),
                text:
                    _selBottom == 0 ? getTranslated(context, 'HOME_LBL') : null,
              ),
              Tab(
                icon: _selBottom == 1
                    ? SvgPicture.asset(
                        imagePath + "category01.svg",
                        color: colors.primary,
                      )
                    : SvgPicture.asset(
                        imagePath + "category.svg",
                        color: colors.primary,
                      ),
                text:
                    _selBottom == 1 ? getTranslated(context, 'category') : null,
              ),
              Tab(
                icon: _selBottom == 2
                    ? SvgPicture.asset(
                        imagePath + "sale02.svg",
                        color: colors.primary,
                      )
                    : SvgPicture.asset(
                        imagePath + "sale.svg",
                        color: colors.primary,
                      ),
                text: _selBottom == 2 ? getTranslated(context, 'SALE') : null,
              ),
              Tab(
                icon: Selector<UserProvider, String>(
                  builder: (context, data, child) {
                    return Stack(
                      children: [
                        Center(
                          child: _selBottom == 3
                              ? SvgPicture.asset(
                                  imagePath + "cart01.svg",
                                  color: colors.primary,
                                )
                              : SvgPicture.asset(
                                  imagePath + "cart.svg",
                                  color: colors.primary,
                                ),
                        ),
                        (data != null && data.isNotEmpty && data != "0")
                            ? new Positioned.directional(
                                bottom: _selBottom == 3 ? 6 : 20,
                                textDirection: Directionality.of(context),
                                end: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colors.primary),
                                  child: new Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(3),
                                      child: new Text(
                                        data,
                                        style: TextStyle(
                                            fontSize: 7,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .white),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container()
                      ],
                    );
                  },
                  selector: (_, homeProvider) => homeProvider.curCartCount,
                ),
                text: _selBottom == 3 ? getTranslated(context, 'CART') : null,
              ),
              Tab(
                icon: _selBottom == 4
                    ? SvgPicture.asset(
                        imagePath + "profile01.svg",
                        color: colors.primary,
                      )
                    : SvgPicture.asset(
                        imagePath + "profile.svg",
                        color: colors.primary,
                      ),
                text:
                    _selBottom == 4 ? getTranslated(context, 'ACCOUNT') : null,
              ),
            ],
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: colors.primary, width: 5.0),
              insets: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 70.0),
            ),
            labelStyle: TextStyle(fontSize: 9),
            labelColor: colors.primary,
          ),
        ));
  }

  Widget _getBottomNavigator() {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: CurvedNavigationBar(
        index: 2,
        height: 50,
        backgroundColor: Colors.transparent,
        items: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/bowl6.png',
                  height: 25.0,
                ),
                Text("FOOD" , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_offer_outlined, size: 25),
                Text("OFFERS" , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/vizzve_bottom logo.png',
                  height: 20.0,
                ),
                Text("Ziberto" , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart, size: 25),
                Text("CART" , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 25),
                Text("ACCOUNT" , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),)
              ],
            ),
          ),
        ],
        onTap: (index) {
          _tabController.animateTo(index);
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  setBottom() {
    if (_selBottom != null) {
      _selBottom = widget.from ?? 2;
    }
    setState(() {});
  }
}
