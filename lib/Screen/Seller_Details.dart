
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Cart.dart';
import 'package:eshop_multivendor/Screen/ProductList.dart';
import 'package:eshop_multivendor/Screen/SellerRating.dart';
import 'package:eshop_multivendor/Screen/my_favorite_seller/add_remove_favrite_seller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/src/provider.dart';

class SellerProfile extends StatefulWidget {
  var sellerID,
      sellerName,
      sellerImage,
      sellerRating,
      storeDesc,
      sellerStoreName,
      subCatId;
  final sellerData;
  final search;
  final extraData;
  final coverImage;
  final buyOneGetOne;

  SellerProfile(
      {Key? key,
      this.sellerID,
      this.sellerName,
      this.sellerImage,
      this.sellerRating,
      this.storeDesc,
      this.sellerStoreName,
      this.subCatId,
      this.sellerData,
      this.search,
      this.extraData,
      this.coverImage,
      this.buyOneGetOne})
      : super(key: key);

  @override
  State<SellerProfile> createState() => _SellerProfileState();
}

class _SellerProfileState extends State<SellerProfile>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  late TabController _tabController;
  bool _isNetworkAvail = true;
  bool isDescriptionVisible = false;
  bool favoriteSeller = false;

  @override
  void initState() {
    super.initState();
    print(widget.buyOneGetOne);
    //print("sellerProfile ${widget.sellerData.sellerProfile}");
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var checkOut = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: getAppBar("Store", context),
      bottomSheet: int.parse(checkOut.curCartCount) > 0
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(colors.primary)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Cart(fromBottom: false)));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Check out",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(width: 0,),
      body: Material(
        child: Column(
          children: [
            widget.search
                ? Container()
                : Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Container(
                        height: 200,
                        width: width * 1,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    widget.sellerData!.seller_profile
                                ),
                                fit: BoxFit.fill)),
                        child: Container(
                          height: height * 0.35,
                          width: width * 0.35,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                color: Colors.black.withOpacity(.5),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            widget.sellerData!.seller_profile),
                                      ),
                                      title: Text(
                                        "${widget.sellerData.store_name!}"
                                            .toUpperCase(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        "${widget.sellerData.store_description}",
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 0, 15, 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SellerRatingsPage(
                                                            sellerId:
                                                                widget.sellerID,
                                                          )));
                                            },
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.star_rounded,
                                                  color: colors.primary,
                                                ),
                                                Text(
                                                  "${widget.sellerData.seller_rating}",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          widget.sellerData.estimated_time != ""
                                              ? Column(
                                                  children: [
                                                    Text(
                                                      "Delivery Time",
                                                      style: TextStyle(
                                                        color: colors.primary,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${widget.sellerData.estimated_time}",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Container(),
                                          // widget.sellerData.food_person != ""
                                          //     ? Column(
                                          //         children: [
                                          //           Text(
                                          //             "₹/Person",
                                          //             style: TextStyle(
                                          //               fontSize: 13,
                                          //               color: colors.primary,
                                          //               fontWeight:
                                          //                   FontWeight.bold,
                                          //             ),
                                          //           ),
                                          //           Text(
                                          //             "${widget.sellerData.food_person}",
                                          //             style: TextStyle(
                                          //               color: Colors.white,
                                          //               fontSize: 13,
                                          //               fontWeight:
                                          //                   FontWeight.bold,
                                          //             ),
                                          //           ),
                                          //         ],
                                          //       )
                                          //     : Container(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      /*Padding(
                        padding: const EdgeInsets.only(right: 25),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: AddRemveSeller(sellerID: widget.sellerID),
                        ),
                      ),*/
                      // SizedBox(height: MediaQuery.of(context).size.height*0.2),
                    ],
                  ),
            widget.search
                ? Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    widget.sellerImage.toString()))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              color: Colors.black.withOpacity(.6),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          widget.sellerImage.toString()),
                                    ),
                                    title: Text(
                                      "${widget.sellerStoreName}".toUpperCase(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      "${widget.storeDesc}",
                                      style: TextStyle(color: Colors.white),
                                      maxLines: 2,
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.spaceBetween,
                                  //     children: [
                                  //       Column(
                                  //         children: [
                                  //           Icon(
                                  //             Icons.star_rounded,
                                  //             color: Colors.white,
                                  //           ),
                                  //           Text(
                                  //             "${widget.extraData["rating"]}",
                                  //             style: TextStyle(
                                  //                 color: colors.primary,
                                  //                 fontWeight: FontWeight.bold),
                                  //           )
                                  //         ],
                                  //       ),
                                  //       widget.extraData["estimated_time"] != ""
                                  //           ? Column(
                                  //               children: [
                                  //                 Text(
                                  //                   "Delivery Time",
                                  //                   style: TextStyle(
                                  //                       color: Colors.white),
                                  //                 ),
                                  //                 Text(
                                  //                   "${widget.extraData["estimated_time"]}",
                                  //                   style: TextStyle(
                                  //                       color: colors.primary,
                                  //                       fontWeight:
                                  //                           FontWeight.bold),
                                  //                 ),
                                  //               ],
                                  //             )
                                  //           : Container(),
                                  //       widget.extraData["food_person"] != ""
                                  //           ? Column(
                                  //               children: [
                                  //                 Text(
                                  //                   "₹/Person",
                                  //                   style: TextStyle(
                                  //                       color: Colors.white),
                                  //                 ),
                                  //                 Text(
                                  //                   "${widget.extraData["food_person"]}",
                                  //                   style: TextStyle(
                                  //                       color: colors.primary,
                                  //                       fontWeight:
                                  //                           FontWeight.bold),
                                  //                 ),
                                  //               ],
                                  //             )
                                  //           : Container(),
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                     /* Padding(
                        padding: const EdgeInsets.only(right: 25),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: AddRemveSeller(sellerID: widget.sellerID),
                        ),
                      ),*/
                    ],
                  )
                : Container(),
            // Card(
            //   shape:
            //   RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            //   child: Column(
            //     children: [
            //       ListTile(
            //         leading: CircleAvatar(
            //           backgroundImage: NetworkImage(widget.sellerData!.seller_profile),
            //         ),
            //         title: Text("${widget.sellerData.store_name!}".toUpperCase()),
            //         subtitle: Text(
            //           "${widget.sellerData.store_description}",
            //           maxLines: 2,
            //         ),
            //       ),
            //       // ListTile(title: Text("Address"), subtitle: Text("${widget.sellerData.address}"),),
            //       Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Column(
            //               children: [
            //                 Icon(
            //                   Icons.star_rounded,
            //                   color: colors.primary,
            //                 ),
            //                 Text("${widget.sellerData.seller_rating}")
            //               ],
            //             ),
            //             widget.sellerData.estimated_time !=""?
            //             Column(
            //               children: [
            //                 Text("Delivery Time"),
            //                 Text(
            //                   "${widget.sellerData.estimated_time}",
            //                   style: TextStyle(color: Colors.green),
            //                 ),
            //               ],
            //             ):Container(),
            //             widget.sellerData.food_person !=""?
            //             Column(
            //               children: [
            //                 Text("₹/Person"),
            //                 Text("${widget.sellerData.food_person}"),
            //               ],
            //             ):Container()
            //           ],),
            //       ),
            //       SizedBox(height: 10,)
            //
            //     ],
            //   ),
            // ),

            Expanded(
              child: ProductList(
                fromSeller: true,
                weeklyOffer: false,
                buyOneOffer: widget.buyOneGetOne,
                name: "",
                id: widget.sellerID,
                subCatId: widget.subCatId,
                tag: false,
                sellerId: widget.sellerID,
              ),
            ),
          ],
        ),
      ),
    );

    DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: getAppBar(getTranslated(context, 'SELLER_DETAILS')!, context),
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: getTranslated(context, 'DETAILS')!),
                  Tab(text: getTranslated(context, 'PRODUCTS')),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    detailsScreen(),
                    ProductList(
                      fromSeller: true,
                      name: "",
                      id: widget.sellerID,
                      tag: false,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        // bottomNavigationBar:
      ),
    );
  }

  // Future fetchSellerDetails() async {
  //   var parameter = {};
  //   final sellerData = await apiBaseHelper.postAPICall(getSellerApi, parameter);
  //   List<Seller> sellerDetails = [];
  //   bool error = sellerData["error"];
  //   String? msg = sellerData["message"];
  //   if (!error) {
  //     var data = sellerData["data"];
  //     sellerDetails =
  //         (data as List).map((data) => Seller.fromJson(data)).toList();
  //   } else {
  //     setSnackbar(msg!, context);
  //   }
  //
  //   return sellerDetails;
  // }

  Widget detailsScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: CircleAvatar(
              radius: 80,
              backgroundColor: colors.primary,
              backgroundImage: NetworkImage(widget.sellerImage!),
              // child: ClipRRect(
              //   borderRadius: BorderRadius.circular(40),
              //   child: FadeInImage(
              //     fadeInDuration: Duration(milliseconds: 150),
              //     image: NetworkImage(widget.sellerImage!),
              //
              //     fit: BoxFit.cover,
              //     placeholder: placeHolder(100),
              //     imageErrorBuilder: (context, error, stackTrace) =>
              //         erroWidget(100),
              //   ),
              // )
            ),
          ),
          getHeading(widget.sellerStoreName!),
          SizedBox(
            height: 5,
          ),
          Text(
            widget.sellerName!,
            style: TextStyle(
                color: Theme.of(context).colorScheme.lightBlack2, fontSize: 16),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          color: colors.primary),
                      child: Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      widget.sellerRating!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.0),
                            color: colors.primary),
                        child: Icon(
                          Icons.description,
                          color: Theme.of(context).colorScheme.white,
                          size: 30,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          isDescriptionVisible = !isDescriptionVisible;
                        });
                      },
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      getTranslated(context, 'DESCRIPTION')!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              color: colors.primary),
                          child: Icon(
                            Icons.list_alt,
                            color: Theme.of(context).colorScheme.white,
                            size: 30,
                          ),
                        ),
                        onTap: () => _tabController
                            .animateTo((_tabController.index + 1) % 2)),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      getTranslated(context, 'PRODUCTS')!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Visibility(
              visible: isDescriptionVisible,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width * 8,
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: colors.primary)),
                child: SingleChildScrollView(
                    child: Text(
                  (widget.storeDesc != "" || widget.storeDesc != null)
                      ? "${widget.storeDesc}"
                      : getTranslated(context, "NO_DESC")!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                )),
              ))
        ],
      ),
    );
    // return FutureBuilder(
    //     future: fetchSellerDetails(),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.done) {
    //         // If we got an error
    //         if (snapshot.hasError) {
    //           return Center(
    //             child: Text(
    //               '${snapshot.error} Occured',
    //               style: TextStyle(fontSize: 18),
    //             ),
    //           );
    //
    //           // if we got our data
    //         } else if (snapshot.hasData) {
    //           // Extracting data from snapshot object
    //           var data = snapshot.data;
    //           print("data is $data");
    //
    //           return Center(
    //             child: Text(
    //               'Hello',
    //               style: TextStyle(fontSize: 18),
    //             ),
    //           );
    //         }
    //       }
    //       return shimmer();
    //     });
  }

  Widget getHeading(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headline6!.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.fontColor,
          ),
    );
  }

  Widget getRatingBarIndicator(var ratingStar, var totalStars) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: RatingBarIndicator(
        rating: ratingStar,
        itemBuilder: (context, index) => const Icon(
          Icons.star_outlined,
          color: colors.yellow,
        ),
        itemCount: totalStars,
        itemSize: 20.0,
        direction: Axis.horizontal,
        unratedColor: Colors.transparent,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
