import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/caixa.dart';
import '../../domain/entities/movimento_caixa.dart';
import '../../services/relatorio_caixa_service.dart';
import '../../services/caixa_service.dart';

class CaixaScreen extends StatefulWidget {
  const CaixaScreen({super.key});

  @override
  State<CaixaScreen> createState() => _CaixaScreenState();
}

class _CaixaScreenState extends State<CaixaScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CaixaService _caixaService = CaixaService();
  Caixa? caixaAtual;
  List<MovimentoCaixa> movimentacoes = [];
  String filtroSelecionado = 'Todas';
  bool _caixaAberto = false;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _verificarEstadoCaixa();
    // Agendar _carregarDados para depois do build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDados();
    });
  }
  
  Future<void> _verificarEstadoCaixa() async {
    if (!mounted) return;
    
    setState(() {
      _carregando = true;
    });
    
    try {
      final estadoCaixa = await _caixaService.verificarEstadoCaixa();
      
      // Estado do caixa verificado
      
      if (!mounted) return;
      
      setState(() {
        _caixaAberto = estadoCaixa.aberto;
        _carregando = false;
      });
    } catch (e) {
      // Erro ao verificar estado
      if (!mounted) return;
      
      setState(() {
        _carregando = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar estado do caixa: $e')),
      );
    }
  }

  Future<void> _carregarDados() async {
    // Carregando dados do caixa
    
    // Verificar novamente o estado antes de prosseguir
    await _verificarEstadoCaixa();
    
    if (!_caixaAberto) {
      // Caixa não está aberto
      setState(() {
        caixaAtual = null;
        movimentacoes = [];
      });
      
      // Mostrar mensagem clara ao usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Você precisa ABRIR O CAIXA primeiro para registrar vendas!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
      return;
    }
    
    try {
      // Obtendo dados do caixa
      final dadosCaixa = await _caixaService.obterDadosCaixaAtual();
      final estado = dadosCaixa['estado'] as EstadoCaixa;
      final resumo = dadosCaixa['resumo'] as ResumoCaixa;
      
      // Resumo do caixa carregado
      
      // Buscar movimentações reais do período
      final movimentacoesReais = await _buscarMovimentacoesCaixa(estado.id!, estado.dataAbertura!);
      
      if (!mounted) return;
      
      setState(() {
        caixaAtual = Caixa(
          id: estado.id ?? 0,
          dataAbertura: DateTime.parse(estado.dataAbertura!),
          saldoInicial: estado.saldoInicial ?? 0,
          saldoFinal: resumo.saldoFinal,
          totalVendas: resumo.totalVendas,
          totalDinheiro: resumo.totalDinheiro,
          totalCartao: resumo.totalCartao,
          totalPix: resumo.totalPix,
          totalSangrias: 0.0,
          status: StatusCaixa.aberto,
          observacoes: '',
          dataCadastro: DateTime.now().toIso8601String(),
          ultimaAtualizacao: DateTime.now().toIso8601String(),
        );
        
        movimentacoes = movimentacoesReais;
      });
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados do caixa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<List<MovimentoCaixa>> _buscarMovimentacoesCaixa(int caixaId, String dataAbertura) async {
    // Buscando movimentações do caixa
    final movimentacoes = <MovimentoCaixa>[];
    
    // Adicionar abertura de caixa
    final estado = await _caixaService.verificarEstadoCaixa();
    movimentacoes.add(
      MovimentoCaixa(
        id: 1,
        caixaId: caixaId,
        tipo: TipoMovimento.abertura,
        valor: estado.saldoInicial ?? 0,
        formaPagamento: FormaPagamento.dinheiro,
        descricao: 'Abertura de caixa',
        dataHora: DateTime.parse(dataAbertura),
        dataCadastro: dataAbertura,
      ),
    );
    
    try {
      // Buscando vendas do período
      
      // Buscar vendas do período
      final supabase = Supabase.instance.client;
      final vendas = await supabase
          .from('pedidos')
          .select()
          .gte('created_at', dataAbertura)
          .order('created_at');
      
      // Processando vendas encontradas
      
      for (final venda in vendas) {
        
        // Adicionar o tipo de pedido na descrição para facilitar a contagem
        final tipoPedido = venda['tipo'] ?? 'balcao';
        String tipoTexto = '';
        if (tipoPedido == 'entrega' || tipoPedido == 'delivery') {
          tipoTexto = ' (Delivery)';
        } else if (tipoPedido == 'mesa') {
          tipoTexto = ' (Mesa)';
        } else {
          tipoTexto = ' (Balcão)';
        }
        
        movimentacoes.add(
          MovimentoCaixa(
            id: venda['id'],
            caixaId: caixaId,
            tipo: TipoMovimento.venda,
            valor: (venda['total'] ?? 0).toDouble(),
            formaPagamento: _parseFormaPagamento(venda['forma_pagamento']),
            descricao: 'Pedido #${venda['numero'] ?? venda['id']}$tipoTexto',
            dataHora: DateTime.parse(venda['created_at']),
            dataCadastro: venda['created_at'],
          ),
        );
      }
    } catch (e) {
      // Erro ao buscar vendas
      // Tabela pedidos não existe - isso é normal
      // O caixa funcionará apenas com a movimentação de abertura
    }
    
    return movimentacoes;
  }
  
  FormaPagamento _parseFormaPagamento(String? forma) {
    switch (forma) {
      case 'Dinheiro':
        return FormaPagamento.dinheiro;
      case 'Cartão':
        return FormaPagamento.cartao;
      case 'PIX':
        return FormaPagamento.pix;
      default:
        return FormaPagamento.dinheiro;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF5F7FA),
        drawer: _buildDrawer(context),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: _buildDrawer(context),
      body: _caixaAberto ? _buildCaixaAberto() : _buildCaixaFechado(),
    );
  }
  
  Widget _buildCaixaAberto() {
    return Column(
      children: [
        // Header
        _buildHeader(),
        
        // Main Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coluna Esquerda - Resumo
                Expanded(
                  flex: 1,
                    child: SingleChildScrollView(
                      child: _buildResumoCards(),
                    ),
                  ),
                  
                  const SizedBox(width: 24),
                  
                  // Coluna Direita - Movimentações
                  Expanded(
                    flex: 2,
                    child: _buildMovimentacoes(),
                  ),
                ],
              ),
            ),
          ),
        
        // Footer - Ações Rápidas
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    final isAberto = _caixaAberto;
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Botão Menu
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            iconSize: 28,
          ),
          
          const SizedBox(width: 16),
          
          // Ícone de Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAberto ? Colors.green[50] : Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAberto ? Icons.account_balance_wallet : Icons.lock,
              color: isAberto ? Colors.green[600] : Colors.red[600],
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Informações do Caixa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.orange[600],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAberto ? 'CAIXA ABERTO' : 'CAIXA FECHADO',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isAberto ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                ),
                
                if (caixaAtual != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Responsável: João Silva',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 2),
                  Text(
                    'Aberto em: ${DateFormat('dd/MM/yyyy HH:mm').format(caixaAtual!.dataAbertura)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Botão de Ação Principal
          ElevatedButton.icon(
            onPressed: isAberto ? _fecharCaixa : _abrirCaixa,
            icon: Icon(isAberto ? Icons.lock : Icons.lock_open),
            label: Text(isAberto ? 'FECHAR CAIXA' : 'ABRIR CAIXA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isAberto ? Colors.red[600] : Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoCards() {
    return Column(
      children: [
        // Primeira linha - Abertura e Vendas
        Row(
          children: [
            Expanded(
              child: _buildCardResumo(
                titulo: 'Valor de Abertura',
                valor: caixaAtual?.saldoInicial ?? 0.0,
                cor: Colors.blue[600]!,
                icone: Icons.play_circle_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCardResumo(
                titulo: 'Total Vendas',
                valor: caixaAtual?.totalVendas ?? 0.0,
                cor: Colors.green[600]!,
                icone: Icons.trending_up,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Segunda linha - Entradas e Saídas
        Row(
          children: [
            Expanded(
              child: _buildCardResumo(
                titulo: 'Total Entradas',
                valor: (caixaAtual?.totalVendas ?? 0.0),
                cor: Colors.teal[600]!,
                icone: Icons.arrow_upward,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCardResumo(
                titulo: 'Total Saídas',
                valor: caixaAtual?.totalSangrias ?? 0.0,
                cor: Colors.orange[600]!,
                icone: Icons.arrow_downward,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Terceira linha - Esperado e Diferença
        Row(
          children: [
            Expanded(
              child: _buildCardResumo(
                titulo: 'Valor Esperado',
                valor: caixaAtual?.saldoAtual ?? 0.0,
                cor: Colors.purple[600]!,
                icone: Icons.calculate,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCardResumo(
                titulo: 'Diferença',
                valor: caixaAtual?.diferencaCaixa ?? 0.0,
                cor: (caixaAtual?.diferencaCaixa ?? 0.0) >= 0 ? Colors.green[600]! : Colors.red[600]!,
                icone: (caixaAtual?.diferencaCaixa ?? 0.0) >= 0 ? Icons.trending_up : Icons.trending_down,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Quarta linha - Vendas por Tipo
        _buildVendasPorTipo(),
        
        const SizedBox(height: 24),
        
        // Gráfico de Formas de Pagamento
        _buildGraficoFormasPagamento(),
      ],
    );
  }

  Widget _buildCardResumo({
    required String titulo,
    required double valor,
    required Color cor,
    required IconData icone,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icone,
                color: cor,
                size: 24,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_upward,
                  color: cor,
                  size: 16,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            titulo,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoFormasPagamento() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Formas de Pagamento',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Legenda simples
          _buildLegendaItem('Dinheiro', Colors.green[600]!, caixaAtual?.totalDinheiro ?? 0.0),
          const SizedBox(height: 8),
          _buildLegendaItem('Cartão', Colors.blue[600]!, caixaAtual?.totalCartao ?? 0.0),
          const SizedBox(height: 8),
          _buildLegendaItem('PIX', Colors.purple[600]!, caixaAtual?.totalPix ?? 0.0),
        ],
      ),
    );
  }

  Widget _buildLegendaItem(String nome, Color cor, double valor) {
    final total = (caixaAtual?.totalDinheiro ?? 0.0) + (caixaAtual?.totalCartao ?? 0.0) + (caixaAtual?.totalPix ?? 0.0);
    final percentual = total > 0 ? (valor / total * 100) : 0.0;
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            nome,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Text(
          'R\$ ${valor.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${percentual.toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMovimentacoes() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header da lista com filtros
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Movimentações',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Filtros
                ...['Todas', 'Vendas', 'Sangrias', 'Suprimentos'].map((filtro) {
                  final isSelected = filtroSelecionado == filtro;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(filtro),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          filtroSelecionado = filtro;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    ),
                  );
                }),
              ],
            ),
          ),
          
          // Lista de movimentações
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: movimentacoes.length,
              itemBuilder: (context, index) {
                final movimento = movimentacoes[index];
                return _buildItemMovimentacao(movimento);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendasPorTipo() {
    // Calcular vendas por tipo
    int vendasBalcao = 0;
    int vendasDelivery = 0;
    int vendasMesa = 0;
    double totalBalcao = 0.0;
    double totalDelivery = 0.0;
    double totalMesa = 0.0;
    
    for (final movimento in movimentacoes) {
      if (movimento.tipo == TipoMovimento.venda) {
        // Tentar identificar o tipo pela descrição ou buscar no banco
        final descricao = movimento.descricao.toLowerCase();
        
        // Por enquanto vamos usar a descrição, mas idealmente buscaríamos o tipo real
        if (descricao.contains('balcão') || descricao.contains('balcao')) {
          vendasBalcao++;
          totalBalcao += movimento.valor;
        } else if (descricao.contains('delivery') || descricao.contains('entrega')) {
          vendasDelivery++;
          totalDelivery += movimento.valor;
        } else if (descricao.contains('mesa')) {
          vendasMesa++;
          totalMesa += movimento.valor;
        } else {
          // Por padrão, considerar como balcão
          vendasBalcao++;
          totalBalcao += movimento.valor;
        }
      }
    }
    
    return Row(
      children: [
        Expanded(
          child: _buildCardTipoVenda(
            titulo: 'Balcão',
            quantidade: vendasBalcao,
            valor: totalBalcao,
            icone: Icons.storefront,
            cor: Colors.blue[600]!,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCardTipoVenda(
            titulo: 'Delivery',
            quantidade: vendasDelivery,
            valor: totalDelivery,
            icone: Icons.delivery_dining,
            cor: Colors.orange[600]!,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCardTipoVenda(
            titulo: 'Mesa',
            quantidade: vendasMesa,
            valor: totalMesa,
            icone: Icons.table_restaurant,
            cor: Colors.purple[600]!,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCardTipoVenda({
    required String titulo,
    required int quantidade,
    required double valor,
    required IconData icone,
    required Color cor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cor.withValues(alpha: 0.8),
            cor,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: cor.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icone,
                color: Colors.white,
                size: 28,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$quantidade',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'R\$ ${valor.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            quantidade == 1 ? '$quantidade venda' : '$quantidade vendas',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemMovimentacao(MovimentoCaixa movimento) {
    final isEntrada = movimento.tipo == TipoMovimento.venda || movimento.tipo == TipoMovimento.suprimento;
    final cor = isEntrada ? Colors.green[600]! : Colors.red[600]!;
    final icone = _getIconeMovimento(movimento.tipo);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Ícone
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icone,
              color: cor,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('HH:mm').format(movimento.dataHora),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  movimento.descricao,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getDescricaoFormaPagamento(movimento.formaPagamento),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Valor
          Text(
            '${isEntrada ? '+' : '-'} R\$ ${movimento.valor.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final isAberto = _caixaAberto;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: isAberto ? _registrarSangria : null,
            icon: const Icon(Icons.remove_circle),
            label: const Text('Registrar Sangria'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          
          const SizedBox(width: 16),
          
          ElevatedButton.icon(
            onPressed: isAberto ? _registrarSuprimento : null,
            icon: const Icon(Icons.add_circle),
            label: const Text('Registrar Suprimento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          
          const SizedBox(width: 16),
          
          ElevatedButton.icon(
            onPressed: caixaAtual != null ? _mostrarOpcoesRelatorio : null,
            icon: const Icon(Icons.print),
            label: const Text('Imprimir Relatório'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 2,
            ),
          ),
          
          const Spacer(),
          
          // Resumo rápido
          if (isAberto)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Saldo Atual: R\$ ${(caixaAtual?.saldoAtual ?? 0.0).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconeMovimento(TipoMovimento tipo) {
    switch (tipo) {
      case TipoMovimento.venda:
        return Icons.shopping_cart;
      case TipoMovimento.sangria:
        return Icons.remove_circle;
      case TipoMovimento.suprimento:
        return Icons.add_circle;
      case TipoMovimento.abertura:
        return Icons.lock_open;
      case TipoMovimento.fechamento:
        return Icons.lock;
    }
  }

  String _getDescricaoFormaPagamento(FormaPagamento forma) {
    switch (forma) {
      case FormaPagamento.dinheiro:
        return 'Dinheiro';
      case FormaPagamento.cartao:
        return 'Cartão';
      case FormaPagamento.pix:
        return 'PIX';
    }
  }

  void _abrirCaixa() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildDialogAbrirCaixa(),
    );
  }

  void _fecharCaixa() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildDialogFecharCaixa(),
    );
  }

  void _registrarSangria() {
    showDialog(
      context: context,
      builder: (context) => _buildDialogSangria(),
    );
  }

  void _registrarSuprimento() {
    showDialog(
      context: context,
      builder: (context) => _buildDialogSuprimento(),
    );
  }

  void _mostrarOpcoesRelatorio() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.print, color: Colors.blue),
            SizedBox(width: 8),
            Text('Opções de Relatório'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.print, color: Colors.blue),
              title: const Text('Imprimir Relatório'),
              subtitle: const Text('Enviar para impressora'),
              onTap: () {
                Navigator.of(context).pop();
                _imprimirRelatorio();
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.green),
              title: const Text('Visualizar Relatório'),
              subtitle: const Text('Pré-visualizar antes de imprimir'),
              onTap: () {
                Navigator.of(context).pop();
                _visualizarRelatorio();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _visualizarRelatorio() async {
    if (caixaAtual == null) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await RelatorioCaixaService.imprimirRelatorio(caixaAtual!, movimentacoes);
      
      if (!mounted) return;
      Navigator.of(context).pop();
      
    } catch (e) {
      if (!mounted) return;
      
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao visualizar relatório: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _imprimirRelatorio() async {
    if (caixaAtual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum caixa disponível para imprimir'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await RelatorioCaixaService.imprimirRelatorio(caixaAtual!, movimentacoes);
      
      // Fechar loading
      if (!mounted) return;
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Relatório gerado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Fechar loading se ainda estiver aberto
      if (!mounted) return;
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar relatório: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDialogAbrirCaixa() {
    final valorController = TextEditingController();
    final observacoesController = TextEditingController();
    final nomeUsuarioController = TextEditingController();
    
    // Lista de operadores comuns
    final operadoresComuns = [
      'João',
      'Maria', 
      'Pedro',
      'Ana',
      'Carlos',
      'Juliana',
    ];
    
    return AlertDialog(
      title: const Text('Abrir Caixa'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo simples com sugestões via Chip
            TextField(
              controller: nomeUsuarioController,
              decoration: const InputDecoration(
                labelText: 'Nome do Operador',
                prefixIcon: Icon(Icons.person),
                hintText: 'Digite o nome do operador',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            // Sugestões de nomes comuns
            Wrap(
              spacing: 8,
              children: operadoresComuns.map((nome) {
                return ActionChip(
                  label: Text(nome),
                  onPressed: () {
                    nomeUsuarioController.text = nome;
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valorController,
              decoration: const InputDecoration(
                labelText: 'Valor Inicial (R\$)',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: observacoesController,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final nomeUsuario = nomeUsuarioController.text.trim();
            final valor = double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0;
            final observacoes = observacoesController.text;
            
            if (nomeUsuario.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, informe o nome do operador'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
            
            if (valor <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, informe um valor inicial válido'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
            
            Navigator.of(context).pop();
            
            try {
              await _caixaService.abrirCaixa(valor, observacoes, nomeUsuario);
              await _verificarEstadoCaixa();
              await _carregarDados();
              
              if (!mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Caixa aberto com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              if (!mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao abrir caixa: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Confirmar Abertura'),
        ),
      ],
    );
  }

  Widget _buildDialogFecharCaixa() {
    final valorContadoController = TextEditingController();
    final justificativaController = TextEditingController();
    
    return AlertDialog(
      title: const Text('Fechar Caixa'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Resumo do Dia',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildResumoFechamento(),
            const SizedBox(height: 16),
            TextField(
              controller: valorContadoController,
              decoration: const InputDecoration(
                labelText: 'Valor Contado em Caixa (R\$)',
                prefixIcon: Icon(Icons.calculate),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: justificativaController,
              decoration: const InputDecoration(
                labelText: 'Justificativa (se houver diferença)',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            
            try {
              await _caixaService.fecharCaixa();
              await _verificarEstadoCaixa();
              await _carregarDados();
              
              if (!mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Caixa fechado com sucesso!'),
                  backgroundColor: Colors.red,
                ),
              );
            } catch (e) {
              if (!mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao fechar caixa: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Confirmar Fechamento'),
        ),
      ],
    );
  }

  Widget _buildResumoFechamento() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildLinhaResumo('Abertura:', caixaAtual?.saldoInicial ?? 0.0),
          _buildLinhaResumo('Vendas:', caixaAtual?.totalVendas ?? 0.0),
          _buildLinhaResumo('Sangrias:', -(caixaAtual?.totalSangrias ?? 0.0)),
          const Divider(),
          _buildLinhaResumo('Esperado:', caixaAtual?.saldoAtual ?? 0.0, bold: true),
        ],
      ),
    );
  }

  Widget _buildLinhaResumo(String label, double valor, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'R\$ ${valor.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: valor < 0 ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogSangria() {
    final valorController = TextEditingController();
    final motivoController = TextEditingController();
    
    return AlertDialog(
      title: const Text('Registrar Sangria'),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valorController,
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                prefixIcon: Icon(Icons.remove_circle, color: Colors.red),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo/Descrição',
                prefixIcon: Icon(Icons.description),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            // Implementar lógica de sangria
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sangria registrada com sucesso!'),
                backgroundColor: Colors.orange,
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Registrar'),
        ),
      ],
    );
  }

  Widget _buildDialogSuprimento() {
    final valorController = TextEditingController();
    final motivoController = TextEditingController();
    
    return AlertDialog(
      title: const Text('Registrar Suprimento'),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valorController,
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                prefixIcon: Icon(Icons.add_circle, color: Colors.green),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo/Descrição',
                prefixIcon: Icon(Icons.description),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            // Implementar lógica de suprimento
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Suprimento registrado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Registrar'),
        ),
      ],
    );
  }
  
  Widget _buildCaixaFechado() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'Caixa Fechado',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _abrirCaixa,
            icon: const Icon(Icons.lock_open),
            label: const Text('Abrir Caixa'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFFDC2626),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_pizza,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  'Pizzaria Sistema',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Pedidos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/pedidos');
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Produtos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/produtos');
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Caixa'),
            onTap: () {
              Navigator.pop(context);
              // Já estamos na tela de caixa
            },
            selected: true,
            selectedTileColor: Colors.grey[200],
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clientes'),
            onTap: () {
              Navigator.pop(context);
              _showComingSoon(context);
            },
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade em desenvolvimento!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}