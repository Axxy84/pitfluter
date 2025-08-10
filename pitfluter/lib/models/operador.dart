class Operador {
  final int id;
  final String nome;
  final String? cpf;
  final String? email;
  final String nivelAcesso;
  final bool ativo;
  final DateTime dataCriacao;
  final DateTime? dataAtualizacao;
  final DateTime? ultimoLogin;
  final int? createdBy;
  final String? observacoes;

  Operador({
    required this.id,
    required this.nome,
    this.cpf,
    this.email,
    required this.nivelAcesso,
    required this.ativo,
    required this.dataCriacao,
    this.dataAtualizacao,
    this.ultimoLogin,
    this.createdBy,
    this.observacoes,
  });

  factory Operador.fromJson(Map<String, dynamic> json) {
    return Operador(
      id: json['id'] as int,
      nome: json['nome'] as String,
      cpf: json['cpf'] as String?,
      email: json['email'] as String?,
      nivelAcesso: json['nivel_acesso'] as String? ?? 'operador',
      ativo: json['ativo'] as bool? ?? true,
      dataCriacao: DateTime.parse(json['data_criacao'] as String),
      dataAtualizacao: json['data_atualizacao'] != null 
          ? DateTime.parse(json['data_atualizacao'] as String)
          : null,
      ultimoLogin: json['ultimo_login'] != null 
          ? DateTime.parse(json['ultimo_login'] as String)
          : null,
      createdBy: json['created_by'] as int?,
      observacoes: json['observacoes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cpf': cpf,
      'email': email,
      'nivel_acesso': nivelAcesso,
      'ativo': ativo,
      'data_criacao': dataCriacao.toIso8601String(),
      'data_atualizacao': dataAtualizacao?.toIso8601String(),
      'ultimo_login': ultimoLogin?.toIso8601String(),
      'created_by': createdBy,
      'observacoes': observacoes,
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = <String, dynamic>{
      'nome': nome,
      'nivel_acesso': nivelAcesso,
      'ativo': ativo,
    };
    
    if (cpf != null) json['cpf'] = cpf;
    if (email != null) json['email'] = email;
    if (createdBy != null) json['created_by'] = createdBy;
    if (observacoes != null) json['observacoes'] = observacoes;
    
    return json;
  }

  Operador copyWith({
    int? id,
    String? nome,
    String? cpf,
    String? email,
    String? nivelAcesso,
    bool? ativo,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
    DateTime? ultimoLogin,
    int? createdBy,
    String? observacoes,
  }) {
    return Operador(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      nivelAcesso: nivelAcesso ?? this.nivelAcesso,
      ativo: ativo ?? this.ativo,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      ultimoLogin: ultimoLogin ?? this.ultimoLogin,
      createdBy: createdBy ?? this.createdBy,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  bool get isAdmin => nivelAcesso == 'admin';
  bool get isGerente => nivelAcesso == 'gerente';
  bool get isOperador => nivelAcesso == 'operador';
  
  bool get podeGerenciarOperadores => isAdmin || isGerente;
  bool get podeAbrirCaixa => ativo;
  bool get podeFecharCaixa => ativo;

  @override
  String toString() {
    return 'Operador(id: $id, nome: $nome, nivelAcesso: $nivelAcesso, ativo: $ativo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Operador && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}