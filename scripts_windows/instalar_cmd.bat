@echo off
echo ===================================
echo INSTALACAO DO SISTEMA PITFLUTER
echo ===================================
echo.

REM Verifica se o Flutter está instalado
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: Flutter nao encontrado!
    echo Por favor, instale o Flutter primeiro:
    echo 1. Baixe o Flutter SDK de: https://flutter.dev/docs/get-started/install/windows
    echo 2. Extraia para C:\flutter
    echo 3. Adicione C:\flutter\bin ao PATH do sistema
    pause
    exit /b 1
)

echo [OK] Flutter encontrado
echo.

REM Limpa cache e baixa dependências
echo Limpando cache do Flutter...
flutter clean

echo.
echo Baixando dependencias...
flutter pub get

if %errorlevel% neq 0 (
    echo ERRO ao baixar dependencias!
    pause
    exit /b 1
)

echo.
echo ===================================
echo INSTALACAO CONCLUIDA COM SUCESSO!
echo ===================================
echo.
echo Para executar o sistema use: executar_cmd.bat
echo Para criar instalador use: criar_instalador_cmd.bat
echo.
pause