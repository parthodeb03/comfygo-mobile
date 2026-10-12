import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Single back affordance used by every screen.
///
/// Pops the current route when there is history to pop, otherwise returns to
/// the home screen. Without the fallback, a page opened with `context.go(...)`
/// (or reached after a redirect) leaves the user with a back arrow that does
/// nothing.
void goBack(BuildContext context) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
  } else {
    router.go('/');
  }
}
