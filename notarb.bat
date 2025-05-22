@echo off

set "script_dir=%~dp0"

set "task=%*"
set "java_exe_path="

call :execute
goto :eof

:execute
    call :detect_or_install_java

    set "script_dir_arg=%script_dir:\=/%"
    set "task_arg=%task:\=/%"

    set "temp_file=%temp%\notarb_launcher_out_%random%.tmp"

    "%java_exe_path%" -cp "notarb-launcher.jar" org.notarb.launcher.Main "%script_dir_arg%" "%task_arg%" > "%temp_file%" 2>&1
    if %errorlevel% == 0 (
        for /f "delims=" %%i in ('type "%temp_file%" ^| findstr /r ".*"') do set "task_args=%%i"
    ) else (
        type "%temp_file%"
    )

    del "%temp_file%"

    if defined task_args (
        "%java_exe_path%" %task_args%
    )
exit /b

:detect_or_install_java
    set "java_url=https://download.java.net/java/GA/jdk24.0.1/24a58e0e276943138bf3e963e6291ac2/9/GPL/openjdk-24.0.1_windows-x64_bin.zip"
    set "java_folder=jdk-24.0.1"

    set "java_exe_path=%script_dir%%java_folder%\bin\java.exe"

    if exist "%java_exe_path%" (
        "%java_exe_path%" --version
        if %errorlevel% == 0 (
            echo Java installation not required.
            exit /b
        )
    )

    echo. & echo.
    echo Installing Java, please wait...
    echo. & echo.

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$tempFile = Join-Path '%script_dir%' 'java_download_temp.zip';" ^
        "Invoke-WebRequest -Uri '%java_url%' -OutFile $tempFile;" ^
        "Expand-Archive -Path $tempFile -DestinationPath '%script_dir%' -Force;" ^
        "Remove-Item -Force $tempFile;"

    "%java_exe_path%" --version
    if %errorlevel% == 0 (
        echo Java installation successful!
    ) else (
        echo Warning: Java installation could not be verified!
    )
exit /b