import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigation State
class NavigationState {
  final int currentIndex;
  final String currentRoute;

  NavigationState({this.currentIndex = 0, this.currentRoute = '/home'});

  NavigationState copyWith({int? currentIndex, String? currentRoute}) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      currentRoute: currentRoute ?? this.currentRoute,
    );
  }
}

/// Navigation Notifier
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState());

  void setIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void setRoute(String route) {
    state = state.copyWith(currentRoute: route);
  }

  void reset() {
    state = NavigationState();
  }
}

/// Navigation Provider
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier();
    });

/// Page Controller Provider
final pageControllerProvider = Provider<PageController>((ref) {
  return PageController();
});
