# jpmlipidomics

Code associated to the publication "OzFAD: Ozone-enabled fatty acid discovery reveals unexpected diversity in the human lipidome." by 
Jan Philipp Menzel, Reuben S. Young, Aurelie H. Benfield, Julia S. Scott, Lisa M. Butler, Sonia T. Henriques, Berwyck L.J. Poad and Stephen J. Blanksby, 2022.
A preprint is available on BioRxiv:
https://www.biorxiv.org/content/10.1101/2022.10.24.513604v1

The code in this repository allows processing of LC-OzID-MS and LC-OzID-MS/MS files as well as mass spectrometry data from direct infusion ESI-MS as part of the workflow introduced in the associated publication. Usage of the code is explained in the Supplementary Information of the associated publication.

IMPORTANT: Skyline (64-bit), version 21.1.0.278 was used for the analysis of the data in the associated publication. Newer versions (including the latest version of Skyline) may not be compatible with the initial version of this workflow. Skyline Daily may not be compatible with the workflow. To download this version of Skyline, go to the Skyline MS website > release installation page for your system architecture (here 64-bit) > follow link for unplugged installer > "I Agree" > "Archive" link below the "Download" link > Skyline (64-bit) 21.1.0.278. (try https://skyline.ms/wiki/home/software/Skyline/page.view?name=install-64-disconnected_22_2, or https://skyline.ms/labkey/_webdav/home/software/Skyline/%40files/installers/Skyline-64_21_1_0_278.zip)

If any problems with getting started with the OzFAD workflow remain or occur during data analysis, please contact me via ResearchGate, LinkedIn or E-mail.
https://www.researchgate.net/publication/364795613_OzFAD_Ozone-enabled_fatty_acid_discovery_reveals_unexpected_diversity_in_the_human_lipidome >> Jan Philipp Menzel
https://au.linkedin.com/in/jan-philipp-menzel-b09455b7


Latest updates to the workflow:                                              

2023_01_09: Updated version OzFAD1.3 released: 

    - NEW: Graphical User Interface (GUI)
    
    - NEW: All programs accessible via graphical user interface, which can be started either via a python program or an executable.
    
    - NEW: Improved automated filtering after discovery step.
    
    - NEW: Added files for testing of the workflow analysis steps (see folder Testing_files). 
    The files represent MCF7, replicate 1; FAME 37mix or Pooled Human Plasma NIST 1950 SRM.
    
    - NOTE: If some steps of the workflow do not execute correctly after being started through OzFAD1v3_GUI_5.exe, 
    start the GUI from python program OzFAD1v3_GUI_5.py via Visual Studio Code (or other IDE). 
    This may be required, if version problems with tcl persist. 


2022_11_16: The files in this repository are now in the folders in which they need to be locally for running the workflow. Paths to python do not need to be updated anymore, as long as python (any version of python3 should be fine) is installed correctly (Added to PATH during installation). To set up the workflow, simply download code as a zip file, unpack and copy OzFAD1.2 folder into your local home / personal folder; make sure that python with all relevant packages is installed, incl. IDE, as well as Skyline MS.

2022_11_14: The workflow is now compatible with latest Skyline versions. Two images explaining the steps of the workflow and the required folder structure for the files contained in this repository are added (Small changes to the versions inluded in the preprint).

2022_11_09: Speed improvements of initial precursor analysis and generation of target lists. The first batch file in the workflow may run significantly faster (< 90 sec) than outlined in the Supplementary Information of the preprint published on BioRxiv (> 6 min).

2022_11_02: Batch files now contain relative paths, only the path to the python version installed locally needs to be adjusted in each batch file, when setting up the workflow. Both python versions 3.9 and 3.11 (python.org) as well as other python versions should be compatible with the workflow. 
