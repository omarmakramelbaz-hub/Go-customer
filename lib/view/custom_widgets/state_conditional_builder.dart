import 'package:flutter/material.dart';

class StateConditionalBuilder extends StatelessWidget implements PreferredSizeWidget {
  final bool loadingCondition, errorCondition;
  final WidgetBuilder loadingBuilder, errorBuilder;
  final WidgetBuilder? fallback;

  const StateConditionalBuilder({
    super.key,
    required this.loadingCondition,
    required this.errorCondition,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (loadingCondition) {
      return loadingBuilder(context);
    } else {
      if (errorCondition) {
        return errorBuilder(context);
      } else {
        if (fallback != null) {
          return fallback!(context);
        } else {
          return const SizedBox.shrink();
        }
      }
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MultiStateConditionalBuilder extends StatelessWidget {
  final List<ConditionBuilder> conditions;
  final WidgetBuilder fallback;

  const MultiStateConditionalBuilder({super.key, required this.conditions, required this.fallback});

  @override
  Widget build(BuildContext context) {
    for (final condition in conditions) {
      if (condition.when) return condition.builder(context);
    }
    return fallback(context);
  }
}

class ConditionBuilder {
  final bool when;
  final WidgetBuilder builder;

  ConditionBuilder({required this.when, required this.builder});
}

ConditionBuilder condition({required bool when, required WidgetBuilder builder}) {
  return ConditionBuilder(when: when, builder: builder);
}
