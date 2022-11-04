@ECHO OFF
ECHO ------- OzFAD1 stage 1 -------
ECHO This batch file controls the de novo fatty acid analysis workflow using LC-OzID-MS data. 
ECHO This stage enables calculation of a target list for the data dependent acquisition.
ECHO The workflow was created by Dr. Jan Philipp Menzel,
ECHO Mass Spectrometry Development Laboratory, Queensland University of Technology, 2021 / 2022.
ECHO Before running the workflow, make sure that:
ECHO  1 There is enough diskspace available, recommended is at least 10 GB free space.
ECHO  2 The maximum retention time in the Transition Settings in the Skyline file template.sky is set according to the analysis.
ECHO  3 The dataset to be analysed and python programs are in the appropriate directories.

rem To install this file on a computer, modify the links to the folder location of your python version and the python scripts associated to this batch file.
rem Tip: Use the find and replace function in Notepad++ to make the changes in all batch files at once.
rem For example: replace "menzel2" with your username and "Python39" with your python version.

rem ECHO For instructions and further information see the publication: _.
set /p identifier=What is the identifier for this run of the workflow?:
set /p targetsonly=Run complete analysis of DIA dataset [2] or only run precursor analysis and generate target list [1] ?:
rem run python script to make transition list containing 16:0 and 18:0

"C:\Users\menzel2\AppData\Local\Programs\Python\Python39\python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_0_precheck.py" %identifier%

SETLOCAL
set ROOT_ANALYSIS_DIR=%~dp0
set SKYLINE_RUNNER="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\SkylineRunner.exe"
set BAT_Script_Precheck="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_Precheck.bat"
set BAT_Script_Precursor="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_Precursor.bat"
set BAT_Script_Full="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_Full.bat"
set BAT_Script_First_Filter="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_First_Filter.bat"
set BAT_Script_Second_Filter="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_Second_Filter.bat"
set LOG="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\workflow_log_files\Import.log"
FOR /F %%A IN ('WMIC OS GET LocalDateTime ^| FINDSTR \.') DO @SET DT=%%A
set LOG_ROLLOVER="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\workflow_log_files\Import_%DT:~0,8%_%DT:~8,6%.log"

if exist %LOG% move %LOG% %LOG_ROLLOVER%

rem run precheck precursor only Skyline analysis, export chromatograms, convert tsv file to csv files
call %BAT_Script_Precheck%  OzFAD1_results DIA_current_LCMS_dataset %identifier% 100000 12 "template.sky"

rem Generate transition list (precursor only) 
"C:\Users\menzel2\AppData\Local\Programs\Python\Python39\python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_1_precursor.py"

rem run precursor only Skyline analysis
call %BAT_Script_Precursor%  OzFAD1_results DIA_current_LCMS_dataset %identifier% 100000 12 "template.sky"

rem Generate full transition list with aldehyde and criegee product transitions
"C:\Users\menzel2\AppData\Local\Programs\Python\Python39\python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_2_full.py"

if %targetsonly%==1 (GOTO END) else (echo "Full analysis of DIA dataset begins")

call %BAT_Script_Full%  OzFAD1_results DIA_current_LCMS_dataset %identifier% 100000 12 "template.sky"

rem Filter results and generate transition lists containing decoys for analysis in Skyline, split into multiple lists, if many transitions
"C:\Users\menzel2\AppData\Local\Programs\Python\Python39\python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_3_filter1.py"

rem Run second filter on merged or output transition list
call %BAT_Script_Second_Filter%  OzFAD1_results DIA_current_LCMS_dataset %identifier% 100000 12 "template.sky"

if %ERRORLEVEL% NEQ 0 GOTO END
GOTO END
:END 

rem begin make new folder and Move results files excel and csv to folder in OzFAD1_results location of current run
md OzFAD1_results\%identifier%\transition_lists_and_report_csv_files
copy %~dp0\OzFAD1_workflow_parameters.xlsx %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files

move %~dp0\jpmlipidomics_vpw20_0_precheck.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files
move %~dp0\jpmlipidomics_vpw20_1_precursor.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files
move %~dp0\jpmlipidomics_vpw20_2_full_list.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files
move %~dp0\jpmlipidomics_vpw20_2_precursor_analysis.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files
move %~dp0\skyl_report_vpw20_0.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files
move %~dp0\skyl_report_vpw20_1.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files
move %~dp0\skyl_xic_report_vpw20_0_precheck.tsv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files
move %~dp0\skyl_xic_report_vpw20_0_intensities.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files
move %~dp0\skyl_xic_report_vpw20_0_times.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files
move %~dp0\jpmlipidomics_dda_targetlist.txt %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files
rem end make new folder and Move results files excel and csv to folder in OzFAD1_results location of current run

echo The calculation is completed.
rem :END
ENDLOCAL
PAUSE
