@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo CRIADOR DE INSTALADOR PITFLUTER v1.0
echo ==========================================
echo.

REM Volta para pasta raiz
cd /d "%~dp0\.."

REM Verifica se o Flutter está instalado
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Flutter nao encontrado!
    echo Instale o Flutter: https://flutter.dev/docs/get-started/install/windows
    pause
    exit /b 1
)

REM Limpa builds anteriores
echo [1/6] Limpando builds anteriores...
if exist "build\windows" rmdir /s /q "build\windows"
if exist "installer_output" rmdir /s /q "installer_output"
flutter clean >nul 2>&1

echo [2/6] Baixando dependencias...
flutter pub get

echo [3/6] Compilando aplicacao Release (aguarde)...
flutter build windows --release

if %errorlevel% neq 0 (
    echo.
    echo [ERRO] Falha na compilacao!
    echo Verifique os erros acima.
    pause
    exit /b 1
)

echo [4/6] Build concluido com sucesso!

REM Verifica se o Inno Setup está instalado
set INNO_PATH=
for %%i in (
    "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
    "%ProgramFiles%\Inno Setup 6\ISCC.exe"
    "%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe"
    "%ProgramFiles%\Inno Setup 5\ISCC.exe"
) do (
    if exist "%%~i" (
        set "INNO_PATH=%%~i"
        goto :found_inno
    )
)

:found_inno
if not defined INNO_PATH (
    echo.
    echo [AVISO] Inno Setup nao encontrado!
    echo.
    echo Para criar um instalador profissional:
    echo 1. Baixe o Inno Setup: https://jrsoftware.org/isdl.php
    echo 2. Execute este script novamente
    echo.
    echo Por enquanto, use a pasta: build\windows\x64\runner\Release\
    echo Copie toda essa pasta para o computador do cliente.
    echo.
    pause
    exit /b 0
)

echo [5/6] Criando instalador com Inno Setup...
"%INNO_PATH%" "installer.iss" /Q

if %errorlevel% neq 0 (
    echo [ERRO] Falha ao criar instalador!
    pause
    exit /b 1
)

echo [6/6] Instalador criado com sucesso!
echo.
echo ==========================================
echo INSTALADOR CRIADO COM SUCESSO!
echo ==========================================
echo.
echo Arquivo gerado: installer_output\PitFluter_Setup_v1.0.0.exe
echo.
echo Este arquivo pode ser enviado para o cliente.
echo Ele instalara o sistema automaticamente!
echo.
explorer installer_output
pause