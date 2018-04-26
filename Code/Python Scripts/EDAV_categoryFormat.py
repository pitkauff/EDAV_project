# -*- coding: utf-8 -*-
"""
Created on Sat Apr 14 13:51:21 2018

@author: Carlo
"""
import csv


FILE_IN = "Full_Cat_List.txt"
FILE_OUT = "categories.csv"

with open(FILE_IN) as f:
    content = f.readlines()
# you may also want to remove whitespace characters like `\n` at the end of each line
content = [x.strip() for x in content] 

with open(FILE_OUT, "wb") as f:
    writer = csv.writer(f, delimiter = '", "')   
    writer.writerow(content)
        
