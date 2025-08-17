# 📦 Guia de Instalação - Sistema PitFluter

## 🎯 Formas de Instalação

### Opção 1: Instalador Profissional (RECOMENDADO)
**Arquivo único .exe que instala tudo automaticamente**

#### Como criar o instalador:
1. **Instale o Inno Setup** (apenas uma vez):
   - Baixe em: https://jrsoftware.org/isdl.php
   - Instale com as opções padrão

2. **Execute o script de criação**:
   - Abra a pasta `scripts_windows`
   - Execute `criar_instalador_completo.bat`
   - Aguarde a compilação (5-10 minutos)
   - O instalador será criado em `installer_output\PitFluter_Setup_v1.0.0.exe`

3. **Envie para o cliente**:
   - Envie apenas o arquivo `PitFluter_Setup_v1.0.0.exe`
   - O cliente executa e segue o assistente de instalação
   - Pronto! Sistema instalado com ícone na área de trabalho

---

### Opção 2: Instalação Manual Simplificada
**Pasta com arquivos + script de instalação**

#### Como preparar:
1. **Execute o script**:
   - Abra a pasta `scripts_windows`
   - Execute `preparar_instalacao_manual.bat`
   - Aguarde a compilação
   - Uma pasta `PitFluter_Instalacao_Manual` será criada

2. **Envie para o cliente**:
   - Compacte a pasta em ZIP
   - Envie o arquivo ZIP para o cliente

3. **Instruções para o cliente**:
   - Descompacte o ZIP
   - Clique com botão direito em `INSTALAR.bat`
   - Escolha "Executar como administrador"
   - Pronto!

---

## ⚙️ Requisitos do Sistema (Cliente)

### Mínimos:
- Windows 10 (64 bits)
- 4 GB RAM
- 500 MB espaço em disco
- Conexão com internet (para acessar o banco Supabase)

### Recomendados:
- Windows 11 (64 bits)
- 8 GB RAM
- 1 GB espaço em disco

### Componente Necessário:
- **Visual C++ Redistributable 2015-2022**
  - Baixar: https://aka.ms/vs/17/release/vc_redist.x64.exe
  - O instalador verifica automaticamente (Opção 1)
  - Na instalação manual, instale antes se necessário

---

## 🚨 Solução de Problemas

### Erro: "VCRUNTIME140.dll não foi encontrado"
**Solução**: Instale o Visual C++ Redistributable (link acima)

### Erro: "Windows protegeu seu PC"
**Solução**: 
1. Clique em "Mais informações"
2. Clique em "Executar assim mesmo"
3. Isto é normal para aplicativos não assinados digitalmente

### Sistema não abre após instalação
**Verificar**:
1. Antivírus não está bloqueando
2. Firewall permite conexão com internet
3. Visual C++ está instalado
4. Reinicie o computador

### Tela branca ou travada
**Solução**:
1. Verifique conexão com internet
2. Aguarde 30 segundos (primeira execução demora mais)
3. Se persistir, reinstale o sistema

---

## 📱 Contatos para Suporte

Configure aqui seus contatos de suporte:
- WhatsApp: (XX) XXXXX-XXXX
- Email: suporte@suaempresa.com
- TeamViewer ID: XXXXXXXXX

---

## 🔄 Atualizações

Para atualizar o sistema:
1. Gere uma nova versão (mude o número em `installer.iss`)
2. Crie novo instalador
3. O cliente executa o novo instalador
4. A versão antiga é substituída automaticamente

---

## 💡 Dicas Importantes

1. **Sempre teste** o instalador em uma máquina virtual antes de enviar
2. **Guarde uma cópia** do instalador de cada versão
3. **Documente mudanças** entre versões
4. **Configure o Supabase** corretamente antes de compilar
5. **Faça backup** do banco de dados regularmente

---

## 🎉 Pronto para Usar!

Após a instalação, o sistema:
- ✅ Cria ícone na área de trabalho
- ✅ Adiciona entrada no menu Iniciar
- ✅ Pode ser desinstalado pelo Painel de Controle
- ✅ Conecta automaticamente ao Supabase
- ✅ Está pronto para uso imediato!

---

*Documento criado para facilitar a instalação do sistema PitFluter em máquinas Windows.*