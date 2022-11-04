@ECHO OFF
ECHO ------- OzFAD1 stage 3 -------
ECHO This batch file controls the de novo fatty acid analysis workflow using LC-OzID-MS data.
ECHO This stage creates a Skyline file containing the confirmed transitions applied to the data independent acquisition for the purpose of relative quantification of isomers.
ECHO This workflow was created by Jan Philipp Menzel, Mass Spectrometry Development Laboratory, Queensland University of Technology, 2021 / 2022.
ECHO Before running the workflow, make sure that:
ECHO ____
ECHO  1 There is enough diskspace available, recommended is at least 10 GB free space.
ECHO  2 The maximum retention time in the Transition Settings in the Skyline file template.sky is set according to the analysis.
ECHO  3 The dataset to be analysed (both DIA and DDA) and python programs are in the appropriate directories.
ECHO  4 The appropriate file skyl_report_dda_found.csv and OzFAD1_workflow_parameters.xlsx must be copied into OzFAD1.
ECHO ____

rem ECHO For instructions and further information see the publication: _.
set /p identifier=What is the identifier for this run of the workflow?:

SETLOCAL
set ROOT_ANALYSIS_DIR=%~dp0
set SKYLINE_RUNNER="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\SkylineRunner.exe"
set BAT_Script_DDA_Full="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_Full.bat"
set BAT_Script_DDA_First_Filter="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_First_Filter.bat"
set BAT_Script_DDA_Second_Filter="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_Second_Filter.bat"
set BAT_Script_DDA_DIA_rt_shift1="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_DIA_rt_shift1.bat"
set BAT_Script_DDA_Summarize="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_summarize.bat"
set BAT_Script_DDA_Summarize2="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_summarize2.bat"
set LOG="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\workflow_log_files\Import.log"
FOR /F %%A IN ('WMIC OS GET LocalDateTime ^| FINDSTR \.') DO @SET DT=%%A
set LOG_ROLLOVER="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\workflow_log_files\Import_%DT:~0,8%_%DT:~8,6%.log"

if exist %LOG% move %LOG% %LOG_ROLLOVER%

rem method starts here by reading into python the results file of the selected skyline file

rem generate transition list with 16:1_n-7_cis straight chain as an anchor for detecting rt shift between DDA and DIA datasets
"C:\Users\menzel2\AppData\Local\Programs\Python\Python39\python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_dda_to_dia_3_rt_shift1.py"

rem run DIA dataset with transition list with 16:1_n-7_cis straight chain, export chromatograms
call %BAT_Script_DDA_DIA_rt_shift1%  OzFAD1_results DIA_current_LCMS_dataset %identifier% 100000 12 "template.sky"

rem run python script to calculate rt shifted transition list for DIA analysis with DDA confirmed species
"C:\Users\menzel2\AppData\Local\Programs\Python\Python39\python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_dda_to_dia_4_rt_shift2.py"

rem run final Skyline analysis of DIA dataset using transition list from DDA analysis for manual assessment
call %BAT_Script_DDA_Summarize%  OzFAD1_results DIA_current_LCMS_dataset %identifier% 100000 12 "template.sky"
rem The last Skyline file needs to be manually assessed to make sure that integration limits are set correctly

rem begin integration failure detection and exrt reset for failed entries
"C:\Users\menzel2\AppData\Local\Programs\Python\Python39\python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_dda_to_dia_4_integrationcheck.py"

call %BAT_Script_DDA_Summarize2%  OzFAD1_results DIA_current_LCMS_dataset %identifier% 100000 12 "template.sky"
rem end integration failure detection and exrt reset for failed entries

rem begin move results files excel and csv to folder in OzFAD1_results location of current run
md OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\OzFAD1_workflow_parameters.xlsx %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\jpmlipidomics_dda_vpw20_3_rt_shift1.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_report_dda_vpw20_3_rt_shift1.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_xic_dda_report_vpw20_3.tsv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_xic_dda_report_vpw20_3_times.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_xic_dda_report_vpw20_3_intensities.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\jpmlipidomics_dda_vpw20_4_rt_shifted.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_report_vpw20_6_DDA_confirmed_DIA_rt_shifted.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\jpmlipidomics_dda_vpw20_4_int_check.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_report_vpw20_6_DDA_confirmed_DIA_int_check.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_report_dda_found.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
rem end move results files excel and csv to folder in OzFAD1_results location of current run

if %ERRORLEVEL% NEQ 0 GOTO END
GOTO END
:END
ENDLOCAL
PAUSE
