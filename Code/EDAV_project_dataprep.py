#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sun Apr  8 12:49:25 2018

@author: michelkauffmann
"""

import re
import pandas as pd
from textblob import TextBlob

data1 = pd.read_csv("restaurant reviews Toronto 1.csv")
data2 = pd.read_csv("restaurant reviews Toronto 2.csv")

result = pd.concat([data1, data2])
revs = result["text"]

def getSentScore(tweet):
    blob = TextBlob(tweet)
    sent_score = 0
    for sentence in blob.sentences:
        sent_score += sentence.sentiment.polarity
        
    return sent_score  

def genCorpus(theText): 
    theText = theText.split()
    tokens = [token.lower() for token in theText] 
    tokens = [re.sub(r'[^a-zA-Z0-9]+', ' ',token) for token in tokens] 
    tokens = [token for token in tokens if token.lower().isalpha()] 
    tokens = " ".join(tokens) 
    
    return tokens

revs = revs.apply(genCorpus)
sent = revs.apply(getSentScore)

data = pd.concat([result, sent], axis = 1)

data.to_csv("reviews_in_Toronto.csv", sep = ',', index = False, index_label = False)
