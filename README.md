# jpmlipidomics

Code associated to the publication "OzFAD: Ozone-enabled fatty acid discovery reveals unexpected diversity in the human lipidome." by 
Jan Philipp Menzel, Reuben S. Young, Aurelie H. Benfield, Julia S. Scott, Lisa M. Butler, Sonia T. Henriques, Berwyck L.J. Poad and Stephen J. Blanksby, 2022.
A preprint is available on BioRxiv:
https://www.biorxiv.org/content/10.1101/2022.10.24.513604v1

The code in this repository allows processing of LC-OzID-MS and LC-OzID-MS/MS files as well as mass spectrometry data from direct infusion ESI-MS as part of the workflow introduced in the associated publication. Usage of the code is explained in the Supplementary Information of the associated publication.

IMPORTANT: Skyline (64-bit), version 21.1.0.278 was used for the analysis of the data in the associated publication. Newer versions (including the latest version of Skyline) may not be compatible with the current version of this workflow. To download this version of Skyline, go to the Skyline MS website > release installation page for your system architecture (here 64-bit) > follow link for unplugged installer > "I Agree" > "Archive" link below the "Download" link > Skyline (64-bit) 21.1.0.278. (https://skyline.ms/labkey/_webdav/home/software/Skyline/%40files/installers/Skyline-64_21_1_0_278.zip)


Latest updates to the workflow: 

2022_11_02: Batch files now contain relative paths, only the path to the python version installed locally needs to be adjusted in each batch file, when setting up the workflow. Both python versions 3.9 and 3.11 (python.org) as well as other python versions should be compatible with the workflow. 

2022_11_09: Speed improvements of initial precursor analysis and generation of target lists. The first batch file in the workflow may run significantly faster (< 90 sec) than outlined in the Supplementary Information of the preprint published on BioRxiv (> 6 min).

