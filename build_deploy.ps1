# --- CONFIGURATION ---
# UPDATE THIS PATH to your actual Google Drive folder
$DriveDest = "G:\My Drive\AppBuilds" 
$AppName = "MyFlutterApp"
# ---------------------

Write-Host "[START] Starting Build Process..." -ForegroundColor Cyan

# 1. Clean previous builds
Write-Host "[STEP 1] Cleaning project..." -ForegroundColor Yellow
flutter clean

# 2. Get dependencies
Write-Host "[STEP 2] Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# 3. Build the Release APK
Write-Host "[STEP 3] Building APK (Release Mode)..." -ForegroundColor Yellow
flutter build apk --release

# 4. Check if build was successful
$ApkPath = "build\app\outputs\flutter-apk\app-release.apk"

if (Test-Path $ApkPath) {
    Write-Host "[SUCCESS] Build Success!" -ForegroundColor Green
    
    # Create timestamp for unique filename
    $DateParams = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $NewFileName = "$AppName_$DateParams.apk"
    $DestPath = Join-Path -Path $DriveDest -ChildPath $NewFileName

    # Ensure destination directory exists
    if (-not (Test-Path $DriveDest)) {
        Write-Host "[INFO] Creating destination directory in Drive..." -ForegroundColor Gray
        New-Item -ItemType Directory -Force -Path $DriveDest | Out-Null
    }

    # 5. Copy to Google Drive
    Write-Host "[UPLOAD] Uploading to Google Drive..." -ForegroundColor Cyan
    Copy-Item -Path $ApkPath -Destination $DestPath

    if (Test-Path $DestPath) {
        Write-Host "[DONE] Success! APK uploaded to: $DestPath" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Failed to copy file to Drive. Check your Drive path." -ForegroundColor Red
    }
} else {
    Write-Host "[ERROR] APK file not found. Build likely failed." -ForegroundColor Red
    exit 1
}

Write-Host "Script Completed."