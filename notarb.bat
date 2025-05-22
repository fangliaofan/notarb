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

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$output = & '%java_exe_path%' -cp 'notarb-launcher.jar' org.notarb.launcher.Main '%script_dir_arg%' '%task_arg%' 2>&1;" ^
        "if ($LASTEXITCODE -ne 0) {" ^
        "    Write-Host $output -ForegroundColor Red;" ^
        "} else {" ^
        "    $lastLine = ($output | Out-String -Stream) | Select-Object -Last 1;" ^
        "    if ($lastLine -like 'cmd=*') {" ^
        "        $cmd = $lastLine.Substring(4).Trim();" ^
        "        Invoke-Expression ('& \"%java_exe_path%\" ' + $cmd);" ^
        "    } else {" ^
        "        Write-Host 'Unknown Output: ' -ForegroundColor Red;" ^
        "        Write-Host $lastLine -ForegroundColor Red;" ^
        "    }" ^
        "}"
exit /b

:execute
    call :detect_or_install_java

    set "script_dir_arg=%script_dir:\=/%"
    set "task_arg=%task:\=/%"

    set "temp_file=%temp%\notarb_launcher_out_%random%.tmp"

    "%java_exe_path%" -cp "notarb-launcher.jar" org.notarb.launcher.Main "%script_dir_arg%" "%task_arg%" > "%temp_file%" 2>&1

    if %errorlevel% equ 0 (
        rem Get the last line from the temp file using a simple approach
        for /f "tokens=*" %%i in ("%temp_file%") do set "out=%%i"
        call :get_last_line "%temp_file%"
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

    echo Installing Java, please wait... & echo. & echo.

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