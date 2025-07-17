@echo off
cd
if [%1]==[] goto defined
echo %1 > res\config
goto cont
:defined
echo default config
echo default.txt > res\config
:cont
res\sjasmplus.exe res\alf_auto_v02.a80 -l
pause 0