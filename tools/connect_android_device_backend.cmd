@echo off
setlocal

echo Checking connected Android devices...
adb devices
if errorlevel 1 (
  echo.
  echo adb is not available. Open Android Studio once or check that Android platform-tools are in PATH.
  pause
  exit /b 1
)

for /f "tokens=1" %%D in ('adb devices ^| findstr /R "^[A-Za-z0-9._:-][A-Za-z0-9._:-]*[ ]*device$"') do (
  echo.
  echo Configuring reverse on device %%D ...
  adb -s %%D reverse tcp:54321 tcp:54321
  if errorlevel 1 (
    echo Could not configure adb reverse on %%D.
    pause
    exit /b 1
  )
)

echo.
echo Active adb reverse rules:
adb reverse --list

echo.
echo Checking local Supabase health...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $response = Invoke-WebRequest -Uri 'http://127.0.0.1:54321/auth/v1/health' -UseBasicParsing -TimeoutSec 6; if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300) { Write-Host 'Supabase is reachable.'; exit 0 }; Write-Host ('Supabase returned HTTP ' + $response.StatusCode); exit 1 } catch { Write-Host ('Supabase health check failed: ' + $_.Exception.Message); exit 1 }"
if errorlevel 1 (
  echo.
  powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Test-NetConnection -ComputerName 127.0.0.1 -Port 54321 -InformationLevel Quiet) { exit 0 } else { exit 1 }"
  if errorlevel 1 (
    echo Supabase local API is not listening on http://127.0.0.1:54321.
    echo Start Docker Desktop if needed, then run: npx supabase start --debug
  ) else (
    echo Supabase is listening, but the health endpoint still failed.
    echo Check the local Supabase logs, then try again.
  )
  pause
  exit /b 1
)

echo.
echo Done. You can now press Retry in the app or run it again from Android Studio.
pause
