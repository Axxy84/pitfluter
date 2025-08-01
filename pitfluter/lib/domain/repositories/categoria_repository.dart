import 'package:dartz/dartz.dart';
import '../entities/categoria.dart';
import '../../core/error/failures.dart';

abstract class CategoriaRepository {
  Future<Either<Failure, List<Categoria>>> getCategorias();
  Future<Either<Failure, Categoria>> getCategoriaById(String id);
  Future<Either<Failure, Categoria>> createCategoria(Categoria categoria);
  Future<Either<Failure, Categoria>> updateCategoria(Categoria categoria);
  Future<Either<Failure, void>> deleteCategoria(String id);
  Stream<List<Categoria>> watchCategorias();
}