@echo off
SETLOCAL

set BASE_NAME=results_files
set DATA_DIR=current_lcms_dataset
set MODEL_NAME=%identifier%
set FILTER_RES=100000
set FILTER_TIME=12
set SKYLINE_FILE="template.sky"
set SKYLINE_FILE=%SKYLINE_FILE:"=%

set STARTTIME=%TIME%

set ROOT_DIR=%ROOT_ANALYSIS_DIR%\%BASE_NAME%
set SKYD_FILE="%ROOT_ANALYSIS_DIR%\%SKYLINE_FILE%d"

echo [%STARTTIME%] Running trial %MODEL_NAME%...
echo [%STARTTIME%] Running trial %MODEL_NAME%... >> %LOG%
rem GOTO REPORT

rem Save to new location to allow parallel processing
%SKYLINE_RUNNER% --timestamp --dir="%ROOT_DIR%" --in="..\%SKYLINE_FILE%" --out="%MODEL_NAME%\jpmlipidomics_vpw20_3_1st_filter.sky" >> %LOG%

rem Do the analysis in the new location
%SKYLINE_RUNNER% --timestamp --dir="%ROOT_DIR%" --in="%MODEL_NAME%\jpmlipidomics_vpw20_3_1st_filter.sky" --import-transition-list=%ROOT_ANALYSIS_DIR%\jpmlipidomics_vpw20_3_1st_filter.csv --save --import-lockmass-positive=556.2771 --import-lockmass-tolerance=0.5 --import-all="%ROOT_ANALYSIS_DIR%\DIA_current_LCMS_dataset" --import-naming-pattern="_([^_]*)$" --save --report-add="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\skyline_report_vpw15.skyr" --report-conflict-resolution=overwrite --report-name=skyl_report_template_vpw15 --report-file="%ROOT_ANALYSIS_DIR%\skyl_report_vpw20_3.csv" --report-invariant --chromatogram-products --chromatogram-file="%ROOT_ANALYSIS_DIR%\skyl_xic_report_vpw20_3.tsv" >> %LOG%

rem convert tsv to csv file(s) containing XIC intensities
"C:\Users\menzel2\AppData\Local\Programs\Python\Python39\python.exe" "C:\Users\menzel2\pythonprogramming\jpmlipidomics\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_4_jpmtsvtocsv.py"

rem Filter results and prepare for manual skyline analysis
"C:\Users\menzel2\AppData\Local\Programs\Python\Python39\python.exe" "C:\Users\menzel2\pythonprogramming\jpmlipidomics\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_4_filter2_tr.py"

if %ERRORLEVEL% NEQ 0 GOTO END

:REPORT

:END

set ENDTIME=%TIME%

rem Change formatting for the start and end times
for /F "tokens=1-4 delims=:.," %%a in ("%STARTTIME%") do (
   set /A "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)
for /F "tokens=1-4 delims=:.," %%a in ("%ENDTIME%") do (
   set /A "end=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)

rem Calculate the elapsed time by subtracting values
set /A elapsed=end-start
rem we might have measured the time inbetween days
if %end% LSS %start% set /A elapsed=(24*60*60*100 - start) + end

    rem Format the results for output
set /A hh=elapsed/(60*60*100), rest=elapsed%%(60*60*100), mm=rest/(60*100), rest%%=60*100, ss=rest/100, cc=rest%%100
if %hh% lss 10 set hh=0%hh%
if %mm% lss 10 set mm=0%mm%
if %ss% lss 10 set ss=0%ss%
if %cc% lss 10 set cc=0%cc%

set DURATION=%hh%:%mm%:%ss%.%cc%

echo. >> %LOG%
echo [%ENDTIME%] Completed trial %MODEL_NAME%... >> %LOG%
echo [%ENDTIME%] =^> Elapsed time: %DURATION%
echo [%ENDTIME%] =^> Elapsed time: %DURATION% >> %LOG%
echo. >> %LOG%
echo. >> %LOG%

ENDLOCAL