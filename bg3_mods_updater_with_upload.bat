@echo off
setlocal enabledelayedexpansion

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                   Set the following directories                   ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set bg3mm=D:\Users\Documents\BG3ModManager_Latest\BG3ModManager.exe
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set steam_common_folder=C:\Program Files (x86)\Steam\steamapps\common

set plb_legacy_zip=%cd%\plb_legacy_v*.zip
set plb_multiplayer_zip=%cd%\plb_multiplayer_patch_v*.zip
set hfu_zip=%cd%\hfu_v*.zip

set plb_legacy_folder=%cd%\plb_legacy
set plb_multiplayer_folder=%cd%\plb_multiplayer_patch
set plb_multiplayer_bat=%plb_multiplayer_folder%\PartyLimitBegonePatcher.bat

set bg3_data_folder=%steam_common_folder%\Baldurs Gate 3\Data
set bg3_bin=%steam_common_folder%\Baldurs Gate 3\bin
set local_versions_file=%bg3_data_folder%\Mods\versions.txt

set plb_legacy_updated=0
set plb_multiplayer_updated=0
set hfu_updated=0

set github_url=https://raw.githubusercontent.com/mranderson2020/the-squads-bg3-mods/master

set plb_legacy_local_version=0
set plb_multiplayer_local_version=0
set hfu_local_version=0


:::::::::::::
set github_folder=D:\Users\Downloads\the-squads-bg3-mods
set mod_uploader=D:/Users/Downloads/the-squads-bg3-mods/bg3_mods_github_uploader.sh
set update_checker=%github_folder%\bg3_mods_update_checker.ps1

echo. & echo Pushing mod updates to GitHub...
"C:\Program Files\Git\bin\bash.exe" -c "%mod_uploader%"
:::::::::::::


echo. & echo Getting GitHub versions...
for /f "delims=" %%i in ('curl "%github_url%/versions.txt"') do (
  set "line=%%i"
  if not "!line:plb_legacy_local_version=!"=="!line!" (
    for /f "tokens=2 delims==" %%a in ("!line!") do (
      set "plb_legacy_local_version=%%a"
    )
  )
  if not "!line:plb_multiplayer_local_version=!"=="!line!" (
    for /f "tokens=2 delims==" %%a in ("!line!") do (
      set "plb_multiplayer_local_version=%%a"
    )
  )
  if not "!line:hfu_local_version=!"=="!line!" (
    for /f "tokens=2 delims==" %%a in ("!line!") do (
      set "hfu_local_version=%%a"
    )
  )
)

set plb_legacy_local_version_installed=0
set plb_multiplayer_local_version_installed=0
set hfu_local_version_installed=0
set local_file_path=%bg3_data_folder%\Mods\versions.txt

echo. & echo Getting installed versions...
for /f "delims=" %%i in ('type "%local_file_path%"') do (
  set "line=%%i"
  if not "!line:plb_legacy_local_version_installed=!"=="!line!" (
    for /f "tokens=2 delims==" %%a in ("!line!") do (
      set "plb_legacy_local_version_installed=%%a"
    )
  )
  if not "!line:plb_multiplayer_local_version_installed=!"=="!line!" (
    for /f "tokens=2 delims==" %%a in ("!line!") do (
      set "plb_multiplayer_local_version_installed=%%a"
    )
  )
  if not "!line:hfu_local_version_installed=!"=="!line!" (
    for /f "tokens=2 delims==" %%a in ("!line!") do (
      set "hfu_local_version_installed=%%a"
    )
  )
)

echo. & echo Downloading latest versions...

curl -O "%github_url%/plb_multiplayer_patch_v%plb_multiplayer_local_version%.zip"

if %plb_legacy_local_version% NEQ %plb_legacy_local_version_installed% (
  curl -O "%github_url%/plb_legacy_v%plb_legacy_local_version%.zip"
)

if %hfu_local_version% NEQ %hfu_local_version_installed% (
  set hfu_updated=1
  curl -O "%github_url%/hfu_v%hfu_local_version%.zip"
) else (
  set hfu_updated=0
)


if exist "%plb_legacy_zip%" (
  echo Extracting latest Party Limit Begone Legacy archive...
  set plb_legacy_updated=1
  powershell -Command "try { $files = Get-ChildItem -Path '%plb_legacy_zip%'; $latest = $files | Sort-Object BaseName -Descending | Select-Object -First 1; $latest | ForEach-Object { Expand-Archive -Path $_.FullName -DestinationPath '%plb_legacy_folder%' -Force } } catch { Write-Host 'Error processing Party Limit Begone Legacy archive' -ForegroundColor Red }"
  
  echo. & echo Moving Mods folder to Baldurs Gate 3 Data folder...
  robocopy "%plb_legacy_folder%\Mods" "%bg3_data_folder%\Mods" /E /IS /MOVE
) else (
  set plb_legacy_updated=0
)

if exist "%plb_multiplayer_zip%" (
  echo. & echo Extracting latest Party Limit Begone Multiplayer Patch archive...
  set plb_multiplayer_updated=1
  powershell -Command "try { $files = Get-ChildItem -Path '%plb_multiplayer_zip%'; $latest = $files | Sort-Object BaseName -Descending | Select-Object -First 1; $latest | ForEach-Object { Expand-Archive -Path $_.FullName -DestinationPath '%plb_multiplayer_folder%' -Force } } catch { Write-Host 'Error processing Party Limit Begone Multiplayer Patch archive' -ForegroundColor Red }"
) else (
  set plb_multiplayer_updated=0
)

echo. & echo Running Party Limit Begone Multiplayer Patch...
cd /d "%bg3_bin%"
if exist "%plb_multiplayer_bat%" (
  call "%plb_multiplayer_bat%" "%bg3_bin%\bg3_dx11.exe"
) else (
  powershell Write-Host `nParty Limit Begone Multiplayer Patch batch file not found. -ForegroundColor Red
  pause
  exit /b
)


echo. & echo Writing local versions to file...
echo plb_legacy_local_version_installed=%plb_legacy_local_version% > "%local_versions_file%"
echo plb_multiplayer_local_version_installed=%plb_multiplayer_local_version% >> "%local_versions_file%"
echo hfu_local_version_installed=%hfu_local_version% >> "%local_versions_file%"


echo. & echo Cleaning up...
if exist "%plb_legacy_folder%" rd /S /Q "%plb_legacy_folder%"
if exist "%plb_multiplayer_folder%" rd /S /Q "%plb_multiplayer_folder%"
if exist "%plb_legacy_zip%" del /F /Q "%plb_legacy_zip%"
if exist "%plb_multiplayer_zip%" del /F /Q "%plb_multiplayer_zip%"
if exist "%current_dir%\hfu_v%hfu_local_version_installed: =%.zip" del /F /Q "%current_dir%\hfu_v%hfu_local_version_installed: =%.zip"

echo.

if !plb_legacy_updated!==1 (
  powershell Write-Host Party Limit Begone Legacy installed. -ForegroundColor Green
)

if !plb_multiplayer_updated!==1 (
  powershell Write-Host Party Limit Begone Multiplayer Patch installed. -ForegroundColor Green
)

if !hfu_updated!==1 (
  powershell Write-Host Honour Features Unlocker downloaded. Install via BG3 Mod Manager. -ForegroundColor Green
  %bg3mm%
)

:::::::::::::
echo. & echo Checking for mod updates...
if exist "%update_checker%" (
  cd /d "%github_folder%"
  powershell -ExecutionPolicy Bypass -File "%update_checker%"
) else (
  powershell Write-Host `nMod update checker script not found. -ForegroundColor DarkYellow
)
:::::::::::::

powershell Write-Host -ForegroundColor DarkCyan `nDone.
pause

endlocal