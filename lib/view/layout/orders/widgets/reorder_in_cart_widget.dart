import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../../../custom_widgets/custom_select/custom_select_item.dart';
import '../../../custom_widgets/custom_select/custom_single_select.dart';
import '../controller/orders_controller.dart';
import '../model/orders_model.dart';

class ReorderInCartWidget extends StatefulWidget {
  const ReorderInCartWidget({super.key, required this.item, required this.index});
  final Items? item;
  final int index;

  @override
  State<ReorderInCartWidget> createState() => _OrdersInCartWidgetState();
}

class _OrdersInCartWidgetState extends State<ReorderInCartWidget> {
  List<Map<String, dynamic>> productCleanList = [];
  int? selectedProductQuantity;
  String? productQuantityName;
  String? selectedProductClean;
  int? productQuantity;
  int? productFeatureName;

  @override
  void initState() {
    productQuantity = widget.item?.qty;
    if (widget.item?.productClean != null) {
      selectedProductClean = getProductCleanName(widget.item?.productClean.toString());
      if (widget.item?.productFeature != null) {
        productQuantityName = widget.item?.productFeatureName;
      }

      // log(" ==================> $selectedProductClean");
    }

    super.initState();
  }

  void updateOrderDetails(BuildContext context) {
    Provider.of<OrdersController>(context, listen: false).updateProductDetails(
      index: widget.index,
      quantity: productQuantity,
      featureId: getProductFeatureId(productQuantityName, widget.item!),
      clean: getProductFeature(selectedProductClean),
    );
  }

  @override
  Widget build(BuildContext context) {
    productCleanList = getProductClean(widget.item); // Reset and update list
    //log("${widget.item?.restaurantProduct?.latestOrderProductClean}");
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomNetworkImage(
                    imageUrl: widget.item?.restaurantProduct?.productImage ?? '',
                    height: 120,
                    width: 120,
                    radius: 12,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product name
                                  Text(
                                    widget.item?.restaurantProduct?.productName ?? '',
                                    style: AppTextStyle.text16RS(),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    'pound'.tr.replaceAll(
                                          '{}',
                                          '${calculatePrice(productPrice: widget.item?.restaurantProduct?.productPrice, quantity: productQuantity, productQuantity: productQuantityName, extraPrice: getProductCleanPrice(selectedProductClean, widget.item) ?? 0)}',
                                        ),
                                    style: AppTextStyle.text16RG(),
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              elevation: 10,
                              child: Row(
                                children: [
                                  IconButton(
                                    constraints: const BoxConstraints(minHeight: 25),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    splashRadius: 20,
                                    iconSize: 20,
                                    onPressed: () {
                                      setState(() {
                                        if (productQuantity != null) {
                                          productQuantity = productQuantity! + 1;
                                          updateOrderDetails(context);
                                        }
                                      });
                                    },
                                    icon: Icon(Icons.add, color: AppColors.mainAppColor),
                                  ),
                                  Text(productQuantity.toString(), style: AppTextStyle.text16RS()),
                                  IconButton(
                                    constraints: const BoxConstraints(minHeight: 25),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    splashRadius: 20,
                                    iconSize: 20,
                                    onPressed: () {
                                      setState(() {
                                        if (productQuantity != null && productQuantity! > 1) {
                                          productQuantity = productQuantity! - 1;
                                          updateOrderDetails(context);
                                        }
                                      });
                                    },
                                    icon: Icon(Icons.remove, color: AppColors.darkGreyColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        10.sbH,
                        // Quantity Feature Selector
                        if (widget.item?.restaurantProduct?.features?.isEmpty != true &&
                                widget.item?.restaurantProduct?.features?.any((e) => e.name == 'kilo') == true ||
                            widget.item?.restaurantProduct?.features?.any((e) => e.name == 'half') == true ||
                            widget.item?.restaurantProduct?.features?.any((e) => e.name == 'quarter') == true)
                          CustomSingleSelect(
                            value: selectedProductQuantity ?? widget.item?.productFeature ?? '',
                            hintText: 'chooseQuantity'.tr,
                            onChanged: (value) {
                              setState(() {
                                selectedProductQuantity = value;
                                productQuantityName = widget.item?.restaurantProduct?.features
                                        ?.where((e) => e.id == value)
                                        .map((e) => e.name)
                                        .first ??
                                    '';

                                // selectedProductClean = widget
                                //         .item?.restaurantProduct?.features
                                //         ?.where((e) => e.id == value)
                                //         .map((e) => e.name)
                                //         .first ??
                                //     "";

                                updateOrderDetails(context);
                                // log(productQuantityName.toString());
                                log(selectedProductClean.toString());
                              });
                            },
                            items: widget.item?.restaurantProduct?.features
                                ?.map((e) => CustomSelectItem(value: e.id, name: getProductFeatureName(e.name) ?? ''))
                                .toList(),
                          ),
                        10.sbH,

                        if (productCleanList.isNotEmpty)
                          CustomSingleSelect(
                            hintText: 'chooseClassification'.tr,
                            value: selectedProductClean ?? '',
                            onChanged: (value) {
                              setState(() {
                                selectedProductClean = value;
                                updateOrderDetails(context);
                              });
                              log('${getProductFeatureId(selectedProductClean, widget.item!)}');
                              log('$selectedProductClean');
                            },
                            items: productCleanList
                                .map((e) => CustomSelectItem(value: e['name'], name: e['name']))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
              30.sbH,
            ],
          ),
        ),
        if (widget.item?.restaurantProduct?.status == 'hide')
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.greyColor.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'productNotAvailable'.tr,
                  style: AppTextStyle.text16BS().copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Map<String, dynamic>> getProductClean(Items? item) {
    List<Map<String, dynamic>> cleanList = [];

    if (item?.restaurantProduct?.extraClean != null && item?.restaurantProduct?.extraClean != 0) {
      cleanList.add({'id': 0, 'name': 'clean'.tr});
    }
    if (item?.restaurantProduct?.extraClear != null && item?.restaurantProduct?.extraClear != 0) {
      cleanList.add({'id': 1, 'name': 'clear'.tr});
    }
    if (item?.restaurantProduct?.extraVacuim != null && item?.restaurantProduct?.extraVacuim != 0) {
      cleanList.add({'id': 2, 'name': 'vacuum'.tr});
    }

    if (item?.restaurantProduct?.extraLarge != null && item?.restaurantProduct?.extraLarge != 0) {
      cleanList.add({'id': 3, 'name': 'large'.tr});
    }

    if (item?.restaurantProduct?.extraMedium != null && item?.restaurantProduct?.extraMedium != 0) {
      cleanList.add({'id': 4, 'name': 'medium'.tr});
    }

    if (item?.restaurantProduct?.extraCombo != null && item?.restaurantProduct?.extraCombo != 0) {
      cleanList.add({'id': 5, 'name': 'combo'.tr});
    }
    // cleanList.add({
    //   "id": item?.restaurantProduct?.productPrice,
    //   "name": 'full'.tr,
    // });
    return cleanList;
  }

  String? getProductFeatureName(String? productFeatureName) {
    switch (productFeatureName) {
      case 'kilo':
        return 'kilo'.tr;
      case 'half':
        return 'half'.tr;
      case 'quarter':
        return 'quarter'.tr;
      default:
        return '';
    }
  }

  String? getProductCleanName(String? productClean) {
    switch (productClean) {
      case 'extra_clean':
        return 'clean'.tr;
      case 'extra_clear':
        return 'clear'.tr;
      case 'extra_large':
        return 'large'.tr;
      case 'extra_medium':
        return 'medium'.tr;
      case 'extra_vacuim':
        return 'vacuum'.tr;
      case 'extra_combo':
        return 'combo'.tr;
      default:
        return 'full'.tr;
    }
  }

  num? getProductCleanPrice(String? productClean, Items? item) {
    if (productClean == 'clean'.tr) {
      return item?.restaurantProduct?.extraClean;
    } else if (productClean == 'clear'.tr) {
      return item?.restaurantProduct?.extraClear;
    } else if (productClean == 'large'.tr) {
      return item?.restaurantProduct?.extraLarge;
    } else if (productClean == 'medium'.tr) {
      return item?.restaurantProduct?.extraMedium;
    } else if (productClean == 'vacuum'.tr) {
      return item?.restaurantProduct?.extraVacuim;
    } else if (productClean == 'combo'.tr) {
      return item?.restaurantProduct?.extraCombo;
    } else {
      return 0;
    }
  }

  String? calculatePrice({
    required int? quantity,
    required num? productPrice,
    required String? productQuantity,
    required num extraPrice,
  }) {
    if (quantity != null && productPrice != null) {
      return ((quantity * (productPrice + extraPrice)) *
              (productQuantity == 'kilo'
                  ? 1
                  : productQuantity == 'half'
                      ? 0.5
                      : productQuantity == 'quarter'
                          ? 0.25
                          : 1))
          .toString();
    }
    return null;
  }

  int? getProductFeatureId(String? productFeatureName, Items item) {
    int? productFeatureId;
    if (productFeatureName == 'large'.tr) {
      productFeatureId = item.restaurantProduct?.features?.firstWhere((element) => element.name == 'large').id ?? 0;
    } else if (productFeatureName == 'medium'.tr) {
      productFeatureId = item.restaurantProduct?.features?.firstWhere((element) => element.name == 'medium').id ?? 0;
    }
    // else if (productFeatureName == 'vacuum'.tr) {
    //   productFeatureId = item.restaurantProduct?.features
    //           ?.firstWhere((element) => element.name == 'vacuim')
    //           .id ??
    //       0;
    // }
    else if (productFeatureName == 'combo'.tr) {
      productFeatureId = item.restaurantProduct?.features?.firstWhere((element) => element.name == 'combo').id ?? 0;
    } else if (productFeatureName == 'kilo') {
      productFeatureId = item.restaurantProduct?.features?.firstWhere((element) => element.name == 'kilo').id ?? 0;
    } else if (productFeatureName == 'half') {
      productFeatureId = item.restaurantProduct?.features?.firstWhere((element) => element.name == 'half').id ?? 0;
    } else if (productFeatureName == 'quarter') {
      productFeatureId = item.restaurantProduct?.features?.firstWhere((element) => element.name == 'quarter').id ?? 0;
    }

    return productFeatureId;
  }

  String? getProductFeature(String? productFeatureName) {
    String? productFeatureTranslatedName;
    if (productFeatureName == 'large'.tr) {
      productFeatureTranslatedName = 'large';
    } else if (productFeatureName == 'medium'.tr) {
      productFeatureTranslatedName = 'medium';
    } else if (productFeatureName == 'vacuum'.tr) {
      productFeatureTranslatedName = 'vacuim';
    } else if (productFeatureName == 'combo'.tr) {
      productFeatureTranslatedName = 'combo';
    } else if (productFeatureName == 'clean'.tr) {
      productFeatureTranslatedName = 'extra_clean';
    } else if (productFeatureName == 'clear'.tr) {
      productFeatureTranslatedName = 'extra_clear';
    }

    return productFeatureTranslatedName;
  }
}
