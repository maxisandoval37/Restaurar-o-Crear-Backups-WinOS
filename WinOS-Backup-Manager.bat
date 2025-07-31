@echo off
setlocal ENABLEDELAYEDEXPANSION
color 0A
title Restaurar o Crear Backups - WinOS

:: === Correr como administrador ===
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo El script requiere privilegios de administrador.
    echo Solicitando privilegios...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: === Configuracion ===
set BACKUP_PATH=D:\SystemBackup
set IMAGE_NAME=MiniOS_Backup
set SYSTEM_DRIVE=C:

:MENU
cls

echo.
echo                  _________-----_____
echo        ____------           __      ----_
echo  ___----             ___------              \
echo     ----________        ----                 \
echo                -----__    ^|             _____)
echo                     __-                /     \
echo         _______-----    ___--          \    /)\ 
echo   ------_______      ---____            \__/  /
echo                -----__    \ --    _          /\
echo                       --__--__     \_____/   \_/\ 
echo                               ---^|   /          ^|
echo                                  ^| ^|___________^|
echo                                  ^| ^| ((_(_)^| )_)
echo                                  ^|  \_((_(_)^|/(_)
echo                                   \             (
echo                                    \_____________)
echo.
echo.

echo =====================================================================
echo                          WinOS Backup Manager
echo                           By: maxisandoval37
echo =====================================================================
echo.

echo  [0] Crear particion para Backups
echo  [1] Crear Backup del Sistema
echo  [2] Restaurar desde Backup
echo  [3] Salir
echo.
set /p op=Selecciona una opcion (0-3): 

if "%op%"=="0" goto CREAR_PARTICION
if "%op%"=="1" goto CREAR_BACKUP
if "%op%"=="2" goto RESTAURAR_BACKUP
if "%op%"=="3" goto SALIR

echo.
echo Opcion invalida. Intenta de nuevo.
pause
goto MENU

:CREAR_BACKUP
cls
echo.
echo Creando imagen del sistema...
echo.
if not exist "%BACKUP_PATH%" mkdir "%BACKUP_PATH%"

dism /Capture-Image /ImageFile:"%BACKUP_PATH%\%IMAGE_NAME%.wim" /CaptureDir:%SYSTEM_DRIVE%/ /Name:"WinOS Base Image"

if %errorlevel%==0 (
    echo.
    echo Backup creado exitosamente en:
    echo    %BACKUP_PATH%\%IMAGE_NAME%.wim
) else (
    echo.
    echo Hubo un error al crear la imagen.
)

pause
goto MENU

:RESTAURAR_BACKUP
cls
echo.
echo Vas a restaurar el sistema desde la imagen. Esto reemplazara el contenido de %SYSTEM_DRIVE%
echo.
pause

echo Restaurando imagen del sistema...
dism /Apply-Image /ImageFile:"%BACKUP_PATH%\%IMAGE_NAME%.wim" /Index:1 /ApplyDir:%SYSTEM_DRIVE%\

if %errorlevel%==0 (
    echo.
    echo Sistema restaurado con EXITO. Reinicia para aplicar cambios.
) else (
    echo.
    echo ERROR al restaurar la imagen.
)

pause
goto MENU

:CREAR_PARTICION
cls
echo.
echo Vas a crear una nueva particion para backups.
echo Asegurate de tener espacio sin asignar en el disco.
echo.
set /p TAMANIO=Cuantos MB queres usar para la particion de backup?: 

echo.
echo Creando particion de %TAMANIO% MB...
echo.
(
echo select disk 0
echo create partition primary size=%TAMANIO%
echo format fs=ntfs quick
echo assign letter=D
echo exit
) | diskpart > nul

if exist D:\ (
    mkdir D:\SystemBackup
    echo Particion creada y carpeta 'SystemBackup' lista en D:\
) else (
    echo Error al crear la particion o asignar letra.
)

pause
goto MENU

:SALIR
echo.
echo Saliendo...
timeout /t 2 >nul
exit