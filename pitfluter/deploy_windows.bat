@echo off
REM ===============================================
REM        SCRIPT DE DEPLOY - PITFLUTER
REM             Para Windows 10/11
REM ===============================================

echo.
echo ================================================
echo           INICIANDO DEPLOY PITFLUTER
echo ================================================
echo.

REM Verificar se Flutter está instalado
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Flutter não está instalado ou não está no PATH
    echo.
    echo Instale o Flutter seguindo: https://docs.flutter.dev/get-started/install/windows
    pause
    exit /b 1
)

echo [INFO] Flutter detectado com sucesso!

REM Habilitar desktop Windows
echo [INFO] Habilitando suporte ao Windows Desktop...
flutter config --enable-windows-desktop

REM Limpar builds anteriores
echo [INFO] Limpando builds anteriores...
flutter clean

REM Buscar dependências
echo [INFO] Buscando dependências...
flutter pub get

REM Verificar ambiente
echo [INFO] Verificando ambiente Flutter...
flutter doctor

REM Gerar build de release
echo.
echo [INFO] Gerando build de release para Windows...
echo [AVISO] Este processo pode demorar alguns minutos...
flutter build windows --release

if %errorlevel% neq 0 (
    echo.
    echo [ERRO] Falha na geração do build!
    pause
    exit /b 1
)

REM Criar pasta de distribuição
echo.
echo [INFO] Criando pasta de distribuição...
if exist "dist" rmdir /s /q "dist"
mkdir "dist"

REM Copiar arquivos necessários
echo [INFO] Copiando arquivos para distribuição...
xcopy "build\windows\x64\runner\Release\*" "dist\" /E /I /Y

echo.
echo ================================================
echo            DEPLOY CONCLUÍDO COM SUCESSO!
echo ================================================
echo.
echo O executável está em: dist\pitfluter.exe
echo.
echo Para executar:
echo 1. Vá até a pasta 'dist'
echo 2. Execute 'pitfluter.exe'
echo.
echo Para distribuição:
echo - Copie toda a pasta 'dist' para o computador de destino
echo - Execute pitfluter.exe
echo.

pause