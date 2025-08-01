import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/categoria_model.dart';
import '../../core/error/exceptions.dart';

abstract class CategoriaRemoteDataSource {
  Future<List<CategoriaModel>> getCategorias();
  Future<CategoriaModel> getCategoriaById(String id);
  Future<CategoriaModel> createCategoria(CategoriaModel categoria);
  Future<CategoriaModel> updateCategoria(CategoriaModel categoria);
  Future<void> deleteCategoria(String id);
  Stream<List<CategoriaModel>> watchCategorias();
}

class CategoriaRemoteDataSourceImpl implements CategoriaRemoteDataSource {
  final SupabaseClient supabaseClient;
  static const String tableName = 'categoria';

  CategoriaRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<CategoriaModel>> getCategorias() async {
    try {
      final response = await supabaseClient
          .from(tableName)
          .select()
          .order('ordem');

      return response
          .map<CategoriaModel>((json) => CategoriaModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CategoriaModel> getCategoriaById(String id) async {
    try {
      final response = await supabaseClient
          .from(tableName)
          .select()
          .eq('id', id)
          .single();

      return CategoriaModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException('Categoria não encontrada');
      }
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CategoriaModel> createCategoria(CategoriaModel categoria) async {
    try {
      final response = await supabaseClient
          .from(tableName)
          .insert(categoria.toJson())
          .select()
          .single();

      return CategoriaModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CategoriaModel> updateCategoria(CategoriaModel categoria) async {
    try {
      final response = await supabaseClient
          .from(tableName)
          .update(categoria.toJson())
          .eq('id', categoria.id)
          .select()
          .single();

      return CategoriaModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteCategoria(String id) async {
    try {
      await supabaseClient
          .from(tableName)
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<CategoriaModel>> watchCategorias() {
    return supabaseClient
        .from(tableName)
        .stream(primaryKey: ['id'])
        .order('ordem')
        .map((data) => data
            .map<CategoriaModel>((json) => CategoriaModel.fromJson(json))
            .toList());
  }
}