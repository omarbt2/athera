import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch all records from a table
  Future<List<Map<String, dynamic>>> fetchAll(String table) async {
    try {
      final response = await _client.from(table).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch records from $table: $e');
    }
  }

  // Insert a record into a table
  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data) async {
    try {
      final response = await _client.from(table).insert(data).select().single();
      return response;
    } catch (e) {
      throw Exception('Failed to insert record into $table: $e');
    }
  }

  // Update a record in a table by id
  Future<Map<String, dynamic>> update(String table, String id, Map<String, dynamic> data) async {
    try {
      final response = await _client.from(table).update(data).eq('id', id).select().single();
      return response;
    } catch (e) {
      throw Exception('Failed to update record in $table: $e');
    }
  }

  // Delete a record from a table by id
  Future<void> delete(String table, String id) async {
    try {
      await _client.from(table).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete record from $table: $e');
    }
  }
}
