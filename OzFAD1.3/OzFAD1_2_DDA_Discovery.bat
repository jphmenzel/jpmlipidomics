@ECHO OFF
rem ECHO ------- OzFAD1 stage 2 -------
rem ECHO This batch file controls the de novo fatty acid analysis workflow using DDA LC-OzID-MS/MS data.
rem ECHO This stage enables de novo discovery of fatty acid double bond isomers based on the data dependent acquisition.
rem ECHO This workflow was created by Jan Philipp Menzel, Mass Spectrometry Development Laboratory, Queensland University of Technology, 2021 / 2022.
rem ECHO Before running the workflow, make sure that:
rem ECHO ____
rem ECHO  1 There is enough diskspace available, recommended is at least 10 GB free space.
rem ECHO  2 The maximum retention time in the Transition Settings in the Skyline file template.sky is set according to the analysis.
rem ECHO  3 The LC-OzID-MS datasets that are to be analysed and python programs are in the appropriate directories.
rem ECHO  4 The appropriate file jpmlipidomics_dda_targetlist.txt must be copied into OzFAD1.
rem ECHO  5 The appropriate file OzFAD1_workflow_parameters.xlsx must be copied into OzFAD1.
rem ECHO ____

rem ECHO For instructions and further information see the publication: _.
rem set /p identifier=What is the identifier for this run of the workflow?:
set identifier=%1

rem testing to pass discoverylevel and discoverylimitation
set discoverylevel=%2
set discoverylimitation=%3

rem run python script to make transition list containing all found db isomers for each precursor at RT defined in targetlist
rem pass identifier_dda from python (from excel file workflow_parameters into this bat script and use as %identifier%
rem "C:\Users\menzel2\AppData\Local\Programs\Python\Python39\python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_dda_0_agnostic.py"
"python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_dda_0_agnostic.py" %discoverylevel%
rem output is file jpmlipidomics_dda_vpw19_0.csv containing all possible transitions for each target (full list)

SETLOCAL
set ROOT_ANALYSIS_DIR=%~dp0
set SKYLINE_RUNNER="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\SkylineRunner.exe"
set BAT_Script_DDA_Full="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_Full.bat"
set BAT_Script_DDA_First_Filter="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_First_Filter.bat"
set BAT_Script_DDA_Second_Filter="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_Second_Filter.bat"
set BAT_Script_DDA_Third_Filter="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_Third_Filter.bat"
set BAT_Script_DDA_DIA_rt_shift1="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_DIA_rt_shift1.bat"
set BAT_Script_DDA_Summarize="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\Skyline_Analysis_DDA_summarize.bat"
set LOG="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\workflow_log_files\Import.log"
FOR /F %%A IN ('WMIC OS GET LocalDateTime ^| FINDSTR \.') DO @SET DT=%%A
set LOG_ROLLOVER="%ROOT_ANALYSIS_DIR%\OzFAD1_black_box\workflow_log_files\Import_%DT:~0,8%_%DT:~8,6%.log"

if exist %LOG% move %LOG% %LOG_ROLLOVER%

rem run DDA Skyline analysis
call %BAT_Script_DDA_Full%  OzFAD1_results DDA_current_LCMS_dataset %identifier% 100000 12 "template.sky"
rem output file is skyl_report_dda_vpw19_0.csv (full list report)

rem analyze skyline dda report and verify or falsify fatty acid isomer assignments, falsified species send to rank3, verfified species remain
rem "C:\Users\menzel2\AppData\Local\Programs\Python\Python39\python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_dda_1_filter1.py"
"python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_dda_1_filter1.py"
rem output is jpmlipidomics_dda_vpw19_1_filtered.csv containing filtered transitions for targets, but still duplicates

call %BAT_Script_DDA_First_Filter%  OzFAD1_results DDA_current_LCMS_dataset %identifier% 100000 12 "template.sky"
rem output file is skyl_report_dda_vpw19_1_filtered.csv and skyl_xic_dda_report_vpw19_1.tsv file with chromatograms, python script within carries out conversion of tsv to csv and filter2

rem run skyline analysis of filter 2 transition list
call %BAT_Script_DDA_Second_Filter%  OzFAD1_results DDA_current_LCMS_dataset %identifier% 100000 12 "template.sky"

rem Analyze extracted ion chromatograms from second filter step and use target list to derive DDA based XICs, (5point / 7 point smoothed), and determine peaks and build transition list for Skyline
"python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_dda_xic_analyzer.py"

rem run skyline analysis of filter 2 transition list
call %BAT_Script_DDA_Third_Filter%  OzFAD1_results DDA_current_LCMS_dataset %identifier% 100000 12 "template.sky"
rem now the filtered results are in the last Skyline file. This Skyline file needs to be manually assessed, to ensure no false positives are present anymore.




rem generate transition list with 16:1_n-7_cis straight chain as an anchor for detecting rt shift between DDA and DIA datasets
rem "C:\Users\menzel2\AppData\Local\Programs\Python\Python39\python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_dda_3_rt_shift1.py"
"python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_dda_3_rt_shift1.py"

rem run DIA dataset with transition list with 16:1_n-7_cis straight chain, export chromatograms
call %BAT_Script_DDA_DIA_rt_shift1%  OzFAD1_results DIA_current_LCMS_dataset %identifier% 100000 12 "template.sky"

rem run python script to calculate rt shifted transition list for DIA analysis with DDA confirmed species
rem "C:\Users\menzel2\AppData\Local\Programs\Python\Python39\python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_dda_4_rt_shift2.py"
"python.exe" "%~dp0\OzFAD1_black_box\OzFAD1_py\OzFAD1_py_black_box\jpmlipidomics_dda_4_rt_shift2.py"

rem run final Skyline analysis of DIA dataset using transition list from DDA analysis for manual assessment
call %BAT_Script_DDA_Summarize%  OzFAD1_results DIA_current_LCMS_dataset %identifier% 100000 12 "template.sky"
rem The last Skyline file needs to be manually assessed to make sure that integration limits are set correctly

rem begin move results files excel and csv to folder in OzFAD1_results location of current run
md OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
rem move %~dp0\skyl_report_vpw20_4_rank1.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files
move %~dp0\OzFAD1_dda_targetlist.txt %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\jpmlipidomics_dda_vpw20_0.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\jpmlipidomics_dda_vpw20_1_filtered.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
rem move %~dp0\OzFAD1_2_DDA_found.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_report_dda_vpw20_0.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_report_dda_vpw20_1_filtered.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_report_dda_vpw20_2_filtered.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_xic_dda_report_vpw20_1.tsv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_xic_dda_report_vpw20_1_intensities.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_xic_dda_report_vpw20_1_times.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\OzFAD1_workflow_parameters.xlsx %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\jpmlipidomics_dda_vpw20_3_rt_shift1.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_report_dda_vpw20_3_rt_shift1.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_xic_dda_report_vpw20_3.tsv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_xic_dda_report_vpw20_3_times.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_xic_dda_report_vpw20_3_intensities.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\jpmlipidomics_dda_vpw20_4_rt_shifted.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_report_dda_found.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\jpmlipidomics_dda_found.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\MUFA_preliminary_dECL_plot.xlsx %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\Clean_DDA_XICs_smoothed.xlsx %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_xic_report_dda_analyzer_times.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_xic_report_dda_analyzer_intensities.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\skyl_xic_report_dda_analyzer.tsv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
move %~dp0\OzFAD1_2_DDA_found_preliminary.csv %~dp0\OzFAD1_results\%identifier%\transition_lists_and_report_csv_files_dda
rem end move results files excel and csv to folder in OzFAD1_results location of current run

if %ERRORLEVEL% NEQ 0 GOTO END
GOTO END
:END
ENDLOCAL
rem PAUSE
