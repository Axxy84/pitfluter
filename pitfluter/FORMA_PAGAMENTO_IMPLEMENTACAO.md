# Implementação de Forma de Pagamento no Carrinho

## Funcionalidades Implementadas

### 1. Novo Widget de Carrinho com Pagamento
**Arquivo:** `lib/presentation/widgets/carrinho_pagamento_widget.dart`

#### Características:
- **Formas de Pagamento Disponíveis:**
  - Dinheiro (com cálculo de troco)
  - Cartão de Crédito
  - Cartão de Débito
  - PIX
  - Vale Refeição

- **Fluxo de Pagamento:**
  1. Usuário adiciona itens ao carrinho
  2. Clica em "Ir para Pagamento"
  3. Visualiza resumo do pedido
  4. Seleciona forma de pagamento
  5. Se Dinheiro: informa valor recebido e vê troco calculado
  6. Finaliza o pedido

- **Validações:**
  - Forma de pagamento obrigatória
  - Valor pago deve ser maior ou igual ao total (para Dinheiro)
  - Cálculo automático de troco

### 2. Integração com Novo Pedido
**Arquivo modificado:** `lib/presentation/screens/novo_pedido_screen.dart`

#### Mudanças:
- Adicionado método `_mostrarModalPagamento()`
- Modal aparece antes de salvar o pedido
- Dados de pagamento salvos no banco:
  - `forma_pagamento`: String com a forma selecionada
  - `valor_pago`: Valor recebido (para Dinheiro)
  - `troco`: Troco calculado (para Dinheiro)

### 3. Estrutura de Dados

#### CarrinhoItem
```dart
class CarrinhoItem {
  final Produto produto;
  final Tamanho tamanho;
  final int quantidade;
  final double precoUnitario;
  double get subtotal => quantidade * precoUnitario;
}
```

#### FormaPagamento (Enum)
```dart
enum FormaPagamento {
  dinheiro('Dinheiro', Icons.money),
  cartaoCredito('Cartão de Crédito', Icons.credit_card),
  cartaoDebito('Cartão de Débito', Icons.credit_card),
  pix('PIX', Icons.qr_code),
  vale('Vale Refeição', Icons.restaurant);
}
```

## Como Usar

### 1. Widget Standalone
```dart
CarrinhoPagamentoWidget(
  itens: listaDeItens,
  onQuantidadeChanged: (item, quantidade) { },
  onItemRemoved: (item) { },
  onFinalizarPedido: (formaPagamento, valorPago, troco) {
    // Salvar pedido com informações de pagamento
  },
)
```

### 2. Como Bottom Sheet
```dart
showCarrinhoPagamentoBottomSheet(
  context: context,
  itens: listaDeItens,
  onQuantidadeChanged: (item, quantidade) { },
  onItemRemoved: (item) { },
  onFinalizarPedido: (formaPagamento, valorPago, troco) {
    // Processar finalização
  },
);
```

## Telas Afetadas

1. **NovoPedidoScreen** - Integração completa com modal de pagamento
2. **ListaPedidosScreen** - Exibe pedidos com possibilidade de ver forma de pagamento

## Banco de Dados

### Campos Adicionados na Tabela `pedidos`:
- `forma_pagamento` (VARCHAR) - Nome da forma de pagamento
- `valor_pago` (DECIMAL) - Valor recebido do cliente (nullable)
- `troco` (DECIMAL) - Troco calculado (nullable)

## Melhorias Futuras

1. **Integração com Impressora**
   - Imprimir forma de pagamento no cupom
   - Imprimir valor pago e troco quando aplicável

2. **Relatórios**
   - Relatório de vendas por forma de pagamento
   - Análise de formas de pagamento mais utilizadas

3. **Validações Adicionais**
   - Limite de crédito para vale refeição
   - Validação de chave PIX
   - Integração com máquina de cartão

4. **Funcionalidades Extras**
   - Parcelamento para cartão de crédito
   - Desconto por forma de pagamento
   - Múltiplas formas de pagamento no mesmo pedido

## Observações

- O sistema está preparado para soft delete mas atualmente usa DELETE direto
- As informações de pagamento são salvas apenas se as colunas existirem no banco
- O cálculo de troco é feito em tempo real enquanto o usuário digita