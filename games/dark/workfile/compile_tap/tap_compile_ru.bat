@echo off

..\..\..\bas2tap\bas2tap.exe -q -a10 -s"TbMA" tap.txt

..\..\..\util\taptool\taptool.exe +f tap.tap ..\Get_Dark.bin Get_Dark C 24576
..\..\..\util\taptool\taptool.exe +f tap.tap ..\The_Dark_ru.bin The_Dark C 24576

rename tap.tap TheDark_ru.tap

pause