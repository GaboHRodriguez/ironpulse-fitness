$ErrorActionPreference = "Stop"

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "  INSTALANDO JAVA JDK 17 + ANDROID SDK Y COMPILANDO APK NATIVO" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

# 1. Instalar JDK 17 si no existe
$jdkPath = Get-ChildItem "C:\Program Files\Eclipse Adoptium\jdk-17*" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $jdkPath) {
    Write-Host "[1/5] Instalando Eclipse Temurin JDK 17..." -ForegroundColor Yellow
    winget install --id EclipseAdoptium.Temurin.17.JDK -e --silent --accept-package-agreements --accept-source-agreements
    $jdkPath = Get-ChildItem "C:\Program Files\Eclipse Adoptium\jdk-17*" -ErrorAction SilentlyContinue | Select-Object -First 1
}

if ($jdkPath) {
    $env:JAVA_HOME = $jdkPath.FullName
    $env:PATH = "$($jdkPath.FullName)\bin;$env:PATH"
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkPath.FullName, "User")
    Write-Host "[OK] JAVA_HOME configurado en: $($env:JAVA_HOME)" -ForegroundColor Green
}

# 2. Descargar y configurar Android Command Line Tools en C:\Android\sdk
$sdkRoot = "C:\Android\sdk"
$cmdlineToolsDir = "$sdkRoot\cmdline-tools\latest"
$sdkManager = "$cmdlineToolsDir\bin\sdkmanager.bat"

if (-not (Test-Path $sdkManager)) {
    Write-Host "[2/5] Descargando Android Command Line Tools oficiales de Google..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path "$sdkRoot\cmdline-tools" | Out-Null
    $zipUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
    $zipFile = "$env:TEMP\cmdline-tools.zip"
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile
    Expand-Archive -Path $zipFile -DestinationPath "$sdkRoot\cmdline-tools\temp_extract" -Force
    if (Test-Path $cmdlineToolsDir) { Remove-Item -Recurse -Force $cmdlineToolsDir }
    Move-Item "$sdkRoot\cmdline-tools\temp_extract\cmdline-tools" $cmdlineToolsDir
    Remove-Item -Recurse -Force "$sdkRoot\cmdline-tools\temp_extract"
    Remove-Item -Force $zipFile
}

$env:ANDROID_HOME = $sdkRoot
$env:ANDROID_SDK_ROOT = $sdkRoot
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkRoot, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $sdkRoot, "User")
$env:PATH = "$cmdlineToolsDir\bin;$sdkRoot\platform-tools;C:\src\flutter\bin;$env:PATH"

# 3. Instalar plataformas y build-tools requeridos por Flutter
Write-Host "[3/5] Aceptando licencias e instalando Android SDK Platform 34/35 y Build-Tools..." -ForegroundColor Yellow
$yesInputs = ("y`r`n" * 40)
$yesInputs | & $sdkManager --sdk_root=$sdkRoot --licenses | Out-Null
$yesInputs | & $sdkManager --sdk_root=$sdkRoot "platform-tools" "platforms;android-35" "platforms;android-34" "build-tools;35.0.0" "build-tools;34.0.0"

# 4. Vincular SDK con Flutter
Write-Host "[4/5] Vinculando Android SDK y JDK con Flutter..." -ForegroundColor Yellow
& "C:\src\flutter\bin\flutter.bat" config --android-sdk $sdkRoot
if ($env:JAVA_HOME) {
    & "C:\src\flutter\bin\flutter.bat" config --jdk-dir $env:JAVA_HOME
}
$yesInputs | & "C:\src\flutter\bin\flutter.bat" doctor --android-licenses | Out-Null

# 5. Compilar el APK Release y copiarlo a la raiz del proyecto
Write-Host "[5/5] Compilando APK nativo de IronPulse Fitness..." -ForegroundColor Yellow
Set-Location "c:\Users\gaboh\Proyectos Antigravity\ironpulse_fitness"
& "C:\src\flutter\bin\flutter.bat" build apk --release

$apkBuilt = "c:\Users\gaboh\Proyectos Antigravity\ironpulse_fitness\build\app\outputs\flutter-apk\app-release.apk"
$apkEasyCopy = "c:\Users\gaboh\Proyectos Antigravity\ironpulse_fitness\IronPulse_Fitness_Android.apk"

if (Test-Path $apkBuilt) {
    Copy-Item $apkBuilt $apkEasyCopy -Force
    Write-Host "==================================================================" -ForegroundColor Green
    Write-Host "  [EXITO] APK GENERADO CORRECTAMENTE EN:" -ForegroundColor Green
    Write-Host "  1) $apkEasyCopy" -ForegroundColor Green
    Write-Host "  2) $apkBuilt" -ForegroundColor Green
    Write-Host "==================================================================" -ForegroundColor Green
} else {
    Write-Host "[!] No se encontro el archivo APK final." -ForegroundColor Red
    exit 1
}
