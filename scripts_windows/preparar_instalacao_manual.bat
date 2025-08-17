@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo PREPARADOR DE INSTALACAO MANUAL
echo ==========================================
echo.

cd /d "%~dp0\.."

REM Compila o projeto
echo Compilando sistema...
flutter build windows --release

if %errorlevel% neq 0 (
    echo [ERRO] Falha na compilacao!
    pause
    exit /b 1
)

REM Cria pasta de distribuição
echo Criando pacote de instalacao...
set OUTPUT_DIR=PitFluter_Instalacao_Manual
if exist "%OUTPUT_DIR%" rmdir /s /q "%OUTPUT_DIR%"
mkdir "%OUTPUT_DIR%"

REM Copia arquivos compilados
xcopy "build\windows\x64\runner\Release\*" "%OUTPUT_DIR%\PitFluter\" /E /I /Y

REM Cria script de instalação para o cliente
echo @echo off > "%OUTPUT_DIR%\INSTALAR.bat"
echo echo ========================================== >> "%OUTPUT_DIR%\INSTALAR.bat"
echo echo INSTALADOR PITFLUTER >> "%OUTPUT_DIR%\INSTALAR.bat"
echo echo ========================================== >> "%OUTPUT_DIR%\INSTALAR.bat"
echo echo. >> "%OUTPUT_DIR%\INSTALAR.bat"
echo echo Instalando sistema... >> "%OUTPUT_DIR%\INSTALAR.bat"
echo. >> "%OUTPUT_DIR%\INSTALAR.bat"
echo REM Cria pasta no Program Files >> "%OUTPUT_DIR%\INSTALAR.bat"
echo set INSTALL_DIR="%%ProgramFiles%%\PitFluter" >> "%OUTPUT_DIR%\INSTALAR.bat"
echo if not exist %%INSTALL_DIR%% mkdir %%INSTALL_DIR%% >> "%OUTPUT_DIR%\INSTALAR.bat"
echo. >> "%OUTPUT_DIR%\INSTALAR.bat"
echo REM Copia arquivos >> "%OUTPUT_DIR%\INSTALAR.bat"
echo xcopy "PitFluter\*" %%INSTALL_DIR%%\ /E /I /Y >> "%OUTPUT_DIR%\INSTALAR.bat"
echo. >> "%OUTPUT_DIR%\INSTALAR.bat"
echo REM Cria atalho na area de trabalho >> "%OUTPUT_DIR%\INSTALAR.bat"
echo powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%%USERPROFILE%%\Desktop\PitFluter.lnk'); $Shortcut.TargetPath = '%%INSTALL_DIR%%\pitfluter.exe'; $Shortcut.Save()" >> "%OUTPUT_DIR%\INSTALAR.bat"
echo. >> "%OUTPUT_DIR%\INSTALAR.bat"
echo echo. >> "%OUTPUT_DIR%\INSTALAR.bat"
echo echo Instalacao concluida! >> "%OUTPUT_DIR%\INSTALAR.bat"
echo echo Atalho criado na area de trabalho. >> "%OUTPUT_DIR%\INSTALAR.bat"
echo pause >> "%OUTPUT_DIR%\INSTALAR.bat"

REM Cria README
echo INSTRUCOES DE INSTALACAO > "%OUTPUT_DIR%\LEIA-ME.txt"
echo ======================== >> "%OUTPUT_DIR%\LEIA-ME.txt"
echo. >> "%OUTPUT_DIR%\LEIA-ME.txt"
echo 1. Execute o arquivo INSTALAR.bat como Administrador >> "%OUTPUT_DIR%\LEIA-ME.txt"
echo    (Clique com botao direito - Executar como administrador) >> "%OUTPUT_DIR%\LEIA-ME.txt"
echo. >> "%OUTPUT_DIR%\LEIA-ME.txt"
echo 2. O sistema sera instalado automaticamente >> "%OUTPUT_DIR%\LEIA-ME.txt"
echo. >> "%OUTPUT_DIR%\LEIA-ME.txt"
echo 3. Um atalho sera criado na area de trabalho >> "%OUTPUT_DIR%\LEIA-ME.txt"
echo. >> "%OUTPUT_DIR%\LEIA-ME.txt"
echo REQUISITOS: >> "%OUTPUT_DIR%\LEIA-ME.txt"
echo - Windows 10 ou superior (64 bits) >> "%OUTPUT_DIR%\LEIA-ME.txt"
echo - Visual C++ Redistributable 2015-2022 >> "%OUTPUT_DIR%\LEIA-ME.txt"
echo   Baixe em: https://aka.ms/vs/17/release/vc_redist.x64.exe >> "%OUTPUT_DIR%\LEIA-ME.txt"

echo.
echo ==========================================
echo PACOTE CRIADO COM SUCESSO!
echo ==========================================
echo.
echo Pasta criada: %OUTPUT_DIR%
echo.
echo INSTRUCOES PARA O CLIENTE:
echo 1. Envie toda a pasta "%OUTPUT_DIR%" para o cliente
echo 2. Peca para executar INSTALAR.bat como Administrador
echo.
explorer "%OUTPUT_DIR%"
pause