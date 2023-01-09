@ECHO OFF
rem ECHO ------- OzFAD1 step 11 -------

rem Venn inspired barchart
"python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD_py_tools\OzFAD1_P_value_heatmap_data.py"

:END
ENDLOCAL
PAUSE
