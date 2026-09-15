import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/date_methods.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/page_container/page_container.dart';
import '../../my_account/account_app_bar/account_app_bar.dart';
import '../controller/vendor_and_delivery_controller.dart';

class ContractVendorArgs {
  final String? vendorName;
  final String? vendorOwnerName;
  final String? vendorNational;
  final String? vendorCommercialRegistrationNo;
  final String? vendorTaxNo;
  final String? vendorMobile;
  final String? vendorEmail;
  final String? vendorVodafoneCash;

  final VoidCallback onConfirm;
  ContractVendorArgs({
    required this.onConfirm,
    required this.vendorName,
    required this.vendorOwnerName,
    required this.vendorNational,
    required this.vendorCommercialRegistrationNo,
    required this.vendorTaxNo,
    required this.vendorMobile,
    required this.vendorEmail,
    required this.vendorVodafoneCash,
  });
}

class ContractVendorScreen extends StatelessWidget {
  final ContractVendorArgs args;
  static const String routeName = 'ContractVendorScreen';
  const ContractVendorScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: CustomButton(
          text: 'confirm'.tr,
          onPressed: () {
            args.onConfirm.call();
          },
        ),
      ),
      body: ChangeNotifierProvider(
        create: (context) => VendorAndDeliveryController()
          ..initialContract()
          ..getContract(typeContract: 'vendor'),
        child: PageContainer(
          bottom: false,
          child: Consumer<VendorAndDeliveryController>(
            builder: (BuildContext context, vendorAndDeliveryController, _) {
              String? contractTemplate = vendorAndDeliveryController.contract?.template;

              final Map<String, String> data = {
                '[contractDate]': DateMethods.formatToDate(DateTime.now().toString()),
                '[vendorName]': args.vendorName ?? '',
                '[vendorNationalid]': args.vendorNational ?? '',
                '[vendorOwnerName]': args.vendorOwnerName ?? '',
                '[vendorCommercialRegistrationNo]': args.vendorCommercialRegistrationNo ?? '',
                '[vendorTaxNo]': args.vendorTaxNo ?? '',
                '[vendorMobile]': args.vendorMobile ?? '',
                '[vendorEmail]': args.vendorEmail ?? '',
                '[vendorVodafoneCash]': args.vendorVodafoneCash ?? '',
              };

              data.forEach((key, value) {
                contractTemplate = contractTemplate?.replaceAll(key, value);
              });

              return ApiResponseWidget(
                apiResponse: vendorAndDeliveryController.contractApiResponse,
                onReload: () => vendorAndDeliveryController.getContract(typeContract: 'delegate'),
                isEmpty: vendorAndDeliveryController.contract == null,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    children: [
                      CustomAccountAppBar(title: 'contract'.tr),
                      Html(data: contractTemplate ?? ''),
                      const SizedBox(height: 70),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
