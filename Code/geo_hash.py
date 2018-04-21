#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Apr 17 11:48:02 2018

@author: michelkauffmann
"""

import pandas as pd
import pygeohash as g

def geoHash(lat,lon,precision):
    return g.encode(lat,lon,precision)

data = pd.read_csv("Toronto_revs_coord.csv")
geo = pd.read_csv('GeoHash.txt', sep = ",")

data["geohash"] = data.apply(lambda x: geoHash(x['latitude'],x['longitude'],6), axis=1)
data = data[data.geohash.isin(geo.ix[:,0].tolist())]
hashes = geo.ix[:,0].tolist()
areas = geo.ix[:,1].tolist() 
geo = {}
for i in range(len(hashes)):
    geo[hashes[i]] = areas[i]
    
data = data.replace({"geohash": geo})

data.to_csv("Toronto_revs_area.csv", sep = ',', index = False, index_label = False)