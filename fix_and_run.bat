@echo off
echo ==========================================
echo      POS FIX & RUN SCRIPT
echo ==========================================

echo [1/6] Killing lingering processes...
taskkill /F /IM dart.exe >nul 2>&1
taskkill /F /IM flutter.exe >nul 2>&1
taskkill /F /IM java.exe >nul 2>&1

echo [2/6] Waiting for locks to release...
timeout /t 3 /nobreak >nul

echo [3/6] Force cleaning build directories...
if exist build (
    echo Deleting build folder...
    rd /s /q build
)
if exist .dart_tool (
    echo Deleting .dart_tool folder...
    rd /s /q .dart_tool
)

echo [4/6] Running Flutter Clean...
call C:\src\flutter\bin\flutter.bat clean

echo [5/6] Getting Dependencies...
call C:\src\flutter\bin\flutter.bat pub get

echo [6/6] Running App...
echo Opening Chrome...
call C:\src\flutter\bin\flutter.bat run -d chrome --web-port 55555

echo.
echo ==========================================
echo      DONE
echo ==========================================
pause
