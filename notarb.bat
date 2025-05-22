@echo off

set "script_dir=%~dp0"
set "task_dir=%*"

set "java_url=https://download.java.net/java/GA/jdk24.0.1/24a58e0e276943138bf3e963e6291ac2/9/GPL/openjdk-24.0.1_windows-x64_bin.zip"
set "java_folder=jdk-24.0.1"
set "java_exe_path=%script_dir%%java_folder%\bin\java.exe"

if exist "%java_exe_path%" (
    "%java_exe_path%" --version
    if not errorlevel 1 (
        echo Java installation not required.
        goto :launch
    )
)

echo Installing Java, please wait...
echo "%java_url%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$tempFile = Join-Path '%script_dir%' 'java_download_temp.zip';" ^
    "Invoke-WebRequest -Uri '%java_url%' -OutFile $tempFile;" ^
    "Write-Host 'Download complete, extracting...'; " ^
    "Expand-Archive -Path $tempFile -DestinationPath '%script_dir%' -Force;" ^
    "Write-Host 'Extraction complete, cleaning up...'; " ^
    "Remove-Item -Force $tempFile;" ^
    "Write-Host 'Java installation finished.'"

echo. & echo.
echo Verifying java installation...
"%java_exe_path%" --version
if not errorlevel 1 (
    echo Java installation successful!
) else (
    echo Warning: Java installation could not be verified!
)

:launch
echo. & echo.
set "script_dir_arg=%script_dir:\=/%"
set "task_dir_arg=%task_dir:\=/%"
set "args_file=%temp%\na_task_args_%random%.tmp"

"%java_exe_path%" -cp "notarb-launcher.jar" org.notarb.launcher.Main "%script_dir_arg%" "%task_dir_arg%" "%args_file%"
if not errorlevel 1 (
    set /p args=<"%args_file%"
    del "%args_file%" 2>nul
    call "%java_exe_path%" %%args%%
) else (
    del "%args_file%" 2>nul
)