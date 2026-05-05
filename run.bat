@echo off
setlocal enabledelayedexpansion

set JAVA_HOME=C:\Users\gamba\.jdks\corretto-25.0.1
set PATH=!JAVA_HOME!\bin;!PATH!

echo Starting Daily Devotional Bot...
echo JAVA_HOME: !JAVA_HOME!
echo All logs will be displayed below:
echo ================================
echo.

echo Building the application...
call mvnw clean install
echo.
echo Build complete. Starting the application...
echo.

call mvnw spring-boot:run

pause
