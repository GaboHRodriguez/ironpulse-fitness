@echo off
setlocal
cd /d "%~dp0"
set "FLUTTER_CMD=C:\src\flutter\bin\flutter.bat"
set "PATH=%PATH%;C:\src\flutter\bin"

echo ============================================================================
echo   IRONPULSE FITNESS - ASISTENTE DE ENTRENAMIENTO DE MUSCULACION
echo ============================================================================
echo.
echo   ELIGE UNA OPCION:
echo   1 - Abrir IronPulse Fitness AHORA en Windows (Ventana Independiente)
echo   2 - Compilar APK nativo para Android (Requiere Android Studio / SDK)
echo   3 - Compilar EXE C++ para Windows (Requiere Visual Studio C++)
echo   4 - Recompilar cambios del codigo (flutter build)
echo   5 - Ver estado de SDKs (flutter doctor)
echo   6 - Salir
echo ============================================================================
set /p opcion="Ingresa el numero de opcion (1-6) [Por defecto 1]: "
if "%opcion%"=="" set "opcion=1"

if "%opcion%"=="1" (
    if not exist "build\web\index.html" (
        echo [*] Compilando paquete de ejecucion...
        call "%FLUTTER_CMD%" build web --release
    )
    python run_windows_app.py
) else if "%opcion%"=="2" (
    call "%FLUTTER_CMD%" build apk --release
    echo.
    echo [OK] Si Android SDK esta configurado, el APK se encuentra en:
    echo      build\app\outputs\flutter-apk\app-release.apk
    pause
) else if "%opcion%"=="3" (
    call "%FLUTTER_CMD%" build windows --release
    pause
) else if "%opcion%"=="4" (
    call "%FLUTTER_CMD%" build web --release
    echo [OK] Aplicacion actualizada correctamente.
    pause
) else if "%opcion%"=="5" (
    call "%FLUTTER_CMD%" doctor
    pause
)
