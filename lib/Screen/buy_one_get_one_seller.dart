import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/widget.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/HomeProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/BuyOneOfferProductList.dart';
import 'package:eshop_multivendor/Screen/Cart.dart';
import 'package:eshop_multivendor/Screen/HomePage.dart';
import 'package:eshop_multivendor/Screen/ProductList.dart';
import 'package:eshop_multivendor/Screen/SellerRating.dart';
import 'package:eshop_multivendor/Screen/Seller_Details.dart';
import 'package:eshop_multivendor/Screen/SubCategory.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'my_favorite_seller/add_remove_favrite_seller.dart';

class BuyOneGetOneSeller extends StatefulWidget {
  final sellerData;
  final search;
  final extraData;
  final coverImage;
  var sellerID,
      sellerName,
      sellerImage,
      sellerRating,
      storeDesc,
      sellerStoreName,
      subCatId;

  BuyOneGetOneSeller({Key? key,
    this.sellerID,
    this.sellerName,
    this.sellerImage,
    this.sellerRating,
    this.storeDesc,
    this.sellerStoreName,
    this.subCatId,
    this.sellerData, this.search, this.extraData, this.coverImage}) : super(key: key);

  @override
  State<BuyOneGetOneSeller> createState() => _BuyOneGetOneSellerState();
}

class _BuyOneGetOneSellerState extends State<BuyOneGetOneSeller> {
  List<Product> sellerLists = [];


  void getBuyOneSeller() {
    String pin = context.read<UserProvider>().curPincode;
    var loc = Provider.of<LocationProvider>(context, listen: false);
    Map parameter = {};
    // if (widget.getByLocation) {
    //   parameter = {"lat": "${loc.lat}", "lang": "${loc.lng}"};
    // } else if (widget.buyOneOffer){
    //
    //   parameter = {"buy_one" : "1"};
    // } else {
    //   parameter = {
    //     "lat": "${loc.lat}",
    //     "lang": "${loc.lng}",
    //     "cat_id": "${widget.catId}"
    //
    //   };
    // }
    apiBaseHelper.postAPICall(getBuyOneApi, parameter).then((getdata) {
      print(parameter);
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        sellerLists =
            (data as List).map((data) => new Product.fromSeller(data)).toList();

        setState(() {});
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSellerLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSellerLoading(false);
    });
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    getBuyOneSeller();
  }
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var checkOut = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: getAppBar("Buy One Get One Offer", context),
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
      body: sellerLists.length > 0 ? ListView.builder(
        itemCount: sellerLists.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: GestureDetector(
              onTap: () async {
              //  if (sellerLists[index].open_close_status == "1") {
              //   Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //           builder: (context) => BuyOneOfferProductList(
              //             search: false,
              //           //  sellerID: widget.sellerId,
              //           //  subCatId: subCatData[index]["id"],
              //             sellerData: sellerLists[index],
              //           )));
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SubCategory(
                            title: sellerLists[index].store_name.toString(),
                            sellerId: sellerLists[index].seller_id.toString(),
                            sellerData: sellerLists[index],
                            //catId: widget.catId,
                          //  buyOneOffer: widget.buyOneOffer,
                           // weekendOffer: false,
                          )));
                // } else {
                //   showToast("Shop Closed");
                // }
                // if (widget.subId == null) {
                //   await Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => ProductList(
                //           name: widget.catName,
                //           id: widget.catId,
                //           tag: false,
                //           fromSeller: false,
                //         ),
                //       ));
                // } else {
                //   await Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => SubCategory(
                //           title: widget.catName,
                //         ),
                //       ));
                // }

                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => SellerProfile(
                //               sellerStoreName:
                //               sellerLists[index].store_name ?? "",
                //               sellerRating:
                //               sellerLists[index].seller_rating ?? "",
                //               sellerImage:
                //               sellerLists[index].seller_profile ?? "",
                //               sellerName: sellerLists[index].seller_name ?? "",
                //               sellerID: sellerLists[index].seller_id,
                //               storeDesc: sellerLists[index].store_description,
                //             )));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      // decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(10),
                      //     image: DecorationImage(
                      //         fit: BoxFit.cover,
                      //         // opacity: .05,
                      //         image: NetworkImage(
                      //             sellerList[index].seller_profile!))
                      //             ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            height: 75,
                            width: 80,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: FadeInImage(
                                fadeInDuration: Duration(milliseconds: 150),
                                image: CachedNetworkImageProvider(
                                  sellerLists[index].seller_profile!,
                                ),
                                fit: BoxFit.cover,
                                imageErrorBuilder:
                                    (context, error, stackTrace) =>
                                    erroWidget(50),
                                placeholder: placeHolder(50),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                ListTile(
                                  dense: true,
                                  title:
                                  Text("${sellerLists[index].store_name!}"),
                                  subtitle: Text(
                                    "${sellerLists[index].store_description!}",
                                    maxLines: 2,
                                  ),
                                  trailing: sellerLists[index]
                                      .open_close_status ==
                                      "1"
                                      ? Text(
                                    "Open",
                                    style: TextStyle(color: Colors.green),
                                  )
                                      : Text(
                                    "Close",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                Divider(
                                  height: 0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      FittedBox(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.star_rounded,
                                              color: Colors.amber,
                                              size: 15,
                                            ),
                                            Text(
                                              "${sellerLists[index].seller_rating!}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption!
                                                  .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // sellerLists[index].estimated_time != ""
                                      //     ? FittedBox(
                                      //         child: Container(
                                      //             child: Center(
                                      //           child: Padding(
                                      //             padding: const EdgeInsets
                                      //                     .symmetric(
                                      //                 horizontal: 5,
                                      //                 vertical: 2),
                                      //             child: Text(
                                      //               "${sellerLists[index].estimated_time}",
                                      //               style:
                                      //                   TextStyle(fontSize: 14),
                                      //             ),
                                      //           ),
                                      //         )),
                                      //       )
                                      //     : Container(),
                                      sellerLists[index].estimated_time != ""
                                          ? FittedBox(
                                        child: Container(
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                  vertical: 1),
                                              child: Text(
                                                "${sellerLists[index].estimated_time}",
                                                style:
                                                TextStyle(fontSize: 14),
                                              ),
                                            )),
                                      )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ) : Container(child: Center(child: Text("NO SELLER FOUND"),),),

      // Material(
      //   child: Column(
      //     children: [
      //       widget.search
      //           ? Container()
      //           : Stack(
      //         alignment: Alignment.centerRight,
      //         children: [
      //           Container(
      //             height: 128,
      //             width: width * 1,
      //             decoration: BoxDecoration(
      //                 image: DecorationImage(
      //                     image: NetworkImage(
      //                         widget.sellerData!.sellerProfile),
      //                     fit: BoxFit.fill)),
      //             child: Container(
      //               height: height * 0.35,
      //               width: width * 0.35,
      //               child: Column(
      //                 mainAxisAlignment: MainAxisAlignment.end,
      //                 children: [
      //                   Container(
      //                     color: Colors.black.withOpacity(.5),
      //                     child: Column(
      //                       children: [
      //                         ListTile(
      //                           leading: CircleAvatar(
      //                             backgroundImage: NetworkImage(
      //                                 widget.sellerData!.sellerProfile),
      //                           ),
      //                           title: Text(
      //                             "${widget.sellerData.storeName!}"
      //                                 .toUpperCase(),
      //                             style: TextStyle(color: Colors.white),
      //                           ),
      //                           subtitle: Text(
      //                             "${widget.sellerData.storeDescription}",
      //                             maxLines: 2,
      //                             style: TextStyle(
      //                                 color: Colors.white,
      //                                 fontWeight: FontWeight.bold),
      //                           ),
      //                         ),
      //                         Padding(
      //                           padding: const EdgeInsets.fromLTRB(
      //                               15, 0, 15, 5),
      //                           child: Row(
      //                             mainAxisAlignment:
      //                             MainAxisAlignment.spaceBetween,
      //                             children: [
      //                               InkWell(
      //                                 onTap: () {
      //                                   Navigator.push(
      //                                       context,
      //                                       MaterialPageRoute(
      //                                           builder: (context) =>
      //                                               SellerRatingsPage(
      //                                                 sellerId:
      //                                                 widget.sellerID,
      //                                               )));
      //                                 },
      //                                 child: Column(
      //                                   children: [
      //                                     Icon(
      //                                       Icons.star_rounded,
      //                                       color: colors.primary,
      //                                     ),
      //                                     Text(
      //                                       "${widget.sellerData.sellerRating}",
      //                                       style: TextStyle(
      //                                         fontSize: 13,
      //                                         color: Colors.white,
      //                                         fontWeight: FontWeight.bold,
      //                                       ),
      //                                     )
      //                                   ],
      //                                 ),
      //                               ),
      //                               widget.sellerData.estimatedTime != ""
      //                                   ? Column(
      //                                 children: [
      //                                   Text(
      //                                     "Delivery Time",
      //                                     style: TextStyle(
      //                                       color: colors.primary,
      //                                       fontSize: 13,
      //                                       fontWeight:
      //                                       FontWeight.bold,
      //                                     ),
      //                                   ),
      //                                   Text(
      //                                     "${widget.sellerData.estimatedTime}",
      //                                     style: TextStyle(
      //                                       fontSize: 13,
      //                                       color: Colors.white,
      //                                       fontWeight:
      //                                       FontWeight.bold,
      //                                     ),
      //                                   ),
      //                                 ],
      //                               )
      //                                   : Container(),
      //                               widget.sellerData.foodPerson != ""
      //                                   ? Column(
      //                                 children: [
      //                                   Text(
      //                                     "₹/Person",
      //                                     style: TextStyle(
      //                                       fontSize: 13,
      //                                       color: colors.primary,
      //                                       fontWeight:
      //                                       FontWeight.bold,
      //                                     ),
      //                                   ),
      //                                   Text(
      //                                     "${widget.sellerData.foodPerson}",
      //                                     style: TextStyle(
      //                                       color: Colors.white,
      //                                       fontSize: 13,
      //                                       fontWeight:
      //                                       FontWeight.bold,
      //                                     ),
      //                                   ),
      //                                 ],
      //                               )
      //                                   : Container(),
      //                             ],
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ),
      //          /* Padding(
      //             padding: const EdgeInsets.only(right: 25),
      //             child: CircleAvatar(
      //               backgroundColor: Colors.white,
      //               child: AddRemveSeller(sellerID: widget.sellerID),
      //             ),
      //           ),*/
      //           // SizedBox(height: MediaQuery.of(context).size.height*0.2),
      //         ],
      //       ),
      //       widget.search
      //           ? Stack(
      //         alignment: Alignment.centerRight,
      //         children: [
      //           Container(
      //             height: 200,
      //             decoration: BoxDecoration(
      //                 image: DecorationImage(
      //                     fit: BoxFit.cover,
      //                     image: NetworkImage(
      //                         widget.sellerImage.toString()))),
      //             child: Column(
      //               mainAxisAlignment: MainAxisAlignment.end,
      //               children: [
      //                 Container(
      //                   color: Colors.black.withOpacity(.6),
      //                   child: Column(
      //                     children: [
      //                       ListTile(
      //                         leading: CircleAvatar(
      //                           backgroundImage: NetworkImage(
      //                               widget.sellerImage.toString()),
      //                         ),
      //                         title: Text(
      //                           "${widget.sellerStoreName}".toUpperCase(),
      //                           style: TextStyle(color: Colors.white),
      //                         ),
      //                         subtitle: Text(
      //                           "${widget.storeDesc}",
      //                           style: TextStyle(color: Colors.white),
      //                           maxLines: 2,
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ],
      //       )
      //           : Container(),
      //       /*Card(
      //         shape:
      //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      //         child: Column(
      //           children: [
      //             ListTile(
      //               leading: CircleAvatar(
      //                 backgroundImage: NetworkImage(widget.sellerData!.sellerProfile),
      //               ),
      //               title: Text("${widget.sellerData.storeName!}".toUpperCase()),
      //               subtitle: Text(
      //                 "${widget.sellerData.storeDescription}",
      //                 maxLines: 2,
      //               ),
      //             ),
      //             // ListTile(title: Text("Address"), subtitle: Text("${widget.sellerData.address}"),),
      //             Padding(
      //               padding: const EdgeInsets.all(8.0),
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                 children: [
      //                   Column(
      //                     children: [
      //                       Icon(
      //                         Icons.star_rounded,
      //                         color: colors.primary,
      //                       ),
      //                       Text("${widget.sellerData.sellerRating}")
      //                     ],
      //                   ),
      //                   widget.sellerData.estimatedTime !=""?
      //                   Column(
      //                     children: [
      //                       Text("Delivery Time"),
      //                       Text(
      //                         "${widget.sellerData.estimatedTime}",
      //                         style: TextStyle(color: Colors.green),
      //                       ),
      //                     ],
      //                   ):Container(),
      //                   widget.sellerData.foodPerson !=""?
      //                   Column(
      //                     children: [
      //                       Text("₹/Person"),
      //                       Text("${widget.sellerData.foodPerson}"),
      //                     ],
      //                   ):Container()
      //                 ],),
      //             ),
      //             SizedBox(height: 10,)
      //
      //           ],
      //         ),
      //       ),*/
      //       // Expanded(
      //       //   child: ProductList(
      //       //     weeklyOffer: true,
      //       //     fromSeller: true,
      //       //     buyOneOffer: false,
      //       //     name: "",
      //       //     id: widget.sellerID,
      //       //     // subCatId: widget.subCatId,
      //       //     tag: false,
      //       //   ),
      //       // ),
      //     ],
      //   ),
      // ),
    );
  }
}
