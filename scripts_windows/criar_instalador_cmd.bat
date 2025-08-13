@echo off
echo ===================================
echo CRIANDO INSTALADOR PITFLUTER
echo ===================================
echo.

REM Volta para pasta raiz do projeto
cd ..

REM Limpa builds anteriores
echo Limpando builds anteriores...
if exist "build\windows" rmdir /s /q "build\windows"
flutter clean

echo.
echo Baixando dependencias...
flutter pub get

echo.
echo Compilando aplicacao (isso pode demorar)...
flutter build windows --release

if %errorlevel% neq 0 (
    echo ERRO na compilacao!
    pause
    exit /b 1
)

echo.
echo ===================================
echo BUILD CONCLUIDO COM SUCESSO!
echo ===================================
echo.
echo Arquivos gerados em: build\windows\x64\runner\Release\
echo.
echo Proximos passos:
echo 1. Copie toda a pasta Release para o computador de destino
echo 2. Execute o arquivo pitfluter.exe
echo.
pause