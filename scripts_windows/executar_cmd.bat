@echo off
echo ===================================
echo EXECUTANDO SISTEMA PITFLUTER
echo ===================================
echo.

REM Verifica se as dependências estão instaladas
if not exist "..\pubspec.lock" (
    echo AVISO: Dependencias nao encontradas!
    echo Executando instalacao...
    call instalar_cmd.bat
)

echo Iniciando aplicacao...
echo.
cd ..
flutter run -d windows --release

if %errorlevel% neq 0 (
    echo.
    echo ERRO ao executar aplicacao!
    echo Tentando modo debug...
    flutter run -d windows
)

pause