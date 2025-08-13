# 🖥️ Deploy do Pitfluter para Windows 10/11

## 📋 Pré-requisitos

### 1. Instalar Flutter
- Download: https://docs.flutter.dev/get-started/install/windows
- Extrair para `C:\flutter`
- Adicionar `C:\flutter\bin` ao PATH do Windows

### 2. Instalar Visual Studio
- **Visual Studio 2022 Community** (gratuito)
- Durante instalação, marcar:
  - ✅ **Desktop development with C++**
  - ✅ **MSVC v143 - VS 2022 C++ x64/x86 build tools**
  - ✅ **Windows 10/11 SDK**

### 3. Configurar Git (opcional)
- Download: https://git-scm.com/download/win
- Para clonar o projeto se necessário

## 🚀 Deploy Automático

### Opção 1: Script Automático
1. **Abrir PowerShell como Administrador**
2. **Navegar até a pasta do projeto:**
   ```cmd
   cd C:\caminho\para\pitfluter
   ```
3. **Executar o script:**
   ```cmd
   deploy_windows.bat
   ```

### Opção 2: Deploy Manual

#### Passo 1 - Preparar Ambiente
```cmd
# Habilitar Windows Desktop
flutter config --enable-windows-desktop

# Limpar cache
flutter clean

# Buscar dependências  
flutter pub get

# Verificar ambiente
flutter doctor
```

#### Passo 2 - Gerar Build
```cmd
# Build de release (produção)
flutter build windows --release
```

#### Passo 3 - Localizar Executável
O executável estará em:
```
build\windows\x64\runner\Release\pitfluter.exe
```

## 📦 Distribuição

### Para Usar Localmente
- Execute diretamente: `pitfluter.exe`

### Para Distribuir
1. **Copiar toda a pasta Release:**
   ```
   build\windows\x64\runner\Release\
   ```

2. **Conteúdo necessário:**
   ```
   Release/
   ├── pitfluter.exe          # Executável principal
   ├── flutter_windows.dll    # DLL do Flutter
   ├── data/                  # Recursos da aplicação
   └── outras DLLs necessárias
   ```

3. **Instalar no computador destino:**
   - Copiar toda a pasta `Release`
   - Renomear para `Pitfluter`
   - Executar `pitfluter.exe`

## 🔧 Configuração de Impressora

### Para Impressão de Comandas
1. **Instalar impressora térmica** (80mm recomendada)
2. **Configurar como impressora padrão**
3. **Testar impressão** no sistema

### Impressoras Compatíveis
- **Epson TM-T20II** (recomendada)
- **Bematech MP-4200 TH**  
- **Daruma DR-800**
- **Elgin i9** (USB/Serial)

## ⚙️ Configuração do Sistema

### Banco de Dados Supabase
O app já está configurado para conectar ao Supabase:
- **URL:** `https://lhvfacztsbflrtfibeek.supabase.co`
- **Chave:** Já configurada no código

### Primeiro Uso
1. **Executar** `pitfluter.exe`
2. **Aguardar carregamento** dos dados
3. **Testar conexão** criando um pedido de teste
4. **Configurar impressora** se necessário

## 📋 Checklist de Deploy

- [ ] Flutter instalado e funcionando
- [ ] Visual Studio com C++ tools
- [ ] Script `deploy_windows.bat` executado
- [ ] Build gerado sem erros
- [ ] Executável testado localmente
- [ ] Impressora configurada
- [ ] Conexão com internet funcionando
- [ ] Dados carregando do Supabase

## 🆘 Problemas Comuns

### "Flutter command not found"
- Verificar se Flutter está no PATH
- Reiniciar terminal após instalação

### "Visual Studio build tools not found"
- Instalar Visual Studio 2022 Community
- Marcar opções de C++ development

### "Unable to connect to database"
- Verificar conexão com internet
- Firewall pode estar bloqueando

### Impressora não funciona
- Instalar driver da impressora
- Definir como impressora padrão
- Testar com outro aplicativo

## 📞 Suporte

Em caso de problemas:
1. Verificar `flutter doctor` 
2. Consultar logs de erro
3. Testar em modo debug: `flutter run -d windows`

---

**🎉 Sucesso!** Após o deploy, o Pitfluter estará rodando como aplicativo desktop nativo do Windows!