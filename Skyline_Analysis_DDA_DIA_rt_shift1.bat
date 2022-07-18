@echo off
SETLOCAL

set BASE_NAME=%1
set DATA_DIR=%2
set MODEL_NAME=%3
set FILTER_RES=%4
set FILTER_TIME=%5
set SKYLINE_FILE=%6
set SKYLINE_FILE=%SKYLINE_FILE:"=%

set STARTTIME=%TIME%

set ROOT_DIR=%ROOT_ANALYSIS_DIR%\%BASE_NAME%
set SKYD_FILE="%ROOT_ANALYSIS_DIR%\%SKYLINE_FILE%d"

echo [%STARTTIME%] Running trial %MODEL_NAME%...
echo [%STARTTIME%] Running trial %MODEL_NAME%... >> %LOG%
rem GOTO REPORT

rem Save to new location to allow parallel processing
%SKYLINE_RUNNER% --timestamp --dir="%ROOT_DIR%" --in="..\%SKYLINE_FILE%" --out="%MODEL_NAME%\jpmlipidomics_dda_vpw20_3_rt_shift1.sky" >> %LOG%

rem Do the analysis in the new location
%SKYLINE_RUNNER% --timestamp --dir="%ROOT_DIR%" --in="%MODEL_NAME%\jpmlipidomics_dda_vpw20_3_rt_shift1.sky" --import-transition-list=%ROOT_ANALYSIS_DIR%\jpmlipidomics_dda_vpw20_3_rt_shift1.csv --save --import-lockmass-positive=556.2771 --import-lockmass-tolerance=0.5 --import-all="%ROOT_ANALYSIS_DIR%\DIA_current_LCMS_dataset" --import-naming-pattern="_([^_]*)$" --save --report-add="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\skyline_report_vpw15.skyr" --report-conflict-resolution=overwrite --report-name=skyl_report_template_vpw15 --report-file="%ROOT_ANALYSIS_DIR%\skyl_report_dda_vpw20_3_rt_shift1.csv" --report-invariant --chromatogram-products --chromatogram-file="%ROOT_ANALYSIS_DIR%\skyl_xic_dda_report_vpw20_3.tsv" >> %LOG%

rem convert tsv to csv file(s) containing XIC intensities
"C:\Users\menzel2\AppData\Local\Programs\Python\Python39\python.exe" "C:\Users\menzel2\pythonprogramming\jpmlipidomics\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_dda_3_jpmtsvtocsv.py"

if %ERRORLEVEL% NEQ 0 GOTO END

:REPORT

:END
