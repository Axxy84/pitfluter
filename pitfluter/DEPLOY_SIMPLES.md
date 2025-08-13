# 🖥️ Deploy SIMPLES - Pitfluter Windows 10

## 📋 O que você precisa instalar

### 1. Flutter SDK
- **Download:** https://docs.flutter.dev/get-started/install/windows
- **Extrair em:** `C:\flutter`
- **Adicionar ao PATH:**
  1. Tecla Windows + R → digite `sysdm.cpl`
  2. Aba "Avançado" → "Variáveis de Ambiente"
  3. Em "Variáveis do sistema" → selecionar "Path" → "Editar"
  4. "Novo" → adicionar: `C:\flutter\bin`
  5. OK para salvar tudo

### 2. Visual Studio Community 2022 (GRATUITO)
- **Download:** https://visualstudio.microsoft.com/vs/community/
- **Durante instalação marcar:**
  - ✅ **"Desenvolvimento para desktop com C++"**
  - ✅ **"MSVC v143 - VS 2022 C++ x64/x86 build tools"**
  - ✅ **"SDK do Windows 10/11"**

## 🚀 Deploy Passo a Passo

### Passo 1: Abrir Prompt de Comando
1. **Tecla Windows + R**
2. **Digite:** `cmd`
3. **Enter**

### Passo 2: Navegar até a pasta do projeto
```cmd
cd C:\caminho\onde\esta\o\pitfluter
```

### Passo 3: Executar comandos um por vez

```cmd
flutter config --enable-windows-desktop
```
*Aguarde terminar, depois:*

```cmd
flutter clean
```
*Aguarde terminar, depois:*

```cmd
flutter pub get
```
*Aguarde terminar, depois:*

```cmd
flutter doctor
```
*Verifica se está tudo OK, depois:*

```cmd
flutter build windows --release
```
*⚠️ ESTE VAI DEMORAR! Aguarde até terminar (pode ser 10-15 minutos)*

## 📦 Localizar o Executável

Depois do build, o seu programa estará em:
```
build\windows\x64\runner\Release\pitfluter.exe
```

## 🎯 Para Usar

### No seu computador:
- Navegue até a pasta `build\windows\x64\runner\Release\`
- Clique duas vezes em `pitfluter.exe`

### Para levar para outro computador:
1. **Copie TODA a pasta** `Release`
2. **Cole no outro computador**
3. **Execute** `pitfluter.exe`

## ⚠️ Se der erro

### "Flutter não é reconhecido"
- Flutter não foi instalado corretamente
- Verificar se PATH foi configurado
- Reiniciar o computador

### "Visual Studio build tools"
- Visual Studio não instalado
- Faltou marcar as opções de C++
- Reinstalar Visual Studio

### "Erro de build"
- Executar: `flutter doctor`
- Ver se aparece algum ❌ vermelho
- Corrigir os problemas mostrados

## 🖨️ Para impressora funcionar

1. **Conectar impressora térmica** (80mm recomendada)
2. **Instalar driver** da impressora
3. **Configurar como padrão** no Windows
4. **Testar** imprimindo uma página de teste

## 📞 Se ainda der problema

1. **Abrir cmd novamente**
2. **Executar:** `flutter doctor -v`
3. **Copiar tudo** que aparecer
4. **Mandar** a mensagem de erro

---

**🎉 Pronto!** Seguindo estes passos você terá o Pitfluter rodando no Windows!