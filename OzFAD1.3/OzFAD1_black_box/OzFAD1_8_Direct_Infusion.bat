@ECHO OFF
rem ECHO ------- OzFAD1 step 11 -------

set fourlettcode=%1%
set intcutoff=%2%
set minlenfa=%3%
set maxlenfa=%4%
set ftmix=%5%
set cderiv=%6%
set hderiv=%7%
set dderiv=%8%
set nderiv=%9%
shift
set oderiv=%9%
shift
set pderiv=%9%
shift
set ideriv=%9%

rem ECHO %fourlettcode%
rem ECHO %oderiv%
rem ECHO %pderiv%
rem ECHO %ideriv%

rem Venn inspired barchart
"python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD_py_tools\OzFAD1_Direct_Infusion.py" %fourlettcode% %intcutoff% %minlenfa% %maxlenfa% %ftmix% %cderiv% %hderiv% %dderiv% %nderiv% %oderiv% %pderiv% %ideriv%

:END
ENDLOCAL
rem PAUSE
