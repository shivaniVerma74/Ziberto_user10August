import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/widget.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Model/WeekendSellerModel.dart';
import 'package:eshop_multivendor/Provider/HomeProvider.dart';
import 'package:eshop_multivendor/Screen/HomePage.dart';
import 'package:eshop_multivendor/Screen/Seller_Details.dart';
import 'package:eshop_multivendor/Screen/SubCategory.dart';
import 'package:eshop_multivendor/Screen/buy_one_get_one_seller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../Helper/String.dart';

class WeeklyOfferSellerList extends StatefulWidget {
  final catId;
  final weekName;

  const WeeklyOfferSellerList({Key? key,this.catId, this.weekName}) : super(key: key);

  @override
  State<WeeklyOfferSellerList> createState() => _WeeklyOfferSellerListState();
}

class _WeeklyOfferSellerListState extends State<WeeklyOfferSellerList> {
  List<Product> sellerLists = [];
  @override
  void initState() {
    getWeeklyOfferSeller();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar("${widget.weekName} Offer", context),
        body: sellerLists.length == 0 ? Container(child: Center(child: Text("NO SELLER FOUND"),),)
       : ListView.builder(
          itemCount: sellerLists.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: GestureDetector(
                onTap: () async {
                  if (sellerLists[index].open_close_status == "1") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubCategory(
                              title: sellerLists[index].store_name.toString(),
                              sellerId: sellerLists[index].seller_id.toString(),
                              sellerData: sellerLists[index],
                              catId: widget.catId,
                              buyOneOffer: false,
                              weekendOffer: true,
                            )));
                  } else {
                    showToast("Shop Closed");
                  }
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
        )
    );

        // FutureBuilder(
        //     future: getWeeklyOfferSeller(),
        //     builder: (BuildContext context, AsyncSnapshot snapshot) {
        //      // WeekendSellerModel? weekItem = snapshot.data;
        //       if (snapshot.hasData) {
        //         return weekItem.error == false ? ListView.builder(
        //           itemCount: weekItem.date!.data!.length,
        //           itemBuilder: (context, index) {
        //             return weekItem.error == false
        //                 ? Padding(
        //               padding:
        //                   EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        //               child: GestureDetector(
        //                 onTap: () async {
        //                   if (weekItem.date!.data![index].openCloseStatus ==
        //                       "1") {
        //                     Navigator.push(
        //                         context,
        //                         MaterialPageRoute(
        //                             builder: (context) => SubCategory(
        //                               title: weekItem.date!.data![index].storeDescription.toString(),
        //                               sellerId: weekItem.date!.data![index].sellerId,
        //                               sellerData: weekItem.date!.data![index].toString(),
        //                               catId: widget.catId,
        //                               buyOneOffer: false,
        //                               weekendOffer: true,
        //                             )));
        //                     print(weekItem.date!.data![index].toString());
        //                     // Navigator.push(
        //                     //     context,
        //                     //     MaterialPageRoute(
        //                     //         builder: (context) => WeeklyOfferProductList(
        //                     //               search: false,
        //                     //           sellerID: weekItem.date!.data![index].sellerId,
        //                     //           // subCatId: subCatData[index]["id"],
        //                     //           sellerData: weekItem.date!.data![index],
        //                     //             )));
        //                   } else {
        //                     showToast("Shop Closed");
        //                   }
        //                 },
        //                 child: Column(
        //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
        //                   mainAxisSize: MainAxisSize.min,
        //                   crossAxisAlignment: CrossAxisAlignment.start,
        //                   children: <Widget>[
        //                     Card(
        //                       elevation: 2,
        //                       shape: RoundedRectangleBorder(
        //                           borderRadius: BorderRadius.circular(10)),
        //                       child: Container(
        //                         // decoration: BoxDecoration(
        //                         //     borderRadius: BorderRadius.circular(10),
        //                         //     image: DecorationImage(
        //                         //         fit: BoxFit.cover,
        //                         //         // opacity: .05,
        //                         //         image: NetworkImage(
        //                         //             sellerList[index].seller_profile!))
        //                         //             ),
        //                         child: Row(
        //                           children: [
        //                             SizedBox(
        //                               width: 5,
        //                             ),
        //                             Container(
        //                               height: 75,
        //                               width: 80,
        //                               child: ClipRRect(
        //                                 borderRadius: BorderRadius.circular(10),
        //                                 child: FadeInImage(
        //                                   fadeInDuration:
        //                                       Duration(milliseconds: 150),
        //                                   image: CachedNetworkImageProvider(
        //                                     "${weekItem.date!.data![index].sellerProfile}",
        //                                   ),
        //                                   fit: BoxFit.cover,
        //                                   imageErrorBuilder:
        //                                       (context, error, stackTrace) =>
        //                                           erroWidget(50),
        //                                   placeholder: placeHolder(50),
        //                                 ),
        //                               ),
        //                             ),
        //                             Expanded(
        //                               child: Column(
        //                                 children: [
        //                                   ListTile(
        //                                     dense: true,
        //                                     title: Text(
        //                                         "${weekItem.date!.data![index].storeName}"),
        //                                     subtitle: Text(
        //                                       "${weekItem.date!.data![index].storeDescription}",
        //                                       maxLines: 2,
        //                                     ),
        //                                     trailing: weekItem
        //                                                 .date!
        //                                                 .data![index]
        //                                                 .openCloseStatus ==
        //                                             "1"
        //                                         ? Text(
        //                                             "Open",
        //                                             style: TextStyle(
        //                                                 color: Colors.green),
        //                                           )
        //                                         : Text(
        //                                             "Close",
        //                                             style: TextStyle(
        //                                                 color: Colors.red),
        //                                           ),
        //                                   ),
        //                                   Divider(
        //                                     height: 0,
        //                                   ),
        //                                   Padding(
        //                                     padding: const EdgeInsets.all(8.0),
        //                                     child: Row(
        //                                       mainAxisAlignment:
        //                                           MainAxisAlignment
        //                                               .spaceBetween,
        //                                       children: [
        //                                         FittedBox(
        //                                           child: Row(
        //                                             children: [
        //                                               Icon(
        //                                                 Icons.star_rounded,
        //                                                 color: Colors.amber,
        //                                                 size: 15,
        //                                               ),
        //                                               Text(
        //                                                 "${weekItem.date!.data![index].sellerRating}",
        //                                                 style: Theme.of(context)
        //                                                     .textTheme
        //                                                     .caption!
        //                                                     .copyWith(
        //                                                         color: Theme.of(
        //                                                                 context)
        //                                                             .colorScheme
        //                                                             .fontColor,
        //                                                         fontWeight:
        //                                                             FontWeight
        //                                                                 .w600,
        //                                                         fontSize: 14),
        //                                               ),
        //                                             ],
        //                                           ),
        //                                         ),
        //                                         // weekItem.date!.data![index]
        //                                         //             .foodPerson !=
        //                                         //         ""
        //                                         //     ? FittedBox(
        //                                         //         child: Container(
        //                                         //             child: Padding(
        //                                         //           padding:
        //                                         //               const EdgeInsets
        //                                         //                       .symmetric(
        //                                         //                   horizontal: 5,
        //                                         //                   vertical: 1),
        //                                         //           child: Text(
        //                                         //             "${weekItem.date!.data![index].foodPerson}",
        //                                         //             style: TextStyle(
        //                                         //                 fontSize: 14),
        //                                         //           ),
        //                                         //         )),
        //                                         //       )
        //                                         //     : Container(),
        //                                         weekItem.date!.data![index]
        //                                             .estimatedTime != ""
        //                                             ?
        //                                         FittedBox(
        //                                           child: Container(
        //                                               child: Center(
        //                                                 child:
        //                                                 Padding(
        //                                                   padding: const EdgeInsets.symmetric(
        //                                                       horizontal:
        //                                                       5,
        //                                                       vertical:
        //                                                       2),
        //                                                   child:
        //                                                   Text(
        //                                                     "${weekItem.date!.data![index].estimatedTime}",
        //                                                     style:
        //                                                     TextStyle(fontSize: 14),
        //                                                   ),
        //                                                 ),
        //                                               )),
        //                                         )
        //                                             : Container(),
        //                                       ],
        //                                     ),
        //                                   ),
        //                                 ],
        //                               ),
        //                             )
        //                           ],
        //                         ),
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             )
        //                 : Center(child: Text("No Item Found"));
        //           },
        //         ) :
        //         Container(child: Center(child: Text("NO OFFERS"),),);
        //       } else if (snapshot.hasError) {
        //         return Icon(Icons.error_outline);
        //       } else if(snapshot.hasError){
        //         return Center(child: Text("No Offers available"));
        //
        //       }
        //       else {
        //         return Center(child: CircularProgressIndicator());
        //       }
        //     }));
  }

  Future<WeekendSellerModel?> getWeeklyOfferSeller() async {
   var parameter = {
   };

   apiBaseHelper.postAPICall(getWeeklySellerApi, parameter).then((getdata) {
     print(parameter);
     bool error = getdata["error"];
     String? msg = getdata["message"];
     if (!error) {
       var data = getdata["date"]["data"];
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
   }

