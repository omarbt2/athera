import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/monument.dart';
import '../domain/entities/filter_params.dart';
import '../data/repositories/monuments_repository.dart';
import '../../core/providers/common_providers.dart';

// Repository Provider
final monumentsRepositoryProvider = Provider<IMonumentsRepository>((ref) {
  return MonumentsRepository();
});

// 1. All monuments - Fix: added pagination (limit 20)
final monumentsProvider = FutureProvider<List<Monument>>((ref) async {
  final repository = ref.watch(monumentsRepositoryProvider);
  // Increased limit to 200 to show more Supabase data and fix "data not showing" issue
  return repository.getAllMonuments(limit: 200);
});

// 2. Filtered monuments
final filteredMonumentsProvider = FutureProvider.family<List<Monument>, FilterParams>((ref, params) async {
  final allMonuments = await ref.watch(monumentsProvider.future);
  return allMonuments.where((m) {
    bool matches = true;
    if (params.region != null) matches = matches && m.region == params.region;
    if (params.category != null) matches = matches && m.category == params.category;
    if (params.onlyUNESCO) matches = matches && m.isUNESCO;
    if (params.onlyPremium) matches = matches && m.isPremium;
    return matches;
  }).toList();
});

// 3. Featured — Fix #12: highest rated monument
final featuredMonumentProvider = FutureProvider<Monument>((ref) async {
  final allMonuments = await ref.watch(monumentsProvider.future);
  if (allMonuments.isEmpty) throw Exception('No monuments found');
  final sorted = [...allMonuments]..sort((a, b) => b.rating.compareTo(a.rating));
  return sorted.first;
});

// 4. Saved monuments — Fix #4: persisted with SharedPreferences
class SavedMonumentsNotifier extends Notifier<List<Monument>> {
  static const _key = 'saved_monuments_ids';

  @override
  List<Monument> build() {
    _loadSaved();
    return [];
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    if (ids.isEmpty) return;

    // Load all monuments then filter by saved IDs
    final allMonuments = await ref.read(monumentsProvider.future);
    final savedList = allMonuments.where((m) => ids.contains(m.id)).toList();
    state = savedList;
  }

  Future<void> _persistSaved() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.map((m) => m.id).toList());
  }

  void toggleSaved(Monument monument) {
    if (state.any((m) => m.id == monument.id)) {
      state = state.where((m) => m.id != monument.id).toList();
    } else {
      state = [...state, monument];
    }
    _persistSaved();
  }
}

final savedMonumentsProvider = NotifierProvider<SavedMonumentsNotifier, List<Monument>>(() {
  return SavedMonumentsNotifier();
});

// 5. Search
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Monument>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  final allMonuments = await ref.watch(monumentsProvider.future);
  return allMonuments.where((m) {
    final lowerQuery = query.toLowerCase();
    return m.name.ar.toLowerCase().contains(lowerQuery) ||
        m.name.en.toLowerCase().contains(lowerQuery) ||
        m.name.fr.toLowerCase().contains(lowerQuery);
  }).toList();
});

// 6. Monument Detail
final monumentDetailProvider = FutureProvider.family<Monument, String>((ref, id) async {
  final repository = ref.watch(monumentsRepositoryProvider);
  return repository.getMonumentById(id);
});

// 7. Is Saved
final isMonumentSavedProvider = Provider.family<bool, String>((ref, id) {
  final saved = ref.watch(savedMonumentsProvider);
  return saved.any((m) => m.id == id);
});

// 8. Category filter provider (for Fix #19)
final selectedCategoryProvider = StateProvider<String?>((ref) => null);
