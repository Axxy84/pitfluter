🍕 SISTEMA PIZZARIA - DIVISÃO PARA AGENTES ESPECIALIZADOS
VISÃO GERAL DO PROJETO
Sistema desktop Flutter que usa Supabase como banco de dados online. O sistema gerencia pizzaria completa: pedidos, clientes, produtos, estoque, mesas e financeiro.
DIVISÃO POR AGENTES (5 AGENTES PARALELOS)
🏗️ AGENTE 1 - ARQUITETURA BASE
Tempo: 4 horas
Missão: Criar estrutura fundamental do projeto
Responsabilidades:

Criar projeto Flutter Desktop
Configurar conexão Supabase
Estruturar pastas do projeto
Configurar dependências principais
Criar modelos base das 34 tabelas
Configurar sistema de rotas
Criar tema visual (cores #DC2626 e #7C2D12)

Entregáveis:

Projeto configurado e rodando
Conexão Supabase funcionando
Todos os modelos criados
Navegação básica implementada

🔌 AGENTE 2 - CAMADA DE DADOS
Tempo: 6 horas
Missão: Implementar toda comunicação com Supabase
Responsabilidades:

Criar repositórios para cada tabela
Implementar CRUD completo
Sistema de cache offline com Drift
Sincronização automática
Tratamento de erros
Sistema de filas para offline

Principais Repositórios:

PedidoRepository (mais complexo)
ClienteRepository
ProdutoRepository
MesaRepository
CaixaRepository

Funcionalidades Especiais:

Realtime para pedidos e mesas
Sistema de numeração sequencial
Cálculos automáticos de totais

🎨 AGENTE 3 - INTERFACE BASE
Tempo: 6 horas
Missão: Criar todos componentes visuais reutilizáveis
Responsabilidades:

Layout principal com sidebar
Componentes de formulário
Cards e listas customizadas
Sistema de notificações
Indicadores de status online/offline
Loading states
Empty states

Componentes Principais:

MainLayout (sidebar + content)
PedidoCard (com cores por status)
ProdutoSelector (com tamanhos)
ClienteSearchField
MesaGrid (visual de mesas)
StatusBadge
MoneyInput

Padrão Visual:

Seguir cores do sistema
Fonte Inter
Sombras suaves
Bordas arredondadas (8px)
Espaçamentos consistentes

📱 AGENTE 4 - FUNCIONALIDADE PEDIDOS
Tempo: 10 horas
Missão: Implementar sistema completo de pedidos
Responsabilidades:

Tela listagem de pedidos
Modal criar novo pedido
Sistema de carrinho
Pizzas meio a meio
Seletor de clientes
Cálculo de taxas
Atualização de status
Impressão de comandas

Fluxo do Pedido:

Lista pedidos com filtros
Botão novo pedido abre modal
Step 1: Buscar/criar cliente
Step 2: Adicionar produtos
Step 3: Pagamento e entrega
Step 4: Confirmar e imprimir

Regras Importantes:

Numeração sequencial automática
Status: recebido → preparando → saindo → entregue
Meio a meio pega preço mais caro
Taxa entrega por bairro

🚀 AGENTE 5 - FUNCIONALIDADES COMPLEMENTARES
Tempo: 8 horas
Missão: Implementar demais módulos
Módulos:

Dashboard (2h)

Cards resumo do dia
Gráfico vendas
Pedidos pendentes
Produtos mais vendidos


Mesas (2h)

Grid visual de mesas
Abrir/fechar mesa
Adicionar pedidos
Comanda por mesa


Clientes (1h)

Lista com busca
Cadastro completo
Múltiplos endereços


Produtos (1h)

Lista por categoria
Preços por tamanho
Ativar/desativar


Caixa (2h)

Abrir caixa
Movimentações
Fechar com conferência
Relatório



ESTRATÉGIA DE EXECUÇÃO
DIA 1 - FUNDAÇÃO (24 horas)
00:00-04:00: Agente 1 cria base
04:00-10:00: Agente 2 implementa dados
10:00-16:00: Agente 3 cria interface
16:00-24:00: Agente 4 inicia pedidos
DIA 2 - INTEGRAÇÃO (24 horas)
00:00-06:00: Agente 4 finaliza pedidos
06:00-14:00: Agente 5 módulos complementares
14:00-20:00: Integração e testes
20:00-24:00: Ajustes e build final
ORGANIZAÇÃO SUPABASE
Tabelas Principais
Módulo Clientes:

clientes_cliente
clientes_endereco

Módulo Produtos:

produtos_categoria
produtos_tamanho
produtos_produto
produtos_produtopreco

Módulo Pedidos:

pedidos_pedido
pedidos_itempedido
pedidos_mesa
pedidos_configuracaopedido

Módulo Estoque:

estoque_ingrediente
estoque_unidademedida
estoque_movimentoestoque
estoque_receitaproduto

Módulo Financeiro:

financeiro_caixa
financeiro_movimentocaixa
financeiro_contapagar

FUNCIONALIDADES POR PRIORIDADE
CRÍTICAS (Fazer primeiro)

Criar e listar pedidos
Sistema de carrinho
Buscar/criar clientes
Selecionar produtos com tamanhos
Impressão básica

IMPORTANTES (Fazer segundo)

Dashboard com resumos
Controle de mesas
Atualização status pedidos
Sistema meio a meio
Caixa básico

DESEJÁVEIS (Se sobrar tempo)

Gestão completa produtos
Relatórios elaborados
Controle estoque
Gráficos avançados
Configurações sistema

INSTRUÇÕES PARA CADA AGENTE
Para Agente 1 - Base
"Crie estrutura Flutter Desktop conectando ao Supabase PostgreSQL existente. Configure 34 modelos baseados nas tabelas Django. Use cores #DC2626 (primária) e #7C2D12 (secundária). Implemente navegação lateral."
Para Agente 2 - Dados
"Implemente repositórios Supabase para todas tabelas com CRUD completo. Foque em PedidoRepository com numeração sequencial e cálculos. Configure realtime para pedidos_pedido e pedidos_mesa."
Para Agente 3 - Interface
"Crie componentes visuais reutilizáveis seguindo design Tailwind original. Sidebar navegação, cards para pedidos com status coloridos, formulários, seletores de produtos com tamanhos."
Para Agente 4 - Pedidos
"Implemente módulo completo de pedidos: listagem com filtros, modal novo pedido em steps, carrinho, meio a meio, integração com clientes e produtos, impressão comandas."
Para Agente 5 - Complementares
"Implemente dashboard com cards e gráficos, sistema de mesas visual, cadastro clientes com endereços, lista produtos por categoria, abertura e fechamento de caixa."
PONTOS DE ATENÇÃO
Sincronização

Salvar local primeiro (Drift)
Sincronizar com Supabase quando online
Mostrar indicador online/offline
Resolver conflitos por timestamp

Performance

Paginação em listas grandes
Cache de imagens produtos
Lazy loading
Debounce em buscas

Regras Negócio

Pedido numeração: 000001, 000002...
Cancelamento precisa senha
Mesa só fecha com pedidos pagos
Caixa: um aberto por vez

Estados Visuais

Recebido: azul
Preparando: laranja
Saindo: roxo
Entregue: verde
Cancelado: vermelho

RESULTADO ESPERADO
Sistema desktop funcional em 48 horas com:

Gestão completa de pedidos funcionando
Sincronização Supabase automática
Interface profissional
Impressão de comandas
Dashboard operacional
Controle de mesas
Cadastro de clientes