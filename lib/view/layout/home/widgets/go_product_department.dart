import 'package:flutter/material.dart';

import '../../../../helpers/theme/go_design_tokens.dart';
import '../../../../go_stores/customer_store_screen.dart';

enum GoProductDepartment {
  supermarket('سوبر ماركت', 'Supermarkets', Icons.shopping_basket_outlined, 0),
  restaurant('مطاعم', 'Restaurants', Icons.restaurant_outlined, 2),
  pharmacy('صيدليات', 'Pharmacies', Icons.local_pharmacy_outlined, 1),
  clinic('عيادات', 'Clinics', Icons.medical_services_outlined, -1);

  const GoProductDepartment(this.ar, this.en, this.icon, this.imageIndex);
  final String ar;
  final String en;
  final IconData icon;
  final int imageIndex;

  String title(bool isArabic) => isArabic ? ar : en;
  bool matches(String query) =>
      ar.contains(query) || en.toLowerCase().contains(query);
}

/// Every department opens the live GO merchant catalog.
class GoProductDepartmentCard extends StatelessWidget {
  const GoProductDepartmentCard({
    super.key,
    required this.department,
    required this.isArabic,
  });

  final GoProductDepartment department;
  final bool isArabic;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerStoreScreen(
          kind: department.name,
          title: department.title(isArabic),
        ),
      ),
    ),
    child: Container(
      key: ValueKey('go-department-card-${department.name}'),
      decoration: BoxDecoration(
        color: GoDesign.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GoDesign.border),
        boxShadow: GoDesign.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 128,
            child: Stack(
              fit: StackFit.expand,
              children: [
                GoDepartmentPhoto(department: department),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0x55000000)],
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 10,
                  end: 10,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: GoDesign.paper,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      department.icon,
                      size: 19,
                      color: GoDesign.orange,
                    ),
                  ),
                ),
                PositionedDirectional(
                  bottom: 10,
                  start: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: GoDesign.paper,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      isArabic ? 'تصفح القسم' : 'Browse department',
                      style: const TextStyle(
                        color: GoDesign.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      size: 19,
                      color: GoDesign.orange,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        department.title(isArabic),
                        style: const TextStyle(
                          color: GoDesign.ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  isArabic
                      ? 'افتح القسم للاطلاع على المتاجر والخدمات المتاحة.'
                      : 'Open the department to browse its stores and services.',
                  style: const TextStyle(
                    color: GoDesign.authMuted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class GoDepartmentPhoto extends StatelessWidget {
  const GoDepartmentPhoto({super.key, required this.department});
  final GoProductDepartment department;

  @override
  Widget build(BuildContext context) => department == GoProductDepartment.clinic
      ? const ColoredBox(
          color: Color(0xFFE4F3EF),
          child: Center(
            child: Icon(
              Icons.local_hospital_rounded,
              size: 76,
              color: Color(0xFF22756C),
            ),
          ),
        )
      : ClipRect(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final panel = constraints.maxWidth > constraints.maxHeight
                  ? constraints.maxWidth
                  : constraints.maxHeight;
              return Stack(
                children: [
                  Positioned(
                    width: panel * 3,
                    height: panel,
                    left:
                        (constraints.maxWidth - panel) / 2 -
                        department.imageIndex * panel,
                    top: (constraints.maxHeight - panel) / 2,
                    child: Image.asset(
                      'assets/brand/go_product_departments.webp',
                      fit: BoxFit.fill,
                      excludeFromSemantics: true,
                      errorBuilder: (_, __, ___) => ColoredBox(
                        color: GoDesign.orangeTint,
                        child: Icon(department.icon, color: GoDesign.orange),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
}
