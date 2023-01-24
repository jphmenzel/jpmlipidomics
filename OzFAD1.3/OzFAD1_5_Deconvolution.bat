@ECHO OFF
rem ECHO ------- OzFAD1 stage 4 -------
rem ECHO This batch file controls the de novo fatty acid analysis workflow, stage 4, deconvolution.
rem ECHO This stage enables deconvolution and relative quantification, using DDA confirmed, selected, integral limit corrected DIA LC-OzID-MS data.
rem ECHO This workflow was created by Jan Philipp Menzel, Mass Spectrometry Development Laboratory, Queensland University of Technology, 2021 / 2022.
rem ECHO Before running the workflow, make sure that:
rem ECHO ____
rem ECHO  1 There is enough diskspace available, recommended is at least 10 GB free space.
rem ECHO  2 The maximum retention time in the Transition Settings in the Skyline file template.sky is set according to the analysis.
rem ECHO  3 The dataset to be analysed (both DIA and DDA) and python programs are in the appropriate directories.
rem ECHO  4 The appropriate files skyl_report_dia_int.csv; skyl_report_dia_xic.tsv and OzFAD1_workflow_parameters.xlsx must be copied into OzFAD1
rem ECHO ____

rem ECHO For instructions and further information see the publication: _.
rem set /p identifier=What is the identifier for this run of the workflow?:
set identifier=%1

SETLOCAL
set ROOT_ANALYSIS_DIR=%~dp0
set SKYLINE_RUNNER="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\SkylineRunner.exe"
set BAT_Script_DDA_Full="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_Full.bat"
set BAT_Script_DDA_First_Filter="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_First_Filter.bat"
set BAT_Script_DDA_Second_Filter="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_Second_Filter.bat"
set BAT_Script_DDA_DIA_rt_shift1="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_DIA_rt_shift1.bat"
set BAT_Script_DDA_Summarize="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_summarize.bat"
set LOG="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\workflow_log_files\Import.log"
FOR /F %%A IN ('WMIC OS GET LocalDateTime ^| FINDSTR \.') DO @SET DT=%%A
set LOG_ROLLOVER="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\workflow_log_files\Import_%DT:~0,8%_%DT:~8,6%.log"

if exist %LOG% move %LOG% %LOG_ROLLOVER%

rem method starts here by reading into python the results file of the selected skyline file, skyl_report_dda_filtered_selected.csv, carries out preliminary final analysis

rem convert tsv file to csv files with XICs
rem "C:\Users\menzel2\AppData\Local\Programs\Python\Python39\python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_5_jpmtsvtocsv.py"
"python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_5_jpmtsvtocsv.py"

rem generate preliminary final output (without deconvolution of precursor XICs: ozid_barchart; with deconvolution of precursor XICs: final_barchart)
rem "C:\Users\menzel2\AppData\Local\Programs\Python\Python39\python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_6_deconvolution.py"
"python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_6_deconvolution.py"

rem begin move results files excel and csv to folder in OzFAD1_results location of current run
md OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_report_dia_xic.tsv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_xic_report_vpw20_6_intensities.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_xic_report_vpw20_6_times.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\OzFAD1_workflow_parameters.xlsx %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_report_dia_int.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\OzFAD1_4_input_DIA_Q.xlsx %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\OzFAD1_4_DIA_deconv_raw.xlsx %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
rem move %~dp0\jpmlipidomics_vpw20_9_selected_final.xlsx %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
rem move %~dp0\skyl_report_dda_filtered_selected.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
rem end move results files excel and csv to folder in OzFAD1_results location of current run

if %ERRORLEVEL% NEQ 0 GOTO END
GOTO END
:END
ENDLOCAL
rem PAUSE
