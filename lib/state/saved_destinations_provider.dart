import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The category selected on Home / Explore.
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

/// Destination ids the traveller has saved.
///
/// Persisted locally so the Saved tab survives restarts even when the API is
/// unreachable.
class SavedDestinationsNotifier extends StateNotifier<Set<int>> {
  static const String _storageKey = 'comfy_saved_destinations';

  SavedDestinationsNotifier() : super(<int>{}) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_storageKey);
      if (stored == null) return;
      final ids = stored.map(int.tryParse).whereType<int>().toSet();
      if (mounted) state = ids;
    } catch (_) {
      // Storage is optional; an unreadable cache simply starts empty.
    }
  }

  bool isSaved(int id) => state.contains(id);

  Future<void> toggle(int id) async {
    final next = <int>{...state};
    if (!next.add(id)) next.remove(id);
    state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _storageKey,
        next.map((value) => value.toString()).toList(),
      );
    } catch (_) {
      // Keep the in-memory state even if persistence fails.
    }
  }
}

final savedDestinationsProvider =
    StateNotifierProvider<SavedDestinationsNotifier, Set<int>>((ref) {
      return SavedDestinationsNotifier();
    });
