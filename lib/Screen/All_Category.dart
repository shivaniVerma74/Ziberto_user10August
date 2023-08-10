import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/widget.dart';
import 'package:eshop_multivendor/Provider/CategoryProvider.dart';
import 'package:eshop_multivendor/Provider/HomeProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/SellerList.dart';
import 'package:eshop_multivendor/Screen/SubCategory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../Helper/Session.dart';
import '../Model/Section_Model.dart';
import 'HomePage.dart';
import 'ProductList.dart';

class AllCategory extends StatefulWidget {
  @override
  State<AllCategory> createState() => _AllCategoryState();
}

var foodType = false;

class _AllCategoryState extends State<AllCategory> {
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  List<Product> sellerLists = [];
  List<Product> popularLists = [];
  List<Product> catLists = [];

  @override
  void initState() {
    super.initState();
    //getCat();
    getSeller();
  }

  // Future<void> getCat() async {
  //   await Future.delayed(Duration.zero);
  //   Map parameter = {
  //     CAT_FILTER: "false",
  //   };
  //   apiBaseHelper.postAPICall(getCatApi, parameter).then((getdata) {
  //     bool error = getdata["error"];
  //     String? msg = getdata["message"];
  //     if (!error) {
  //       var data = getdata["data"];
  //
  //       catList =
  //           (data as List).map((data) => new Product.fromCat(data)).toList();
  //
  //       if (getdata.containsKey("popular_categories")) {
  //         var data = getdata["popular_categories"];
  //         popularList =
  //             (data as List).map((data) => new Product.fromCat(data)).toList();
  //
  //         if (popularList.length > 0) {
  //           Product pop =
  //               new Product.popular("Popular", imagePath + "popular.svg");
  //           catList.insert(0, pop);
  //           context.read<CategoryProvider>().setSubList(popularList);
  //         }
  //       }
  //     } else {
  //       setSnackbar(msg!, context);
  //     }
  //
  //     context.read<HomeProvider>().setCatLoading(false);
  //   }, onError: (error) {
  //     setSnackbar(error.toString(), context);
  //     context.read<HomeProvider>().setCatLoading(false);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.white,
        title: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            getTranslated(context, 'CATEGORY')!,
            style: TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
          ),
        ),
      ),
        body:
        // _seller()
        Consumer<HomeProvider>(
          builder: (context, homeProvider, _) {
            if (homeProvider.catLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return Row(
              children: [
               /* Expanded(
                  flex: 1,
                  child: Container(
                    color: Theme.of(context).colorScheme.gray,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsetsDirectional.only(top: 10.0),
                      itemCount: catList.length,
                      itemBuilder: (context, index) {
                        return catItem(index, context);
                      },
                    ),
                  ),
                ),*/
                Expanded(
                  flex: 3,
                  child: catList.length > 0
                      ? Column(
                          children: [
                            Selector<CategoryProvider, int>(
                              builder: (context, data, child) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                    /*  Row(
                                        children: [
                                          Text(catList[data].name! + " "),
                                          Expanded(
                                            child: Divider(
                                              thickness: 2,
                                            ),
                                          ),
                                        ],
                                      ),*/
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Text(
                                          getTranslated(context, 'All')! +
                                              " " +
                                              catList[data].name! +
                                              " ",
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                              selector: (_, cat) => cat.curCat,
                            ),
                            Expanded(
                              child: Selector<CategoryProvider, List<Product>>(
                                builder: (context, data, child) {
                                  return data.length > 0
                                      ? GridView.count(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          crossAxisCount: 3,
                                          shrinkWrap: true,
                                          childAspectRatio: .75,
                                          children: List.generate(
                                            data.length,
                                            (index) {
                                              return subCatItem(
                                                  data, index, context);
                                            },
                                          ))
                                      : Center(
                                          child: Text(
                                              getTranslated(context, 'noItem')!));
                                },
                                selector: (_, categoryProvider) =>
                                    categoryProvider.subList,
                              ),
                            ),
                          ],
                        )
                      : Container(),
                ),
              ],
            );
          },
        ),
        );
  }

  Widget catItem(int index, BuildContext context1) {
    return Selector<CategoryProvider, int>(
      builder: (context, data, child) {
        if (index == 0 && (popularLists.length > 0)) {
          return GestureDetector(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: data == index
                      ? Theme.of(context).colorScheme.white
                      : Colors.transparent,
                  border: data == index
                      ? Border(
                          left: BorderSide(width: 5.0, color: colors.primary),
                        )
                      : null
                  // borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: SvgPicture.asset(
                        data == index
                            ? imagePath + "popular_sel.svg"
                            : imagePath + "popular.svg",
                        color: colors.primary,
                      ),
                    ),
                  ),
                  Text(
                    catLists[index].name! + "\n",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context1).textTheme.caption!.copyWith(
                        color: data == index
                            ? colors.primary
                            : Theme.of(context).colorScheme.fontColor),
                  )
                ],
              ),
            ),
            onTap: () {
              context1.read<CategoryProvider>().setCurSelected(index);
              context1.read<CategoryProvider>().setSubList(popularLists);
            },
          );
        } else {
          return GestureDetector(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: data == index
                      ? Theme.of(context).colorScheme.white
                      : Colors.transparent,
                  border: data == index
                      ? Border(
                          left: BorderSide(width: 5.0, color: colors.primary),
                        )
                      : null),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: FadeInImage(
                            image: CachedNetworkImageProvider(
                                catLists[index].image!),
                            fadeInDuration: Duration(milliseconds: 150),
                            fit: BoxFit.fill,
                            imageErrorBuilder: (context, error, stackTrace) =>
                                erroWidget(50),
                            placeholder: placeHolder(50),
                          )),
                    ),
                  ),
                  Text(
                    catLists[index].name! + "\n",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context1).textTheme.caption!.copyWith(
                        color: data == index
                            ? colors.primary
                            : Theme.of(context).colorScheme.fontColor),
                  )
                ],
              ),
            ),
            onTap: () {
              context1.read<CategoryProvider>().setCurSelected(index);
              if (catLists[index].subList == null ||
                  catLists[index].subList!.length == 0) {
                context1.read<CategoryProvider>().setSubList([]);
                Navigator.push(
                    context1,
                    MaterialPageRoute(
                      builder: (context) => ProductList(
                        name: catLists[index].name,
                        id: catLists[index].id,
                        tag: false,
                        fromSeller: false,
                      ),
                    ));
              } else {
                context1
                    .read<CategoryProvider>()
                    .setSubList(catLists[index].subList);
              }
            },
          );
        }
      },
      selector: (_, cat) => cat.curCat,
    );
  }

  Widget catLoading() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                    .map((_) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.white,
                            shape: BoxShape.circle,
                          ),
                          width: 50.0,
                          height: 50.0,
                        ))
                    .toList()),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ),
      ],
    );
  }

  subCatItem(List<Product> subList, int index, BuildContext context) {
    return GestureDetector(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: FadeInImage(
                  image: CachedNetworkImageProvider(subList[index].image!),
                  fadeInDuration: Duration(milliseconds: 150),
                  fit: BoxFit.fill,
                  height: MediaQuery.of(context).size.height * 0.12,
                  width: MediaQuery.of(context).size.height * 0.12,
                  imageErrorBuilder: (context, error, stackTrace) =>
                      erroWidget(50),
                  placeholder: placeHolder(50),
                )),
          ),
          Text(
            subList[index].name! + "\n",
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
          )
        ],
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SellerList(
                      getByLocation: false,
                      catId: subList[index].id!,
                  buyOneOffer: false,
                    )));
        // if (context.read<CategoryProvider>().curCat == 0 &&
        //     popularList.length > 0) {
        //   if (popularList[index].subList == null ||
        //       popularList[index].subList!.length == 0) {
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => ProductList(
        //             name: popularList[index].name,
        //             id: popularList[index].id,
        //             tag: false,
        //             fromSeller: false,
        //           ),
        //         ));
        //   } else {
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => SubCategory(
        //             title: popularList[index].name ?? "",
        //           ),
        //         ));
        //   }
        // } else if (subList[index].subList == null ||
        //     subList[index].subList!.length == 0) {
        //   Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => ProductList(
        //           name: subList[index].name,
        //           id: subList[index].id,
        //           tag: false,
        //           fromSeller: false,
        //         ),
        //       ));
        // } else {
        //   Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => SubCategory(
        //           title: subList[index].name ?? "",
        //         ),
        //       ));
        // }
      },
    );
  }

  void getSeller() {
    String pin = context.read<UserProvider>().curPincode;
    var loc = Provider.of<LocationProvider>(context, listen: false);
    sellerLists.clear();
    Map parameter = {
      "lat": "${loc.lat}",
      "lang": "${loc.lng}",
      "shop_type": "1",
      "veg_nonveg": foodType ? "2" : "1",
    };
    print(parameter);
    // if (pin != '') {
    //   parameter = {
    //     "lat":"$latitude",
    //     "lang":"$longitude"
    //   };
    //   print(latitude);
    //   print(longitude);
    // }

    apiBaseHelper.postAPICall(getSellerApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        dynamic data = getdata["data"];
        print(getSellerApi.toString());
        print(parameter.toString());
        print(getdata.toString());
        print(data);
        if (data.isEmpty) {
          // showToast("No Seller Available");
        }

        sellerLists =
            (data as List).map((data) => new Product.fromSeller(data)).toList();
        setState(() {});
      } else {
        // setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSellerLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSellerLoading(false);
    });
  }

  _seller() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? Container(
                width: double.infinity,
                child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.simmerBase,
                    highlightColor: Theme.of(context).colorScheme.simmerHigh,
                    child: catLoading()))
            : ListView(
                children: [
                  ListTile(
                    trailing: Container(
                      width: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          foodType
                              ? Text(
                            "Non Veg",
                            style: TextStyle(color: Colors.red),
                          )
                              : Text(
                            "Veg",
                            style: TextStyle(color: Colors.green),
                          ),
                          Padding(
                            padding:  EdgeInsets.zero,
                            child: Switch(
                                value: foodType,
                                onChanged: (val) {
                                  setState(() {
                                    foodType = val;
                                  });
                                  foodType ? showToast("Non Veg") : showToast("Veg");
                                  sellerLists.clear();
                                  getSeller();
                                }),
                          ),
                        ],
                      ),
                    ),
                    title: Text(getTranslated(context, 'RES_BY_SELLER')!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontWeight: FontWeight.bold)),

                    // trailing: TextButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => SellerList(
                    //                   getByLocation: true,
                    //                 )));
                    //   },
                    //   child: Text(
                    //     getTranslated(context, 'VIEW_ALL')!,
                    //     style: TextStyle(fontWeight: FontWeight.w600),
                    //   ),
                    // ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          sellerLists.isNotEmpty
                              ? ListView.builder(
                                  itemCount: sellerLists.length,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 1),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (sellerLists[index]
                                                  .open_close_status ==
                                              "1") {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SubCategory(
                                                          title:
                                                              sellerLists[index]
                                                                  .store_name
                                                                  .toString(),
                                                          sellerId:
                                                              sellerLists[index]
                                                                  .seller_id
                                                                  .toString(),
                                                          sellerData:
                                                              sellerLists[
                                                                  index],
                                                        )));
                                          } else {
                                            showToast("Shop Closed");
                                          }
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) => SellerProfile(
                                          //               sellerStoreName: sellerList[index]
                                          //                       .store_name ??
                                          //                   "",
                                          //               sellerRating: sellerList[index]
                                          //                       .seller_rating ??
                                          //                   "",
                                          //               sellerImage: sellerList[index]
                                          //                       .seller_profile ??
                                          //                   "",
                                          //               sellerName: sellerList[index]
                                          //                       .seller_name ??
                                          //                   "",
                                          //               sellerID:
                                          //                   sellerList[index].seller_id,
                                          //               storeDesc: sellerList[index]
                                          //                   .store_description,
                                          //             )));
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Card(
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Container(
                                                // decoration: BoxDecoration(
                                                //     borderRadius:
                                                //         BorderRadius.circular(10),
                                                //     image: DecorationImage(
                                                //         fit: BoxFit.cover,
                                                //         // opacity: .05,
                                                //         image: NetworkImage(
                                                //             sellerList[index]
                                                //                 .seller_profile!))),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 70,
                                                      width: 80,
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        child: FadeInImage(
                                                          fadeInDuration:
                                                              Duration(
                                                                  milliseconds:
                                                                      150),
                                                          image:
                                                              CachedNetworkImageProvider(
                                                            sellerLists[index]
                                                                .seller_profile!,
                                                          ),
                                                          fit: BoxFit.cover,
                                                          imageErrorBuilder:
                                                              (context, error,
                                                                      stackTrace) =>
                                                                  erroWidget(
                                                                      50),
                                                          placeholder:
                                                              placeHolder(50),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        children: [
                                                          ListTile(
                                                            dense: true,
                                                            title: Text(
                                                                "${sellerLists[index].store_name!}"),
                                                            subtitle: Text(
                                                              "${sellerLists[index].store_description!}\n${sellerLists[index].open_close_status}",
                                                              maxLines: 2,
                                                            ),
                                                            trailing: Text(
                                                              sellerLists[index]
                                                                          .open_close_status ==
                                                                      "1"
                                                                  ? "Open"
                                                                  : "Close",
                                                              style: TextStyle(
                                                                  color: sellerLists[index]
                                                                              .open_close_status ==
                                                                          "1"
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .red),
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 0,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                FittedBox(
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .star_rounded,
                                                                        color: Colors
                                                                            .amber,
                                                                        size:
                                                                            15,
                                                                      ),
                                                                      Text(
                                                                        "${sellerLists[index].seller_rating!}",
                                                                        style: Theme.of(context).textTheme.caption!.copyWith(
                                                                            color:
                                                                                Theme.of(context).colorScheme.fontColor,
                                                                            fontWeight: FontWeight.w600,
                                                                            fontSize: 14),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                sellerLists[index]
                                                                            .estimated_time !=
                                                                        ""
                                                                    ? FittedBox(
                                                                        child: Container(
                                                                            child: Center(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                                            child:
                                                                                Text(
                                                                              "${sellerLists[index].estimated_time}",
                                                                              style: TextStyle(fontSize: 14),
                                                                            ),
                                                                          ),
                                                                        )),
                                                                      )
                                                                    : Container(),
                                                                sellerLists[index]
                                                                            .food_person !=
                                                                        ""
                                                                    ? FittedBox(
                                                                        child: Container(
                                                                            child: Padding(
                                                                          padding: const EdgeInsets.symmetric(
                                                                              horizontal: 5,
                                                                              vertical: 1),
                                                                          child:
                                                                              Text(
                                                                            "${sellerLists[index].food_person}",
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
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height * .6,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                          child: Image.asset(
                                        "assets/images/restaurant not found.png",
                                        scale: 5,
                                      )),
                                    ],
                                  )),
                        ],
                      ),
                    ),
                  ),
                ],
              );
      },
      selector: (_, homeProvider) => homeProvider.sellerLoading,
    );
  }
}
