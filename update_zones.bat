@echo off
REM ============================================================
REM  update_zones.bat
REM  Svalq posledniya dron-zoni JSON ot caa.bg, regenere
REM  zones_geo.json (za kartata) i otvori kartata v brauzera.
REM  Iziskvania: Python 3.11+, PowerShell.
REM ============================================================

chcp 65001 >NUL
setlocal enabledelayedexpansion
cd /d "%~dp0"

REM --- 1/5: extract latest zoned JSON URL from caa.bg --------------
echo [1/5] Tarsi posledniya link za zonite na caa.bg...
powershell -NoProfile -ExecutionPolicy Bypass -File _caa_get_link.ps1 > _caa_link.txt 2> _caa_err.txt
if errorlevel 1 (
    echo   GRESHKA: ne namerih link.
    type _caa_err.txt
    del _caa_link.txt _caa_err.txt 2>NUL
    exit /b 1
)
set /p CAA_ZIP_PATH=<_caa_link.txt
del _caa_err.txt 2>NUL
if "%CAA_ZIP_PATH%"=="" (
    echo   GRESHKA: prazen link.
    del _caa_link.txt 2>NUL
    exit /b 1
)
set CAA_ZIP_URL=https://www.caa.bg%CAA_ZIP_PATH%
for %%I in ("%CAA_ZIP_PATH%") do set ZIP_NAME=%%~nxI
for %%I in ("!ZIP_NAME:.zip=!") do set BASE_NAME=%%~I
del _caa_link.txt 2>NUL

echo   Link: %CAA_ZIP_URL%
echo   ZIP:  !ZIP_NAME! -^> JSON: !BASE_NAME!.json

REM --- 2/5: download the ZIP ---------------------------------------
echo.
echo [2/5] Svalqm ZIP-a...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%CAA_ZIP_URL%' -OutFile '%ZIP_NAME%'"
if errorlevel 1 (
    echo   GRESHKA: svalqneto neuspeshno.
    exit /b 1
)
echo   Gotovo.

REM --- 3/5: unzip --------------------------------------------------
echo.
echo [3/5] Razarhiviram...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%ZIP_NAME%' -DestinationPath '.' -Force"
if errorlevel 1 (
    echo   GRESHKA: razarhivirane neuspeshno.
    exit /b 1
)
if not exist "!BASE_NAME!.json" (
    echo   GRESHKA: !BASE_NAME!.json ne e nameren.
    exit /b 1
)
echo   Gotovo.

REM --- 4/5: regenerate zones_geo.json -----------------------------
echo.
echo [4/5] Regeneriram zones_geo.json...
python regen_geojson.py "!BASE_NAME!.json" zones_geo.json
if errorlevel 1 (
    echo   GRESHKA: regen. neuspeshen.
    exit /b 1
)
echo.

REM --- 5/5: start server (if needed) and open browser --------------
echo [5/5] Startiram lokalen HTTP survur (ako ne e pusnat) i otvaryam kartata...
powershell -NoProfile -ExecutionPolicy Bypass -File _port_check.ps1 > _port.txt 2>NUL
set /p PORT_STATUS=<_port.txt
del _port.txt 2>NUL

set SERVER_TITLE=DroneBG-Server
if /I "%PORT_STATUS%"=="FREE" (
    echo   Port 127.0.0.1:8765 e svoboden. Startiram survur...
    start "%SERVER_TITLE%" /B python -m http.server 8765 --bind 127.0.0.1
    timeout /t 2 /nobreak >NUL
) else (
    echo   Survurut veche raboti na 127.0.0.1:8765.
)

set RAND_SUFFIX=%RANDOM%
set "URL=http://127.0.0.1:8765/drones_bg.html?v=%RAND_SUFFIX%#updated"
echo   Otvaryam: %URL%
start "" "%URL%"

echo.
echo Gotovo. Kartata trqbva da se otvori v brauzera ti.
echo Za da spresh survura: zatvorhi prozoreca "%SERVER_TITLE%".
