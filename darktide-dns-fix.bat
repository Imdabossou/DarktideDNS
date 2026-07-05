@echo off
setlocal EnableDelayedExpansion

set "HOSTS_FILE=%WINDIR%\System32\drivers\etc\hosts"
set "MARKER_START=# BEGIN darktide-dns-fix"
set "MARKER_END=# END darktide-dns-fix"

set "SERVERS=echo-prod-aws-af-south-1.atoma.cloud echo-prod-aws-ap-east-1.atoma.cloud echo-prod-aws-ap-northeast-1.atoma.cloud echo-prod-aws-ap-northeast-2.atoma.cloud echo-prod-aws-ap-south-1.atoma.cloud echo-prod-aws-ap-southeast-1.atoma.cloud echo-prod-aws-ap-southeast-2.atoma.cloud echo-prod-aws-ca-central-1.atoma.cloud echo-prod-aws-eu-central-1.atoma.cloud echo-prod-aws-eu-north-1.atoma.cloud echo-prod-aws-eu-west-1.atoma.cloud echo-prod-aws-eu-west-2.atoma.cloud echo-prod-aws-me-south-1.atoma.cloud echo-prod-aws-sa-east-1.atoma.cloud echo-prod-aws-us-east-1.atoma.cloud echo-prod-aws-us-east-2.atoma.cloud echo-prod-aws-us-west-2.atoma.cloud echo-prod-ga-aws-af-south-1.atoma.cloud echo-prod-ga-aws-ap-east-1.atoma.cloud echo-prod-ga-aws-ap-northeast-1.atoma.cloud echo-prod-ga-aws-ap-northeast-2.atoma.cloud echo-prod-ga-aws-ap-southeast-1.atoma.cloud echo-prod-ga-aws-ap-southeast-2.atoma.cloud echo-prod-ga-aws-ca-central-1.atoma.cloud echo-prod-ga-aws-eu-central-1.atoma.cloud echo-prod-ga-aws-eu-north-1.atoma.cloud echo-prod-ga-aws-eu-west-1.atoma.cloud echo-prod-ga-aws-eu-west-2.atoma.cloud echo-prod-ga-aws-me-south-1.atoma.cloud echo-prod-ga-aws-sa-east-1.atoma.cloud echo-prod-ga-aws-us-east-1.atoma.cloud echo-prod-ga-aws-us-east-2.atoma.cloud echo-prod-ga-aws-us-west-1.atoma.cloud"

net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo Run this script as Administrator.>&2
    exit /b 1
)

set "TMP_FILE=%TEMP%\darktide-dns-fix-%RANDOM%.tmp"
if exist "%TMP_FILE%" del "%TMP_FILE%"

set "SKIP=0"
for /f "usebackq tokens=1* delims=:" %%A in (`findstr /n "^" "%HOSTS_FILE%"`) do (
    set "LINE=%%B"
    if "!LINE!"=="%MARKER_START%" set "SKIP=1"
    if "!SKIP!"=="0" (
        >>"%TMP_FILE%" echo(!LINE!
    )
    if "!LINE!"=="%MARKER_END%" set "SKIP=0"
)

>>"%TMP_FILE%" echo %MARKER_START%
for %%S in (%SERVERS%) do (
    call :resolve "%%S"
    if defined IP (
        >>"%TMP_FILE%" echo !IP! %%S
    )
)
>>"%TMP_FILE%" echo %MARKER_END%

copy /y "%TMP_FILE%" "%HOSTS_FILE%" >nul
del "%TMP_FILE%"

ipconfig /flushdns >nul 2>&1

endlocal
exit /b 0

:resolve
set "IP="
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "(Resolve-DnsName -Name '%~1' -Type A -ErrorAction SilentlyContinue | Where-Object { $_.Type -eq 'A' } | Select-Object -First 1 -ExpandProperty IPAddress)"`) do (
    set "IP=%%I"
)
exit /b 0
