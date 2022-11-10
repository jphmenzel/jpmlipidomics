# -*- coding: UTF-8 -*-

# Jan Philipp Menzel
## Notes: Derivative, positive fixed charge
## NOTES: VIRTUAL PRECURSOR - PrecursorName and PrecursorMz are artificially set +Xe (only column 3 and 5), fragment transitions correct including precursor
## NOTES: Virtual precursor forces Skyline to consider all transitions incl. real precursor (fragment in transition list), Skyline Setting: TransitionSettings-Filter-IonTypes-f 
import math
import openpyxl
import pandas as pd
import datetime
import openpyxl
from openpyxl import Workbook
import statistics
from statistics import mean
from statistics import median
################ DATABASE ## Source: Internetchemie.info 
#isotope=["1H", "2H", "12C", "13C", "14N", "15N", "16O", "17O", "18O", "19F", "23Na", "28Si", "29Si", "30Si", "31P", "32S", "33S", "34S", "36S", "39K", "40K", "41K", "35Cl", "37Cl", "79Br", "81Br"]
#mass=[1.00783, 2.01410 , 12.00000, 13.00335, 14.00307, 15.00011, 15.99491, 16.99913, 17.99916, 18.99840, 22.97977, 27.97693, 28.97649, 29.97377, 30.97376, 31.97207, 32.97146, 33.96787, 35.96708, 38.96371, 39.96400, 40.96183, 34.96885, 36,96590, 78.91834, 80.91629]
#abundance=[99.9885, 0.0115, 98.93, 1.07, 99.636, 0.364, 99.757, 0.04, 0.2, 100, 100, 92.233, 4.685, 3.092, 100, 94.93, 0.76, 4.29, 0.02, 93.2581, 0.0117, 6.7302, 75.76, 24.24, 50.69, 49.31]
################
#default=eval(input('Run workflow with default parameters? (Yes: 1 / No: 0) (Derivatization agent: AMPP; Slow and full workflow including all FA; Apply retention time limitation; Use Fatty Acid Library to prevent filtering out important FA; Max RT = 17.5 min; FA: 12 - 24 C; Max m/z error: 10 ppm; Precursor peak area threshold: 3000; Product peak area threshold: 200.) :'))
default=0
isotope=['1H   ', '2H  ', '12C   ', '14N   ', '16O    ', '31P   ', '32S    ' '23Na     ', 'e     ', '132Xe', '   127I']
imass=[1.007825, 2.0141, 12.00000, 14.00307, 15.99491, 30.973762, 31.97207, 22.98977, 0.000548585, 131.9041535, 126.904473]
###########

beforeall=datetime.datetime.now()
#print('Workflow is running ...')

#begin read file and save data in lists, edit strings and calculate fragment masses, build output lists
trdf=pd.read_csv('skyl_report_vpw20_6_DDA_confirmed_DIA_int_check.csv')
toprowx=[trdf.columns.values.tolist()]
toprow=toprowx[0]
trdf=trdf.transpose()
writelist=trdf.values.tolist()
ki=len(writelist[0])			## writelist is report file int_check, with potentially failed integration entries
print('Number of rows in skyl_report_vpw20_6_DDA_confirmed_DIA_int_check.csv: %d' % ki)
#print(ki)
#####################################################################################################

#begin read file and save data in lists, edit strings and calculate fragment masses, build output lists
ttrdf=pd.read_csv('jpmlipidomics_dda_vpw20_4_int_check.csv')
ttoprowx=[trdf.columns.values.tolist()]
ttoprow=ttoprowx[0]
ttrdf=ttrdf.transpose()
swritelist=ttrdf.values.tolist()
tki=len(swritelist[0])			## twritelist is transition list int_check, with potentially failing entries that need to have their exrt moved
print('Number of rows in jpmlipidomics_dda_vpw20_4_int_check.csv.csv: %d' % ki)
#print(ki)
#####################################################################################################

#begin go through row of writelist to find failed entries
r=0
while r<ki:
	e=writelist[1][r] #sheetinput.cell(row=r, column=2)	# Precursorname		# begin determine which row to start (r) and to end (s)
	s=r+1
	st=0
	while st<1:
		if s>(len(writelist[1])-1):
			ne='stop_loop'
		else:
			ne=writelist[1][s] #sheetinput.cell(row=s, column=2)	# Precursorname
		if ne==e:
			s=s+1
			st=0
		else:
			s=s-1
			st=1		# end determine s
	if str(writelist[11][r])=='nan':
		# this one needs exrt replacing in targetlist
		cfail=str(writelist[1][r])
		cch=int(cfail[len(cfail)-1])
		cfail=cfail[:-1]
		cnew=cfail+str(cch+1)
		t=r
		while t<s+1:
			swritelist[1][t]=cnew
			swritelist[11][t]=float(swritelist[11][t])+0.01
			t=t+1
	r=s+1

#end go through row of writelist to find failed entries

mlistname=[]
precname=[]
precformula=[]
precadduct=[]
precmz=[]
precchrg=[]
prodname=[]
prodformula=[]
prodadduct=[]
prodmz=[]
prodchrg=[]
exrtwindow=[]
explicitrt=[]

# swritelist is list with updated species that will not fail
t=0
while t<(len(swritelist[0])): 
	e=swritelist[0][t] ## mlistname	# begin append rows of suitable species to lists for later saving 
	mlistname.append(e)
	e=swritelist[1][t] ## precname	
	precname.append(e)
	e=swritelist[2][t] ## precformula	
	precformula.append(e)
	e=swritelist[3][t] ## precadduct	
	precadduct.append(e)
	e=swritelist[4][t] ## precmz
	precmz.append(e)
	e=swritelist[5][t] ## precchrg
	precchrg.append(e)
	e=swritelist[6][t] ## prodname
	prodname.append(e)
	e=swritelist[7][t] ## prodformula
	prodformula.append(e)
	e=swritelist[8][t] ## prodadduct
	prodadduct.append(e)
	e=swritelist[9][t] ## prodmz
	prodmz.append(e)
	e=swritelist[10][t] ## 	prodchrg
	prodchrg.append(e)
	e=swritelist[11][t] ##	explicitrt
	explicitrt.append(e)
	exrtwindow.append(0.1)		################################# ENTER EXPLICIT RETENTION TIME WINDOW ##############################
	t=t+1

writelist=[]
writelist.append(mlistname)
writelist.append(precname)
writelist.append(precformula)
writelist.append(precadduct)
writelist.append(precmz)
writelist.append(precchrg)
writelist.append(prodname)
writelist.append(prodformula)
writelist.append(prodadduct)
writelist.append(prodmz)
writelist.append(prodchrg)
writelist.append(explicitrt)
writelist.append(exrtwindow)


# save updated transition list as jpmlipidomics_dda_vpw20_4_rt_shifted.csv

toprow=['MoleculeGroup', 'PrecursorName', 'PrecursorFormula', 'PrecursorAdduct', 'PrecursorMz', 'PrecursorCharge', 'ProductName', 
		'ProductFormula', 'ProductAdduct', 'ProductMz', 'ProductCharge', 'PrecursorRT', 'PrecursorRTWindow']
#print('swritelist created')
transitionresultsdf=pd.DataFrame(writelist).transpose()
#print('Transposed')
transitionresultsdf.columns=[toprow[0],toprow[1],toprow[2],toprow[3],toprow[4],toprow[5],toprow[6],toprow[7],toprow[8],toprow[9],toprow[10],toprow[11],toprow[12]]
#print('Transposed and DataFrame created')
after=datetime.datetime.now()
after=str(after)
filename='jpmlipidomics_dda_vpw20_4_rt_shifted.csv'
transitionresultsdf.to_csv(filename, index=False)
print('Transition list is saved as jpmlipidomics_dda_vpw20_4_rt_shifted.csv')
afterall=datetime.datetime.now()
dt=afterall-beforeall
print('Calculation time (h:mm:ss) is: %s' % dt)
#print('Calculation time (h:mm:ss) is:')
#print(dt)








