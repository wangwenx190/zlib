@echo off
setlocal
if not defined VSCMD_VER (
    call :init_msvc
    if errorlevel 1 exit /b 1
)
cmake -S "%~dp0." -B "%~dp0build" -G Ninja -DCMAKE_BUILD_TYPE=Release %*
if errorlevel 1 exit /b 1
cmake --build "%~dp0build" --parallel
exit /b %errorlevel%

:init_msvc
set "vswhere=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%vswhere%" (
    >&2 echo Install Visual Studio with the Desktop development with C++ workload.
    exit /b 1
)
for /f "usebackq delims=" %%I in (`"%vswhere%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "vsroot=%%I"
if not defined vsroot exit /b 1
call "%vsroot%\VC\Auxiliary\Build\vcvars64.bat"
exit /b %errorlevel%
