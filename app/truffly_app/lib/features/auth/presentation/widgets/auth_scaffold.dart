import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.children,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.scrollable = true,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding =
        padding ??
        const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          10,
          AppSpacing.screenHorizontal,
          0,
        );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final content = Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxWidth: 440,
                  ),
                  child: Column(
                    crossAxisAlignment: crossAxisAlignment,
                    children: children,
                  ),
                ),
              );

              return scrollable
                  ? SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: resolvedPadding,
                      child: content,
                    )
                  : Padding(padding: resolvedPadding, child: content);
            },
          ),
        ),
      ),
    );
  }
}
