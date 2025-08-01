import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/repositories/categoria_repository.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
import '../datasources/categoria_remote_datasource.dart';
import '../models/categoria_model.dart';

class CategoriaRepositoryImpl implements CategoriaRepository {
  final CategoriaRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CategoriaRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Categoria>>> getCategorias() async {
    if (await networkInfo.isConnected) {
      try {
        final categorias = await remoteDataSource.getCategorias();
        return Right(categorias);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } on SocketException {
        return const Left(NetworkFailure('Sem conexão com a internet'));
      } catch (e) {
        return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, Categoria>> getCategoriaById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final categoria = await remoteDataSource.getCategoriaById(id);
        return Right(categoria);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } on SocketException {
        return const Left(NetworkFailure('Sem conexão com a internet'));
      } catch (e) {
        return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, Categoria>> createCategoria(Categoria categoria) async {
    if (await networkInfo.isConnected) {
      try {
        final categoriaModel = CategoriaModel.fromEntity(categoria);
        final createdCategoria = await remoteDataSource.createCategoria(categoriaModel);
        return Right(createdCategoria);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on SocketException {
        return const Left(NetworkFailure('Sem conexão com a internet'));
      } catch (e) {
        return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, Categoria>> updateCategoria(Categoria categoria) async {
    if (await networkInfo.isConnected) {
      try {
        final categoriaModel = CategoriaModel.fromEntity(categoria);
        final updatedCategoria = await remoteDataSource.updateCategoria(categoriaModel);
        return Right(updatedCategoria);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } on SocketException {
        return const Left(NetworkFailure('Sem conexão com a internet'));
      } catch (e) {
        return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('Sem conexão com a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategoria(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteCategoria(id);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } on SocketException {
        return const Left(NetworkFailure('Sem conexão com a internet'));
      } catch (e) {
        return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('Sem conexão com a internet'));
    }
  }

  @override
  Stream<List<Categoria>> watchCategorias() {
    return remoteDataSource.watchCategorias().cast<List<Categoria>>();
  }
}