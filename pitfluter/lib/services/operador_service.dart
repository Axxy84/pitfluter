import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/operador.dart';

class OperadorService {
  final _supabase = Supabase.instance.client;

  /// Buscar todos os operadores ativos
  Future<List<Operador>> buscarOperadoresAtivos() async {
    try {
      final response = await _supabase
          .from('operadores')
          .select()
          .eq('ativo', true)
          .order('nome');

      return response.map<Operador>((json) => Operador.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar operadores: $e');
    }
  }

  /// Buscar todos os operadores (ativos e inativos)
  Future<List<Operador>> buscarTodosOperadores() async {
    try {
      final response = await _supabase
          .from('operadores')
          .select()
          .order('nome');

      return response.map<Operador>((json) => Operador.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar todos os operadores: $e');
    }
  }

  /// Buscar operador por ID
  Future<Operador?> buscarOperadorPorId(int id) async {
    try {
      final response = await _supabase
          .from('operadores')
          .select()
          .eq('id', id)
          .limit(1);

      if (response.isEmpty) return null;
      
      return Operador.fromJson(response.first);
    } catch (e) {
      throw Exception('Erro ao buscar operador: $e');
    }
  }

  /// Buscar operador por nome
  Future<Operador?> buscarOperadorPorNome(String nome) async {
    try {
      final response = await _supabase
          .from('operadores')
          .select()
          .eq('nome', nome)
          .eq('ativo', true)
          .limit(1);

      if (response.isEmpty) return null;
      
      return Operador.fromJson(response.first);
    } catch (e) {
      throw Exception('Erro ao buscar operador por nome: $e');
    }
  }

  /// Buscar operador por CPF
  Future<Operador?> buscarOperadorPorCpf(String cpf) async {
    try {
      final response = await _supabase
          .from('operadores')
          .select()
          .eq('cpf', cpf)
          .limit(1);

      if (response.isEmpty) return null;
      
      return Operador.fromJson(response.first);
    } catch (e) {
      throw Exception('Erro ao buscar operador por CPF: $e');
    }
  }

  /// Criar novo operador
  Future<Operador> criarOperador({
    required String nome,
    String? cpf,
    String? email,
    String nivelAcesso = 'operador',
    bool ativo = true,
    int? createdBy,
    String? observacoes,
  }) async {
    try {
      // Validar se CPF já existe (se fornecido)
      if (cpf != null && cpf.isNotEmpty) {
        final existente = await buscarOperadorPorCpf(cpf);
        if (existente != null) {
          throw Exception('Já existe um operador com este CPF');
        }
      }

      final operador = Operador(
        id: 0, // Será definido pelo banco
        nome: nome,
        cpf: cpf,
        email: email,
        nivelAcesso: nivelAcesso,
        ativo: ativo,
        dataCriacao: DateTime.now(),
        createdBy: createdBy,
        observacoes: observacoes,
      );

      final response = await _supabase
          .from('operadores')
          .insert(operador.toInsertJson())
          .select()
          .single();

      return Operador.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar operador: $e');
    }
  }

  /// Atualizar operador
  Future<Operador> atualizarOperador(int id, {
    String? nome,
    String? cpf,
    String? email,
    String? nivelAcesso,
    bool? ativo,
    String? observacoes,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (nome != null) updates['nome'] = nome;
      if (cpf != null) updates['cpf'] = cpf;
      if (email != null) updates['email'] = email;
      if (nivelAcesso != null) updates['nivel_acesso'] = nivelAcesso;
      if (ativo != null) updates['ativo'] = ativo;
      if (observacoes != null) updates['observacoes'] = observacoes;

      if (updates.isEmpty) {
        throw Exception('Nenhum campo para atualizar');
      }

      // Verificar se CPF já existe em outro operador (se fornecido)
      if (cpf != null && cpf.isNotEmpty) {
        final existente = await buscarOperadorPorCpf(cpf);
        if (existente != null && existente.id != id) {
          throw Exception('Já existe outro operador com este CPF');
        }
      }

      final response = await _supabase
          .from('operadores')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return Operador.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar operador: $e');
    }
  }

  /// Desativar operador (não remove do banco)
  Future<void> desativarOperador(int id) async {
    try {
      await _supabase
          .from('operadores')
          .update({'ativo': false})
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao desativar operador: $e');
    }
  }

  /// Ativar operador
  Future<void> ativarOperador(int id) async {
    try {
      await _supabase
          .from('operadores')
          .update({'ativo': true})
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao ativar operador: $e');
    }
  }

  /// Registrar login do operador
  Future<void> registrarLogin(int operadorId) async {
    try {
      await _supabase
          .from('operadores')
          .update({'ultimo_login': DateTime.now().toIso8601String()})
          .eq('id', operadorId);
    } catch (e) {
      throw Exception('Erro ao registrar login: $e');
    }
  }

  /// Validar permissões do operador
  bool podeAbrirCaixa(Operador operador) {
    return operador.ativo;
  }

  bool podeFecharCaixa(Operador operador) {
    return operador.ativo;
  }

  bool podeGerenciarOperadores(Operador operador) {
    return operador.ativo && (operador.isAdmin || operador.isGerente);
  }

  bool podeGerenciarRelatorios(Operador operador) {
    return operador.ativo && (operador.isAdmin || operador.isGerente);
  }

  /// Buscar operadores por nível de acesso
  Future<List<Operador>> buscarOperadoresPorNivel(String nivelAcesso) async {
    try {
      final response = await _supabase
          .from('operadores')
          .select()
          .eq('nivel_acesso', nivelAcesso)
          .eq('ativo', true)
          .order('nome');

      return response.map<Operador>((json) => Operador.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar operadores por nível: $e');
    }
  }

  /// Contar operadores ativos
  Future<int> contarOperadoresAtivos() async {
    try {
      final response = await _supabase
          .from('operadores')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('ativo', true);

      return response.count ?? 0;
    } catch (e) {
      throw Exception('Erro ao contar operadores: $e');
    }
  }
}