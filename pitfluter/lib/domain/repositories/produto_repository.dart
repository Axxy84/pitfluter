import 'package:dartz/dartz.dart';
import '../entities/produto.dart';
import '../entities/produto_preco.dart';
import '../../core/error/failures.dart';

abstract class ProdutoRepository {
  Future<Either<Failure, List<Produto>>> getProdutos();
  Future<Either<Failure, List<Produto>>> getProdutosByCategoria(int categoriaId);
  Future<Either<Failure, Produto>> getProdutoById(String id);
  Future<Either<Failure, List<ProdutoPreco>>> getPrecosProduto(int produtoId);
  Future<Either<Failure, Produto>> createProduto(Produto produto);
  Future<Either<Failure, Produto>> updateProduto(Produto produto);
  Future<Either<Failure, void>> deleteProduto(String id);
  Stream<List<Produto>> watchProdutos();
  Stream<List<Produto>> watchProdutosByCategoria(int categoriaId);
}