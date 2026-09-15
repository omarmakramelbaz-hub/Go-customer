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

class ContractDeliveryArgs {
  final String? name;
  final String? nationalId;
  final String? drivingLicenseNo;
  final String? mobile;
  final String? email;
  final String? vodafoneCash;
  final VoidCallback onConfirm;
  ContractDeliveryArgs({
    required this.onConfirm,
    required this.name,
    required this.nationalId,
    required this.drivingLicenseNo,
    required this.mobile,
    required this.email,
    required this.vodafoneCash,
  });
}

class ContractDeliveryScreen extends StatelessWidget {
  final ContractDeliveryArgs args;
  static const String routeName = 'ContractDeliveryScreen';
  const ContractDeliveryScreen({super.key, required this.args});

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
          ..getContract(typeContract: 'delegate'),
        child: PageContainer(
          bottom: false,
          child: Consumer<VendorAndDeliveryController>(
            builder: (BuildContext context, vendorAndDeliveryController, _) {
              String? contractTemplate = vendorAndDeliveryController.contract?.template;

              final Map<String, String> data = {
                '[contractDate]': DateMethods.formatToDate(DateTime.now().toString()),
                '[vendorName]': args.name ?? '',
                '[vendorNationalid]': args.nationalId ?? '',
                '[vendorDrivingLicenseNo]': args.drivingLicenseNo ?? '',
                '[vendorMobile]': args.mobile ?? '',
                '[vendorEmail]': args.email ?? '',
                '[vendorVodafoneCash]': args.vodafoneCash ?? '',
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
