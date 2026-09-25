import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../helpers/identity/go_customer_identity.dart';

class GoDriveBrand extends StatelessWidget {
  const GoDriveBrand({super.key, this.size = 28, this.light = false});
  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) => Semantics(
    label: GoCustomerIdentity.displayName,
    image: true,
    child: SvgPicture.asset(
      light ? GoCustomerIdentity.lightLogoAsset : GoCustomerIdentity.logoAsset,
      height: size * 1.35,
      width: size * 2.5,
      fit: BoxFit.contain,
    ),
  );
}
