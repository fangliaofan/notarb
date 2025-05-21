@echo off
setlocal enabledelayedexpansion

set "script_dir=%~dp0"

set "task=%*"
set "java_exe_path="

call :execute
goto :eof

:execute
    call :detect_or_install_java

    set "CMD="

    powershell -Command "& {
        $output = & \"%java_exe_path%\" -cp \"notarb-launcher.jar\" org.notarb.launcher.Main \"%script_dir%\" \"%task%\" 2>&1
        $lastLine = $output | Select-Object -Last 1

        if ($lastLine -like 'cmd=*') {
            $env:CMD = $lastLine.Substring(4)
            exit 0
        } else {
            foreach ($line in $output) {
                Write-Host $line
            }
            exit 1
        }
    }"

    if not errorlevel 1 (
        "%java_exe_path%" %CMD%
    )
exit /b

:detect_or_install_java
    set "java_url=https://download.java.net/java/GA/jdk24.0.1/24a58e0e276943138bf3e963e6291ac2/9/GPL/openjdk-24.0.1_windows-x64_bin.zip"
    set "java_folder=jdk-24.0.1"

    set "java_exe_path=%script_dir%%java_folder%\bin\java.exe"

    if exist "%java_exe_path%" (
        "%java_exe_path%" --version
        if !errorlevel! == 0 (
            echo Java installation not required.
            exit /b
        )
    )

    echo Installing Java, please wait...
    echo.
    echo.

    powershell -Command "
        $tempFile = Join-Path \"%script_dir%\" \"java_download_temp.zip\"
        Invoke-WebRequest -Uri '%java_url%' -OutFile $tempFile
        Expand-Archive -Path $tempFile -DestinationPath \"%script_dir%\" -Force
        Remove-Item -Force $tempFile
    "

    "%java_exe_path%" --version
    if !errorlevel! == 0 (
        echo Java installation successful!
    ) else (
        echo Warning: Java installation could not be verified!
    )
exit /b