# -*- coding: UTF-8 -*-

#Jan Philipp Menzel testcode for speed of calculation
#created: 2018 04 18
#Notes: counts iteratively to 100 000 000 (takes about 11 sec, QUT PC)
import math
import openpyxl
import pandas as pd
import datetime
import statistics
import csv
beforeall=datetime.datetime.now()

segmentsize=500	# min number of entries in xic report and transitions report to be processed at once (once functional change to 500, then increase to test if advantageous)

convertfile=1		# set 0 for troubleshooting (run this python script on its own using csv file), 1 is default value for running workflow through batch file
if convertfile==1:
	# begin convert tsv file generated from Skyline runner to csv file # BEGIN EXTRACT INTENSITIES
	try:
	    with open(r'skyl_report_dia_xic.tsv', 'r', newline='\n') as in_f, \
	         open(r'skyl_xic_report_vpw20_6_intensities.csv', 'w', newline='\n') as out_f:
	        reader = csv.reader(in_f, delimiter='\t')
	        writer = csv.writer(out_f, delimiter=',')
	        for li in reader:
	            try:
	                writer.writerow([li[0], li[1], li[2], li[3], li[4], li[5], li[6], li[7], li[9]])
	            except IndexError:  # Prevent errors on blank lines.
	                pass
	except IOError as err:
	    print(err)
	# end convert tsv file generated from Skyline runner to csv file
	# begin delete double quotes from generated csv file
	with open('skyl_xic_report_vpw20_6_intensities.csv', "r+", encoding="utf-8") as csv_file:
	    content = csv_file.read()
	with open('skyl_xic_report_vpw20_6_intensities.csv', "w+", encoding="utf-8") as csv_file:
	    csv_file.write(content.replace('"', ''))
	# end delete double quotes from generated csv file # END EXTRACT INTENSITIES
	# begin convert float values for intensities to integers to reduce file size
	tempdf=pd.read_csv('skyl_xic_report_vpw20_6_intensities.csv', header=None, skiprows=1)
	templist=tempdf.values.tolist()
	tcol=0
	trow=0
	while trow<(len(templist)):		# replaces content of first column (FileName) with int(0)
		templist[trow][tcol]=int(0)
		trow=trow+1
	tcol=2
	trow=0
	while trow<(len(templist)):		# replaces content of third column (Precursorcharge) with int(0)
		templist[trow][tcol]=int(0)
		trow=trow+1
	tcol=6
	trow=0
	while trow<(len(templist)):		# replaces content of seventh column (IsotopeLabel) with int(0)
		templist[trow][tcol]=int(0)
		trow=trow+1
	tcol=9
	trow=0
	while trow<(len(templist)):		# converts intensities to integers
		tcol=9
		while tcol<(len(templist[0])):
			templist[trow][tcol]=float(templist[trow][tcol])
			templist[trow][tcol]=round(templist[trow][tcol], 0)
			templist[trow][tcol]=int(templist[trow][tcol])
			tcol=tcol+1
		trow=trow+1
	tempconvdf=pd.DataFrame(templist)
	filename='skyl_xic_report_vpw20_6_intensities.csv'
	tempconvdf.to_csv(filename, index=False)
	templist=[]
	tempconvdf=pd.DataFrame(templist)
	tempdf=pd.DataFrame(templist)
	# end convert float values for intensities to integers to reduce file size
if convertfile==1:
	# begin convert tsv file generated from Skyline runner to csv file # BEGIN EXTRACT TIMES
	try:
	    with open(r'skyl_report_dia_xic.tsv', 'r', newline='\n') as in_f, \
	         open(r'skyl_xic_report_vpw20_6_times.csv', 'w', newline='\n') as out_f:
	        reader = csv.reader(in_f, delimiter='\t')
	        writer = csv.writer(out_f, delimiter=',')
	        for li in reader:
	            try:
	                writer.writerow([li[8]])
	            except IndexError:  # Prevent errors on blank lines.
	                pass
	except IOError as err:
	    print(err)
	# end convert tsv file generated from Skyline runner to csv file
	# begin delete double quotes from generated csv file
	with open('skyl_xic_report_vpw20_6_times.csv', "r+", encoding="utf-8") as csv_file:
	    content = csv_file.read()
	with open('skyl_xic_report_vpw20_6_times.csv', "w+", encoding="utf-8") as csv_file:
	    csv_file.write(content.replace('"', ''))
	# end delete double quotes from generated csv file
	xictimesdf=pd.read_csv('skyl_xic_report_vpw20_6_times.csv', header=None, skiprows=1, nrows=1)
	xictimeslistfromdf=xictimesdf.values.tolist()
	xictimeslist=xictimeslistfromdf[0]		# contains times of XICs
	aa=0
	while aa<8:
		xictimeslist.insert(0, 0)
		aa=aa+1
	# begin save times of XICs in csv file
	xictimesconvdf=pd.DataFrame(xictimeslist).transpose()
	filename='skyl_xic_report_vpw20_6_times.csv'
	xictimesconvdf.to_csv(filename, index=False)
	# end save times of XICs in csv file
	xictimesdf=pd.DataFrame(templist)
	xictimeslistfromdf=[]
	#print(xictimesdf)
	#print('list:')
	#print(xictimeslist)
	#print(len(xictimeslist))
	# END EXTRACT TIMES
