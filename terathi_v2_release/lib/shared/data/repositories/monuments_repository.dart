import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/monument.dart';

abstract class IMonumentsRepository {
  Future<List<Monument>> getAllMonuments({int? limit, int? offset});
  Future<Monument> getMonumentById(String id);
}

class MonumentsRepository implements IMonumentsRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<Monument>> getAllMonuments({int? limit, int? offset}) async {
    try {
      dynamic query = _supabase.from('monuments_app').select();
      
      if (limit != null) {
        final from = offset ?? 0;
        final to = from + limit - 1;
        query = (query as dynamic).range(from, to);
      }
      
      // Order by ID or rating to ensure consistent results during pagination
      final response = await query.order('id', ascending: true);
      
      return (response as List).map((json) => Monument.fromJson(json)).toList();
    } catch (e) {
      // Return empty list on error to prevent UI crash
      return [];
    }
  }

  @override
  Future<Monument> getMonumentById(String id) async {
    final response = await _supabase.from('monuments_app').select().eq('id', id).single();
    return Monument.fromJson(response);
  }
}
