@ECHO OFF
rem ECHO ------- OzFAD1 step 11 -------

set fourlettcode=%1%
set cderiv=%2%
set hderiv=%3%
set dderiv=%4%
set nderiv=%5%
set oderiv=%6%
set pderiv=%7%
set ideriv=%8%

rem ECHO %cderiv%

rem Venn inspired barchart
"python.exe" "%~dp0\OzFAD1_py\OzFAD_py_tools\OzFAD1_5_Plot_Table.py" %fourlettcode% %cderiv% %hderiv% %dderiv% %nderiv% %oderiv% %pderiv% %ideriv%

:END
ENDLOCAL
rem PAUSE
