@echo off
setlocal

set "PLATFORM=%~1"
set "CONFIGURATION=%~2"
if not defined CONFIGURATION set "CONFIGURATION=Release"

set "SOLUTION=%~dp0..\build\zoteroWinWordIntegration\zoteroWinWordIntegration.sln"

if not defined MSBUILD (
  for /f "usebackq tokens=*" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do set "MSBUILD=%%i"
)

if not defined MSBUILD (
  echo Could not locate MSBuild. Install Visual Studio 2022 with the C++ build tools. 1>&2
  exit /b 1
)

echo Using %MSBUILD%
if not defined PLATFORM goto build_all
call :build %PLATFORM%
if errorlevel 1 goto build_failed
goto build_succeeded

:build_all
call :build Win32
if errorlevel 1 goto build_failed
call :build x64
if errorlevel 1 goto build_failed
call :build ARM64
if errorlevel 1 goto build_failed

:build_succeeded
exit /b 0

:build_failed
exit /b 1

:build
echo.
echo Building %CONFIGURATION%^|%~1
"%MSBUILD%" "%SOLUTION%" /m /nologo /p:Configuration=%CONFIGURATION% /p:Platform=%~1
exit /b %ERRORLEVEL%
