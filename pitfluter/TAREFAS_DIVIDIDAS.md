# Tarefas Divididas - Pitfluter

## 🤖 Agente do Cursor (Supabase/Database)

### Responsabilidades:
- Criar e gerenciar tabelas no Supabase
- Executar migrações de banco de dados
- Configurar RLS (Row Level Security)
- Gerenciar dados de exemplo
- Monitorar performance do banco

### Tarefas Atuais:
1. **Estrutura de Tabelas** ✅ (Já criado)
   - `produtos_tamanho` - tamanhos (Broto, Média, Grande, Família, 8 Pedaços)
   - `categorias` - categorias de produtos
   - `produtos` - produtos únicos
   - `produtos_precos` - preços com foreign keys

2. **Próximas Tarefas**:
   - Adicionar mais produtos de exemplo
   - Configurar RLS policies
   - Criar índices de performance
   - Backup de dados

### Comandos Úteis:
```bash
# Listar tabelas
mcp_supabase_list_tables

# Executar SQL
mcp_supabase_execute_sql

# Aplicar migração
mcp_supabase_apply_migration

# Verificar advisors
mcp_supabase_get_advisors
```

---

## 💻 Claude Code (Flutter/App)

### Responsabilidades:
- Desenvolver código Flutter
- Executar e testar o app
- Corrigir bugs de frontend
- Otimizar performance da UI
- Gerenciar dependências

### Tarefas Atuais:
1. **Correção Pizzas Doces** ✅ (Já corrigido)
   - Preços agora aparecem corretamente
   - Estrutura unificada implementada

2. **Próximas Tarefas**:
   - Testar todas as funcionalidades
   - Otimizar carregamento de dados
   - Implementar cache local
   - Melhorar UX/UI

### Comandos Úteis:
```bash
# Executar app
flutter run -d linux

# Analisar código
flutter analyze

# Limpar build
flutter clean

# Atualizar dependências
flutter pub get
```

---

## 🔄 Fluxo de Trabalho

### Quando precisar de mudanças no banco:
1. **Claude Code** identifica necessidade
2. **Agente do Cursor** cria/atualiza tabelas
3. **Claude Code** atualiza código Flutter
4. **Claude Code** testa e valida

### Quando precisar de mudanças no app:
1. **Claude Code** implementa feature
2. **Claude Code** testa localmente
3. **Agente do Cursor** valida dados no Supabase
4. **Claude Code** faz commit

---

## 📋 Checklist de Comunicação

### Para o Agente do Cursor:
- [ ] Estrutura de tabelas está correta?
- [ ] Dados de exemplo estão inseridos?
- [ ] RLS policies configuradas?
- [ ] Performance otimizada?

### Para o Claude Code:
- [ ] App está funcionando?
- [ ] Todas as telas carregam?
- [ ] Preços aparecem corretamente?
- [ ] UX está boa?

---

## 🚀 Próximos Passos

1. **Testar app completo** (Claude Code)
2. **Adicionar mais produtos** (Agente do Cursor)
3. **Implementar cache** (Claude Code)
4. **Otimizar queries** (Agente do Cursor)
5. **Melhorar UI** (Claude Code)
