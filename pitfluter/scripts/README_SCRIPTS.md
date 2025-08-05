# 🍕 Scripts de Automação para Pizzas

## 📋 **Scripts Disponíveis**

### 1. **🔥 deletar_pizzas_automatico.py**
- **Função**: Deleta TODAS as pizzas com preços incorretos automaticamente
- **Uso**: `python3 deletar_pizzas_automatico.py`
- ⚠️ **ATENÇÃO**: Irá deletar dados permanentemente!

### 2. **✅ inserir_pizzas_corretas.py** 
- **Função**: Insere pizzas com preços corretos no banco
- **Uso**: `python3 inserir_pizzas_corretas.py`
- **Pizzas incluídas**: 8 pizzas com preços e tamanhos corretos

## 🚀 **Como Usar - Processo Completo**

### **Passo 1: Instalar Dependências**
```bash
pip install supabase
```

### **Passo 2: Configurar Credenciais**
Edite os arquivos e substitua:
```python
SUPABASE_URL = "https://your-project.supabase.co"  # SUA URL AQUI
SUPABASE_KEY = "your-anon-key"  # SUA CHAVE AQUI
```

### **Passo 3: Limpar Pizzas Incorretas**
```bash
cd /home/shannon/Documentos/Pitfluter/pitfluter/scripts
python3 deletar_pizzas_automatico.py
```
- O script irá mostrar todas as pizzas encontradas
- Digite `CONFIRMAR_DELETAR` para prosseguir
- Qualquer outra coisa cancela a operação

### **Passo 4: Inserir Pizzas Corretas** 
```bash
python3 inserir_pizzas_corretas.py
```
- Insere automaticamente 8 pizzas com preços corretos
- Cria categoria "Pizza" se não existir
- Calcula automaticamente preços por tamanho

## 📊 **Pizzas que Serão Inseridas**

| Pizza | Preço Base | Pequena | Média | Grande | Família |
|-------|------------|---------|-------|--------|---------|
| Margherita | R$ 35,90 | R$ 23,34 | R$ 30,52 | R$ 35,90 | R$ 46,67 |
| Calabresa | R$ 38,90 | R$ 25,29 | R$ 33,07 | R$ 38,90 | R$ 50,57 |
| Portuguesa | R$ 42,90 | R$ 27,89 | R$ 36,47 | R$ 42,90 | R$ 55,77 |
| 4 Queijos | R$ 45,90 | R$ 29,84 | R$ 39,02 | R$ 45,90 | R$ 59,67 |
| Vegetariana | R$ 39,90 | R$ 25,94 | R$ 33,92 | R$ 39,90 | R$ 51,87 |
| Napolitana | R$ 37,90 | R$ 24,64 | R$ 32,22 | R$ 37,90 | R$ 49,27 |
| Frango c/ Catupiry | R$ 41,90 | R$ 27,24 | R$ 35,62 | R$ 41,90 | R$ 54,47 |
| Pepperoni | R$ 43,90 | R$ 28,54 | R$ 37,32 | R$ 43,90 | R$ 57,07 |

## 🔧 **Multiplicadores de Tamanho**
- **Pequena**: 0.65x (65% do preço base)
- **Média**: 0.85x (85% do preço base)  
- **Grande**: 1.0x (100% do preço base)
- **Família**: 1.3x (130% do preço base)

## ⚠️ **Cuidados Importantes**

1. **BACKUP**: Faça backup do banco antes de usar os scripts
2. **TESTE**: Execute primeiro em ambiente de desenvolvimento
3. **CREDENCIAIS**: Nunca commite as credenciais do Supabase
4. **VERIFICAÇÃO**: Confira os preços no app após inserção

## 🎯 **Resultado Esperado**

Após executar ambos os scripts:
- ✅ Pizzas antigas com preços incorretos removidas
- ✅ 8 pizzas novas com preços corretos inseridas
- ✅ Sistema de 2 sabores funcionando com preços reais
- ✅ Cálculo automático por tamanho funcionando

## 💡 **Personalização**

Para ajustar preços, edite o array `PIZZAS_CORRETAS` em `inserir_pizzas_corretas.py`:

```python
{
    'nome': 'Sua Pizza',
    'preco_unitario': 50.00,  # Preço base
    # Os tamanhos são calculados automaticamente
}
```