import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jhatfat/Components/custom_appbar.dart';
import 'package:jhatfat/Routes/routes.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/Themes/style.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/productlistvarient.dart';
import 'package:jhatfat/bean/subcategorylist.dart';
import 'package:jhatfat/databasehelper/dbhelper.dart';
import 'package:jhatfat/singleproductpage/singleproductpage.dart';

import '../bean/cartitem.dart';
import '../bean/resturantbean/restaurantcartitem.dart';

class ItemsPage extends StatefulWidget {
  final dynamic pageTitle;
  final dynamic vendor_id;
  final dynamic category_name;
  final dynamic category_id;
  final dynamic distance;

  ItemsPage(this.pageTitle, this.vendor_id, this.category_name,
      this.category_id, this.distance);

  @override
  _ItemsPageState createState() =>
      _ItemsPageState(pageTitle, vendor_id, category_name, category_id);
}

class _ItemsPageState extends State<ItemsPage>
    with SingleTickerProviderStateMixin {
  int itemCount = 0;
  int restrocart = 0;
  List<CartItem> cartListI = [];

  List<Tab> tabs = <Tab>[];

  dynamic pageTitle;
  dynamic vendor_id;
  dynamic category_name;
  dynamic category_id;

  dynamic currency = '';

  List<CartItem> tagObjs = [];
  List<int> vendors = [];

  List<SubCategoryList> subCategoryListApp = [];
  List<SubCategoryList> subCategoryListDemo = [
    SubCategoryList(
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ),
    SubCategoryList(
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ),
    SubCategoryList(
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ),
  ];

  List<ProductWithVarient> productVarientList = [];
  List<ProductWithVarient> productVarientListSearch = [];

  bool isCartCount = false;
  var cartCount = 0;

  dynamic totalAmount = 0.0;
  TextEditingController searchController = TextEditingController();
  TabController? tabController;

  bool addMinus = false;

  bool isFetchList = false;
  bool isSearchOpen = false;
  String message = "";
  String curency = "";
  List<CartItem> results = [];

  _ItemsPageState(
      this.pageTitle, this.vendor_id, this.category_name, this.category_id);

  @override
  void initState() {
    super.initState();
    print("widget items : ${widget.pageTitle}");
    print("widget items : ${widget.vendor_id}");
    print("widget items : ${widget.category_name}");
    print("widget items : ${widget.category_id}");
    print("widget items : ${widget.distance}");

    hitServices();
    getCartCount();
    getCartItem2();
  }

  @override
  void dispose() {
    super.dispose();
  }

  showMyDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            content: Text(
              'Grocery orders are to be placed separately.\nPlease clear/empty cart to add item. ',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Clear Cart'),
                onPressed: () {
                  ClearCart();
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
  }

  void ClearCart() {
    DatabaseHelper db = DatabaseHelper.instance;
    db.deleteAllRestProdcut();
    getCartItem2();
    setState(() {
      restrocart = 0;
    });
  }

  void getCartCount() {
    DatabaseHelper db = DatabaseHelper.instance;
    db.queryRowCount().then((value) {
      setState(() {
        if (value != null && value > 0) {
          cartCount = value;
          isCartCount = true;
        } else {
          cartCount = 0;
          isCartCount = false;
        }
      });
    });

    getCatC();
  }

  void getCartItem2() async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.getResturantOrderList().then((value) {
      List<RestaurantCartItem> tagObjs =
          value.map((tagJson) => RestaurantCartItem.fromJson(tagJson)).toList();
      if (tagObjs.isNotEmpty) {
        setState(() {
          restrocart = 1;
        });
      }
    });
  }

  void getCatC() async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.calculateTotal().then((value) {
      var tagObjsJson = value as List;
      setState(() {
        if (value != null) {
          totalAmount = tagObjsJson[0]['Total'];
        } else {
          totalAmount = 0.0;
        }
      });
    });
  }

  void setList2() {
    if (searchController != null && searchController.text.length > 0) {
      setState(() {
        searchController.clear();
        productVarientList.clear();
        productVarientList = List.from(productVarientListSearch);
      });
    } else {
      setState(() {
        isSearchOpen = false;
        productVarientList.clear();
        productVarientList = List.from(productVarientListSearch);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Stack(children: <Widget>[
          DefaultTabController(
            length: tabs.length,
            child: Stack(children: [
              Container(
                child: Scaffold(
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(115.0),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 10,
                        ),

                        CustomAppBar(
                          titleWidget: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(pageTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .copyWith(color: kMainTextColor)),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.location_on,
                                      color: kIconColor,
                                      size: 10,
                                    ),
                                    SizedBox(width: 10.0),
                                    Text(
                                        '${double.parse('${widget.distance}').toStringAsFixed(2)} km ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .overline),
                                    Text('|',
                                        style: Theme.of(context)
                                            .textTheme
                                            .overline),
                                    Text(category_name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .overline),
                                    Spacer(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            Padding(
                              padding: const EdgeInsets.only(right: 2.0),
                              child: IconButton(
                                  icon: Icon(
                                    Icons.search,
                                    color: kHintColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isSearchOpen = !isSearchOpen;
                                    });
                                  }),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Stack(
                                children: [
                                  IconButton(
                                      icon: ImageIcon(
                                        AssetImage(
                                            'images/icons/ic_cart blk.png'),
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                                context, PageRoutes.viewCart)
                                            .then((value) {
                                          setList(productVarientList);
                                          getCartCount();
                                        });
                                      }),
                                  // Positioned(
                                  //     right: 5,
                                  //     top: 2,
                                  //     child: Visibility(
                                  //       visible: isCartCount,
                                  //       child: CircleAvatar(
                                  //         minRadius: 4,
                                  //         maxRadius: 8,
                                  //         backgroundColor: kMainColor,
                                  //         child: Text(
                                  //           '$cartCount',
                                  //           overflow: TextOverflow.ellipsis,
                                  //           style: TextStyle(
                                  //               fontSize: 7,
                                  //               color: kWhiteColor,
                                  //               fontWeight: FontWeight.w200),
                                  //         ),
                                  //       ),
                                  //     ))
                                ],
                              ),
                            ),
                          ],
                          bottom: PreferredSize(
                            preferredSize: Size.fromHeight(10.0),
                            child: Column(
                              children: <Widget>[
                                Visibility(
                                  visible: (!isSearchOpen) ? false : true,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    height: 50,
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.only(left: 5),
                                    child: TypeAheadField(
                                      textFieldConfiguration:
                                          TextFieldConfiguration(
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5.0)),
                                              borderSide: BorderSide(
                                                  color: Colors.black)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5.0)),
                                              borderSide: BorderSide(
                                                  color: Colors.black)),
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color: kHintColor,
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isSearchOpen = !isSearchOpen;
                                              });
                                            },
                                            icon: Icon(Icons.close),
                                          ),
                                          hintText: 'Search Items...',
                                        ),
                                      ),
                                      suggestionsCallback: (pattern) async {
                                        return await BackendService
                                            .getSuggestions(
                                                pattern, widget.vendor_id);
                                      },
                                      itemBuilder: (context,
                                          ProductWithVarient suggestion) {
                                        return ListTile(
                                            title: Text('${suggestion.str1}'),
                                            subtitle:
                                                Text('${suggestion.str2}'));
                                      },
                                      hideOnError: true,
                                      onSuggestionSelected:
                                          (ProductWithVarient detail) {
                                        if (detail.product_id != null) {
                                          setState(() {
                                            isSearchOpen = false;
                                          });
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return SingleProductPage(
                                              detail,
                                              curency,
                                            );
                                          }));
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                TabBar(
                                  tabs: tabs,
                                  isScrollable: (subCategoryListApp != null &&
                                          subCategoryListApp.length > 3)
                                      ? true
                                      : false,
                                  labelColor: kMainColor,
                                  unselectedLabelColor: kLightTextColor,
                                  controller: tabController,
                                  indicatorPadding:
                                      EdgeInsets.symmetric(horizontal: 24.0),
                                ),
                                Divider(
                                  color: kCardBackgroundColor,
                                  thickness: 8.0,
                                )
                              ],
                            ),
                          ),
                        ),
                        // Visibility(
                        //   visible: isSearchOpen,
                        //   child: Container(
                        //     width: MediaQuery
                        //         .of(context)
                        //         .size
                        //         .width,
                        //     height: 72,
                        //     padding: EdgeInsets.only(top: 5.0),
                        //     color: kWhiteColor,
                        //     child: Column(
                        //       children: [
                        //         SizedBox(
                        //           height: 15,
                        //         ),
                        //         Container(
                        //           width: MediaQuery
                        //               .of(context)
                        //               .size
                        //               .width,
                        //           height: 52,
                        //           padding: EdgeInsets.only(left: 5),
                        //           decoration: BoxDecoration(
                        //             color: scaffoldBgColor,
                        //           ),
                        //           child: TextFormField(
                        //             controller: searchController,
                        //             decoration: InputDecoration(
                        //               border: InputBorder.none,
                        //               prefixIcon: Icon(
                        //                 Icons.search,
                        //                 color: kHintColor,
                        //               ),
                        //               hintText: 'Search category...',
                        //               suffixIcon: IconButton(
                        //                 onPressed: () {
                        //                   setState(() {
                        //                     isSearchOpen = !isSearchOpen;
                        //                   });
                        //                 },
                        //                 icon: Icon(
                        //                   Icons.close,
                        //                   color: kHintColor,
                        //                 ),
                        //               ),
                        //             ),
                        //             cursorColor: kMainColor,
                        //             autofocus: false,
                        //             onChanged: (value) {
                        //               setState(() {
                        //                 productVarientList = productVarientListSearch
                        //                     .where((element) =>
                        //                     element.product_name
                        //                         .toString()
                        //                         .toLowerCase()
                        //                         .contains(value.toLowerCase()))
                        //                     .toList();
                        //               });
                        //             },
                        //           ),
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  body: DefaultTabController(
                    length: tabs.length,
                    child: TabBarView(
                      controller: tabController,
                      children: tabs.map((Tab tab) {
                        return Stack(children: [
                          Container(
                              child: Stack(
                            children: <Widget>[
                              Positioned(
                                  top: 0.0,
                                  width: MediaQuery.of(context).size.width,
                                  height: isCartCount
                                      ? (MediaQuery.of(context).size.height)
                                      : (MediaQuery.of(context).size.height),
                                  child:
                                      (!isFetchList &&
                                              productVarientList != null &&
                                              productVarientList.length > 0)
                                          ? ListView.builder(
                                              padding:
                                                  EdgeInsets.only(bottom: 500),
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                              // new
                                              controller:
                                                  new ScrollController(),
                                              //
                                              // new
                                              itemCount:
                                                  productVarientList.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return SingleProductPage(
                                                          productVarientList[
                                                              index],
                                                          currency);
                                                    })).then((value) {
                                                      setList(
                                                          productVarientList);
                                                      getCartCount();
                                                    });
                                                  },
                                                  behavior:
                                                      HitTestBehavior.opaque,
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 20.0,
                                                                    top: 30.0,
                                                                    right:
                                                                        14.0),
                                                            child: (productVarientList !=
                                                                        null &&
                                                                    productVarientList
                                                                            .length >
                                                                        0)
                                                                ?
                                                            // Image.network(
                                                            //         imageBaseUrl +
                                                            //             productVarientList[index]
                                                            //                 .products_image,
                                                            //         height:
                                                            //             93.3,
                                                            //         width: 93.3,
                                                            //       )



                                                            Image.network(
                                                              imageBaseUrl +
                                                                  productVarientList[index].products_image,
                                                              width: 93.3,
                                                              height: 93.3,
                                                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                                // Return a placeholder/default image when the network image fails to load
                                                                return Image.network(
                                                                  'https://img.freepik.com/premium-vector/default-image-icon-vector-missing-picture-page-website-design-mobile-app-no-photo-available_87543-11093.jpg?w=900',
                                                                  width: 93.3,
                                                                  height: 93.3,
                                                                );
                                                                // Replace 'default_image.png' with your default image asset path
                                                              },
                                                            )
                                                                : Image(
                                                                    image: AssetImage(
                                                                        'images/logos/logo_user.png'),
                                                                    height:
                                                                        93.3,
                                                                    width: 93.3,
                                                                  ),
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <Widget>[
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              20),
                                                                  child: Text(
                                                                      productVarientList[
                                                                              index]
                                                                          .product_name,
                                                                      style: bottomNavigationTextStyle.copyWith(
                                                                          fontSize:
                                                                              15)),
                                                                ),
                                                                SizedBox(
                                                                  height: 8.0,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                        (productVarientList[index].data.length <= 0 || productVarientList[index].data[productVarientList[index].selectPos].strick_price <= productVarientList[index].data[productVarientList[index].selectPos].price || productVarientList[index].data[productVarientList[index].selectPos].strick_price == null)
                                                                            ? ''
                                                                            : '$currency ${productVarientList[index].data[productVarientList[index].selectPos].strick_price} ',
                                                                        style: TextStyle(
                                                                            decoration:
                                                                                TextDecoration.lineThrough)),
                                                                    Text(
                                                                      '$currency ${(productVarientList[index].data.length > 0) ? productVarientList[index].data[productVarientList[index].selectPos].price : 0}',
                                                                      //style: TextStyle(decoration: TextDecoration.lineThrough)
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 20.0,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Positioned(
                                                        left: 120,
                                                        bottom: 5,
                                                        child: Container(
                                                          height: 30.0,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      12.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                kCardBackgroundColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30.0),
                                                          ),
                                                          child: (productVarientList[
                                                                              index]
                                                                          .data !=
                                                                      null &&
                                                                  productVarientList[
                                                                              index]
                                                                          .data
                                                                          .length >
                                                                      0)
                                                              ? DropdownButton<
                                                                      VarientList>(
                                                                  underline:
                                                                      Container(
                                                                    height: 0.0,
                                                                    color:
                                                                        kCardBackgroundColor,
                                                                  ),
                                                                  value: productVarientList[
                                                                          index]
                                                                      .data[productVarientList[
                                                                          index]
                                                                      .selectPos],
                                                                  items: productVarientList[
                                                                          index]
                                                                      .data
                                                                      .map((e) {
                                                                    return DropdownMenuItem<
                                                                        VarientList>(
                                                                      child:
                                                                          Text(
                                                                        '${e.quantity} ${e.unit}',
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .caption,
                                                                      ),
                                                                      value: e,
                                                                    );
                                                                  }).toList(),
                                                                  onChanged:
                                                                      (vale) {
                                                                    setState(
                                                                        () {
                                                                      int indexd = productVarientList[
                                                                              index]
                                                                          .data
                                                                          .indexOf(
                                                                              vale!);
                                                                      if (indexd !=
                                                                          -1) {
                                                                        productVarientList[index].selectPos =
                                                                            indexd;
                                                                        DatabaseHelper
                                                                            db =
                                                                            DatabaseHelper.instance;
                                                                        db.getVarientCount(int.parse('${productVarientList[index].data[productVarientList[index].selectPos].varient_id}')).then(
                                                                            (value) {
                                                                          print(
                                                                              'print t val $value');
                                                                          if (value ==
                                                                              null) {
                                                                            setState(() {
                                                                              productVarientList[index].add_qnty = 0;
                                                                            });
                                                                          } else {
                                                                            setState(() {
                                                                              productVarientList[index].add_qnty = value;
                                                                              isCartCount = true;
                                                                            });
                                                                          }
                                                                        });
                                                                      }
                                                                    });
                                                                  })
                                                              : Text(''),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        height: 30,
                                                        right: 20.0,
                                                        bottom: 5,
                                                        child: (productVarientList[
                                                                            index]
                                                                        .data !=
                                                                    null &&
                                                                productVarientList[
                                                                            index]
                                                                        .data
                                                                        .length >
                                                                    0 &&
                                                                int.parse(
                                                                        '${productVarientList[index].data[productVarientList[index].selectPos].stock}') >
                                                                    0)
                                                            ? (productVarientList[
                                                                            index]
                                                                        .add_qnty ==
                                                                    0
                                                                ? Container(
                                                                    height:
                                                                        30.0,
                                                                    child:
                                                                        TextButton(
                                                                      child:
                                                                          Text(
                                                                        'Add',
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .caption!
                                                                            .copyWith(
                                                                                color: kMainColor,
                                                                                fontWeight: FontWeight.bold),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        if (restrocart ==
                                                                            1) {
                                                                          print(
                                                                              "ALREADY");
                                                                          showMyDialog(
                                                                              context);
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            var stock =
                                                                                int.parse('${productVarientList[index].data[productVarientList[index].selectPos].stock}');
                                                                            if (stock >
                                                                                productVarientList[index].add_qnty) {
                                                                              productVarientList[index].add_qnty++;
                                                                              addOrMinusProduct(productVarientList[index].is_id, productVarientList[index].is_pres, productVarientList[index].isbasket, productVarientList[index].product_name, productVarientList[index].data[productVarientList[index].selectPos].unit, double.parse('${productVarientList[index].data[productVarientList[index].selectPos].price}'), int.parse('${productVarientList[index].data[productVarientList[index].selectPos].quantity}'), productVarientList[index].add_qnty, productVarientList[index].data[productVarientList[index].selectPos].varient_image, productVarientList[index].data[productVarientList[index].selectPos].varient_id, productVarientList[index].data[0].vendor_id);
                                                                            } else {
                                                                              // Toast.show(
                                                                              //     "No more stock available!",
                                                                              //     context,
                                                                              //     gravity: Toast
                                                                              //         .BOTTOM);
                                                                            }
                                                                          });
                                                                        }
                                                                      },
                                                                    ),
                                                                  )
                                                                : Container(
                                                                    height:
                                                                        30.0,
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            11.0),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border: Border.all(
                                                                          color:
                                                                              kMainColor),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30.0),
                                                                    ),
                                                                    child: Row(
                                                                      children: <Widget>[
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              productVarientList[index].add_qnty--;
                                                                            });
                                                                            addOrMinusProduct(
                                                                                productVarientList[index].is_id,
                                                                                productVarientList[index].is_pres,
                                                                                productVarientList[index].isbasket,
                                                                                productVarientList[index].product_name,
                                                                                productVarientList[index].data[productVarientList[index].selectPos].unit,
                                                                                double.parse('${productVarientList[index].data[productVarientList[index].selectPos].price}'),
                                                                                int.parse('${productVarientList[index].data[productVarientList[index].selectPos].quantity}'),
                                                                                productVarientList[index].add_qnty,
                                                                                productVarientList[index].data[productVarientList[index].selectPos].varient_image,
                                                                                productVarientList[index].data[productVarientList[index].selectPos].varient_id,
                                                                                productVarientList[index].data[0].vendor_id);
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            Icons.remove,
                                                                            color:
                                                                                kMainColor,
                                                                            size:
                                                                                20.0,
                                                                            //size: 23.3,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                8.0),
                                                                        Text(
                                                                            productVarientList[index]
                                                                                .add_qnty
                                                                                .toString(),
                                                                            style:
                                                                                Theme.of(context).textTheme.caption),
                                                                        SizedBox(
                                                                            width:
                                                                                8.0),
                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              var stock = int.parse('${productVarientList[index].data[productVarientList[index].selectPos].stock}');
                                                                              if (stock > productVarientList[index].add_qnty) {
                                                                                productVarientList[index].add_qnty++;
                                                                                addOrMinusProduct(productVarientList[index].is_id, productVarientList[index].is_pres, productVarientList[index].isbasket, productVarientList[index].product_name, productVarientList[index].data[productVarientList[index].selectPos].unit, double.parse('${productVarientList[index].data[productVarientList[index].selectPos].price}'), int.parse('${productVarientList[index].data[productVarientList[index].selectPos].quantity}'), productVarientList[index].add_qnty, productVarientList[index].data[productVarientList[index].selectPos].varient_image, productVarientList[index].data[productVarientList[index].selectPos].varient_id, productVarientList[index].data[0].vendor_id);
                                                                              } else {
                                                                                // Toast.show(
                                                                                //     "No more stock available!",
                                                                                //     context,
                                                                                //     gravity: Toast
                                                                                //         .BOTTOM);
                                                                              }
                                                                            });
                                                                          },
                                                                          child:
                                                                              Icon(
                                                                            Icons.add,
                                                                            color:
                                                                                kMainColor,
                                                                            size:
                                                                                20.0,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ))
                                                            : Container(
                                                                child: Text(
                                                                  'Out off stock',
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .caption!
                                                                      .copyWith(
                                                                          color:
                                                                              kMainColor,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                ),
                                                              ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  isFetchList
                                                      ? CircularProgressIndicator()
                                                      : Container(
                                                          width: 0.5,
                                                        ),
                                                  isFetchList
                                                      ? SizedBox(
                                                          width: 10,
                                                        )
                                                      : Container(
                                                          width: 0.5,
                                                        ),
                                                  Text(
                                                    (!isFetchList)
                                                        ? 'No product available for this category'
                                                        : 'Fetching Products..',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: kMainTextColor),
                                                  )
                                                ],
                                              ),
                                            ))
                            ],
                          ))
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Positioned(
                  child: Visibility(
                      visible: isCartCount,
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                        context, PageRoutes.viewCart)
                                    .then((value) {
                                  setList(productVarientList);
                                  getCartCount();
                                });
                              },
                              child: Container(
                                  color: kMainColor,
                                  height: 60.0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Image.asset(
                                        'images/icons/ic_cart wt.png',
                                        height: 19.0,
                                        width: 18.3,
                                      ),
                                      DefaultTextStyle(
                                        style: bottomBarTextStyle.copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                        child: Text(
                                            '$cartCount items | $currency $totalAmount'),
                                      ),
                                      Flexible(
                                          fit: FlexFit.tight,
                                          child: SizedBox()),
                                      Align(
                                          alignment: Alignment.centerRight,
                                          child: DefaultTextStyle(
                                            style: bottomBarTextStyle.copyWith(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500),
                                            child: const Text('Go to cart'),
                                          )),
                                    ],
                                  )))))),
            ]),
          ),
        ]));
  }

  void addOrMinusProduct(is_id, is_pres, isBasket, product_name, unit, price,
      quantity, itemCount, varient_image, varient_id, vendor) async {
    DatabaseHelper db = DatabaseHelper.instance;
    Future<int?> existing = db.getcount(int.parse('${varient_id}'));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? store_name = prefs.getString('store_name');

    existing.then((value) {
      var vae = {
        DatabaseHelper.productName: product_name,
        DatabaseHelper.storeName: store_name,
        DatabaseHelper.vendor_id: vendor,
        DatabaseHelper.price: (price * itemCount),
        DatabaseHelper.unit: unit,
        DatabaseHelper.quantitiy: quantity,
        DatabaseHelper.addQnty: itemCount,
        DatabaseHelper.productImage: varient_image,
        DatabaseHelper.is_pres: is_pres,
        DatabaseHelper.is_id: is_id,
        DatabaseHelper.isBasket: isBasket,
        DatabaseHelper.addedBasket: 0,
        DatabaseHelper.varientId: int.parse('${varient_id}')
      };

      bool allow = (prefs.getString("allowmultishop").toString() != "1");
      if (value == 0) {
        db.insert(vae);
        print("CARTITEN:::" + vae.toString());

        if (allow) {
          db.getVendorcount().then((value) {
            print("VENDORCOUNT" + value.toString());
            if (value != null && value <= 3) {
              //db.insert(vae);
              getCartCount();
            } else {
              db.delete(int.parse('${varient_id}'));
              showMyDialog2(context);
              setList(productVarientList);
            }
          });
        } else {
          db.insert(vae);
          getCartCount();
        }
      } else {
        if (itemCount == 0) {
          db.delete(int.parse('${varient_id}'));
          getCartCount();
        } else {
          db.updateData(vae, int.parse('${varient_id}')).then((vay) {
            print('vay - $vay');
            getCartCount();
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void hitServices() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currency = preferences.getString('curency');
    });
    var url = subCategoryList;
    Uri myUri = Uri.parse(url);

    var response =
        await http.post(myUri, body: {'category_id': category_id.toString()});

    try {
      if (response.statusCode == 200) {
        print('Response Body: - ${response.body}');
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<SubCategoryList> tagObjs = tagObjsJson
              .map((tagJson) => SubCategoryList.fromJson(tagJson))
              .toList();
          List<Tab> tabss = <Tab>[];
          List<SubCategoryList> toRemove = [];

          setState(() {
            for (SubCategoryList tagd in tagObjs) {
              if (tagd.istabacco.toString() != "1") {
                tabss.add(Tab(
                  text: tagd.subcatName,
                ));
                toRemove.add(tagd);
              } else {}
            }
            setState(() {
              subCategoryListApp.clear();
              tabs.clear();
              subCategoryListApp = toRemove;
              tabs = tabss;
              tabController = TabController(length: tabs.length, vsync: this);
            });
            setState(() {
              productVarientList = [];
              hitTabSeriveList(subCategoryListApp[0].subcatId);
            });

            tabController!.addListener(() {
              if (!tabController!.indexIsChanging) {
                setState(() {
                  productVarientList = [];
                  hitTabSeriveList(
                      subCategoryListApp[tabController!.index].subcatId);
                });
              }
            });
          });
        } else {
          setState(() {
            List<Tab> tabss = <Tab>[];
            tabss.add(Tab(
              text: category_name,
            ));
            subCategoryListApp.clear();
            tabs.clear();
            subCategoryListApp = [];
            tabs = tabss;

            tabController = TabController(length: tabs.length, vsync: this);
            tabController!.addListener(() {
              if (!tabController!.indexIsChanging) {
                setState(() {
                  productVarientList = [];
                  hitTabSeriveList(
                      subCategoryListApp[tabController!.index].subcatId);
                });
              }
            });
            setState(() {
              productVarientList = [];

              ///hitTabSeriveList(subCategoryListApp[0].subcat_id);
            });
          });
        }
      }
    } on Exception catch (_) {
      Timer(Duration(seconds: 5), () {
        hitServices();
      });
    }
  }

  void hitTabSeriveList(subCatId) async {
    print("subcat is: ${subCatId.toString()}");
    setState(() {
      isFetchList = true;
    });
    var url = productListWithVarient;
    Uri myUri = Uri.parse(url);

    var response =
        await http.post(myUri, body: {'subcat_id': subCatId.toString()});
    try {
      if (response.statusCode == 200) {
        if (response.body.toString().contains('product_id')) {
          print('Response Body(chicken): - ${response.body}');
          var jsonData = jsonDecode(response.body);
          if (jsonData.toString().length > 4) {
            var tagObjsJson = jsonDecode(response.body) as List;
            List<ProductWithVarient> tagObjs = tagObjsJson
                .map((tagJson) => ProductWithVarient.fromJson(tagJson))
                .toList();
            setState(() {
              productVarientList.clear();
              productVarientListSearch.clear();
              productVarientList = tagObjs;
              print("productvarient list is 1 : ${productVarientList}");
              print(
                  "productvarient list is 1 : ${productVarientList[0].data.length}");
              /*       print("productvarient list is :${productVarientList[1]
                  .data[productVarientList[1]
                  .selectPos].strick_price}");*/
              setList(tagObjs);
            });
          }
          setState(() {
            isFetchList = false;
          });
        } else {
          setState(() {
            productVarientList.clear();
            isFetchList = false;
          });
        }
      }
    } on Exception catch (_) {
      Timer(Duration(seconds: 5), () {
        hitTabSeriveList(subCatId);
      });
    }
  }

  hitViewCart(BuildContext context) {
    if (isCartCount) {
      Navigator.pushNamed(context, PageRoutes.viewCart).then((value) {
        setList(productVarientList);
        getCartCount();
      });
    } else {
      // Toast.show('No Value in the cart!', context,
      //     duration: Toast.LENGTH_SHORT);
    }
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      message = prefs.getString("message")!;
      curency = prefs.getString("curency")!;
    });
  }

  void setList(List<ProductWithVarient> tagObjs) {
    for (int i = 0; i < tagObjs.length; i++) {
      if (tagObjs[i].data.length > 0) {
        print("PRES: " + tagObjs[i].is_pres.toString());
        DatabaseHelper db = DatabaseHelper.instance;
        db
            .getVarientCount(int.parse(
                '${tagObjs[i].data[tagObjs[i].selectPos].varient_id}'))
            .then((value) {
          print('print val $value');
          if (value == null) {
            setState(() {
              tagObjs[i].add_qnty = 0;
            });
          } else {
            setState(() {
              tagObjs[i].add_qnty = value;
              isCartCount = true;
            });
          }
        });
      }
    }
    productVarientListSearch = List.from(productVarientList);
  }
}

showMyDialog2(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
            'Maximum Vendor Limit Reached',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      });
}

// class BottomSheetWidget extends StatefulWidget {
//   final String product_name;
//   final String store_name;
//   final String category_name;
//   final dynamic is_pres;
//   final dynamic is_id;
//   final dynamic currency;
//   final List<VarientList> datas;
//   List<VarientList> newdatas = [];
//
//   BottomSheetWidget(
//       this.product_name, this.store_name,this.datas, this.category_name, this.currency,this.is_pres,this.is_id) {
//     newdatas.clear();
//     newdatas.addAll(datas);
//     newdatas.removeAt(0);
//   }
//
//   @override
//   State<StatefulWidget> createState() {
//     return BottomSheetWidgetState(product_name,store_name, newdatas,is_pres,is_id);
//   }
// }
//
// class BottomSheetWidgetState extends State<BottomSheetWidget> {
//   final String product_name;
//   final String store_name;
//   final List<VarientList> data;
//   final dynamic is_pres;
//   final dynamic is_id;
//
//   BottomSheetWidgetState(this.product_name,this.store_name, this.data,this.is_pres,this.is_id) {
//     setList(data);
//   }
//
//   void setList(List<VarientList> tagObjs) {
//     for (int i = 0; i < tagObjs.length; i++) {
//       DatabaseHelper db = DatabaseHelper.instance;
//       db.getVarientCount(int.parse('${tagObjs[i].varient_id}')).then((value) {
//         print('print val $value');
//         if (value == null) {
//           setState(() {
//             tagObjs[i].add_qnty = 0;
//           });
//         } else {
//           setState(() {
//             tagObjs[i].add_qnty = value;
//           });
//         }
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       children: <Widget>[
//         Container(
//           height: 80.7,
//           color: kCardBackgroundColor,
//           padding: EdgeInsets.all(10.0),
//           child: ListTile(
//             title: Text(product_name,
//                 style: Theme.of(context)
//                     .textTheme
//                     .caption!
//                     .copyWith(fontSize: 15, fontWeight: FontWeight.w500)),
//             subtitle: Text('${widget.category_name}',
//                 style:
//                 Theme.of(context).textTheme.caption!.copyWith(fontSize: 15)),
//           ),
//         ),
//         ListView.separated(
//           shrinkWrap: true,
//           primary: true,
//           itemCount: data.length,
//           itemBuilder: (context, index) {
//             return Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     SizedBox(
//                       width: 20,
//                     ),
//                     Text(
//                       '${data[index].quantity} ${data[index].unit}  ${widget.currency} ${data[index].price}',
//                       style: Theme.of(context)
//                           .textTheme
//                           .caption!
//                           .copyWith(fontSize: 16.7),
//                     )
//                   ],
//                 ),
//                 data[index].add_qnty == 0
//                     ? Container(
//                   height: 30.0,
//                   child: TextButton(
//                     child: Text(
//                       'Add',
//                       style: Theme.of(context).textTheme.caption!.copyWith(
//                           color: kMainColor, fontWeight: FontWeight.bold),
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         var stock = int.parse('${data[index].stock}');
//                         if (stock > data[index].add_qnty) {
//                           data[index].add_qnty++;
//                           addOrMinusProduct(
//                               product_name,
//                               data[index].unit,
//                               double.parse('${data[index].price}'),
//                               int.parse('${data[index].quantity}'),
//                               data[index].add_qnty,
//                               data[index].varient_image,
//                               data[index].varient_id,
//                               widget.store_name,
//                             is_pres,is_id
//                           );
//                         } else {
//                           // Toast.show("No more stock available!", context,
//                           //     gravity: Toast.BOTTOM);
//                         }
//                       });
//                     },
//                   ),
//                 )
//                     : Container(
//                   height: 30.0,
//                   padding: EdgeInsets.symmetric(horizontal: 11.0),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: kMainColor),
//                     borderRadius: BorderRadius.circular(30.0),
//                   ),
//                   child: Row(
//                     children: <Widget>[
//                       InkWell(
//                         onTap: () {
//                           setState(() {
//                             data[index].add_qnty--;
//                           });
//                           addOrMinusProduct(
//                               product_name,
//                               data[index].unit,
//                               double.parse('${data[index].price}'),
//                               int.parse('${data[index].quantity}'),
//                               data[index].add_qnty,
//                               data[index].varient_image,
//                               data[index].varient_id,
//                               widget.store_name,
//                               is_pres,is_id
//
//                           );
//                         },
//                         child: Icon(
//                           Icons.remove,
//                           color: kMainColor,
//                           size: 20.0,
//                           //size: 23.3,
//                         ),
//                       ),
//                       SizedBox(width: 8.0),
//                       Text(data[index].add_qnty.toString(),
//                           style: Theme.of(context).textTheme.caption),
//                       SizedBox(width: 8.0),
//                       InkWell(
//                         onTap: () {
//                           setState(() {
//                             var stock = int.parse('${data[index].stock}');
//                             if (stock > data[index].add_qnty) {
//                               data[index].add_qnty++;
//                               addOrMinusProduct(
//                                   product_name,
//                                   data[index].unit,
//                                   double.parse('${data[index].price}'),
//                                   int.parse('${data[index].quantity}'),
//                                   data[index].add_qnty,
//                                   data[index].varient_image,
//                                   data[index].varient_id,
//                                   widget.store_name,
//                                   is_pres,
//                                   is_id
//
//                               );
//                             } else {
//                               // Toast.show(
//                               //     "No more stock available!", context,
//                               //     gravity: Toast.BOTTOM);
//                             }
//                           });
//                         },
//                         child: Icon(
//                           Icons.add,
//                           color: kMainColor,
//                           size: 20.0,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             );
//           },
//           separatorBuilder: (context, index) {
//             return Divider(
//               height: 20,
//               color: Colors.transparent,
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   void addOrMinusProduct(product_name, unit, price, quantity, itemCount,
//       varient_image, varient_id,vendor_name,is_pres,is_id) async {
//
//     print("Pres :"+is_pres.toString());
//
//     DatabaseHelper db = DatabaseHelper.instance;
//     Future<int?> existing = db.getcount(int.parse('${varient_id}'));
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     existing.then((value) {
//       var vae = {
//         DatabaseHelper.storeName : vendor_name,
//         DatabaseHelper.productName: product_name,
//         DatabaseHelper.price: (price * itemCount),
//         DatabaseHelper.unit: unit,
//         DatabaseHelper.quantitiy: quantity,
//         DatabaseHelper.addQnty: itemCount,
//         DatabaseHelper.productImage: varient_image,
//         DatabaseHelper.varientId: varient_id,
//         DatabaseHelper.is_pres: 0,
//         DatabaseHelper.is_id: 0
//       };
//       if (value == 0) {
//         db.insert(vae);
//       } else {
//         if (itemCount == 0) {
//           db.delete(int.parse('${varient_id}'));
//         } else {
//           db.updateData(vae, int.parse('${varient_id}'));
//         }
//       }
//     });
//   }
// }

class BackendService {
  static Future<List<ProductWithVarient>> getSuggestions(
      String query, dynamic vendor_id) async {
    if (query.isEmpty && query.length < 2) {
      print('Query needs to be at least 3 chars');
      return Future.value([]);
    }

    var url = storesearch;
    Uri myUri = Uri.parse(url);
    var response = await http.post(myUri,
        body: {'vendor_id': vendor_id.toString(), 'prod_name': query});

    List<ProductWithVarient> vendors = [];
    List<ProductWithVarient> vendors1 = [];

    if (response.statusCode == 200) {
      Iterable json1 = jsonDecode(response.body)['product'];
      Iterable json2 = jsonDecode(response.body)['cat'];

      if (json1.isNotEmpty) {
        vendors.clear();
        vendors = List<ProductWithVarient>.from(
            json1.map((model) => ProductWithVarient.fromJson(model)));
      }
      if (json2.isNotEmpty) {
        vendors1.clear();
        vendors1 = List<ProductWithVarient>.from(
            json2.map((model) => ProductWithVarient.fromJson(model)));
        vendors.addAll(vendors1);
      }
    }

    return Future.value(vendors);
  }
}
