# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import pandas as pd
from nltk.corpus import stopwords
import re
from tqdm import tqdm

stopWords = set(stopwords.words('english'))

def cleaner(text):
    text = text.split(" ")
    tokens = [token.lower() for token in text] 
    tokens = [re.sub(r'[^a-zA-Z0-9]+', ' ',token) for token in tokens] 
    tokens = [token for token in tokens if token.lower().isalpha()] 
    tokens = [word for word in tokens if word not in stopWords] 
    tokens = " ".join(tokens)
    
    return tokens

def word_count(text, words):
    text = text.split(" ")
    for i in text:
        if i not in words:
            words[i] = 1
        else:
            words[i] += 1
    
    return words
    
toronto = pd.read_csv("reviews_in_Toronto.csv")
toronto["text"] = toronto["text"].apply(cleaner)
toronto.rename(columns={'text.1':'sent'}, inplace = True)
good_revs = toronto[toronto.sent >= 0.5]["text"].tolist()
bad_revs = toronto[toronto.sent < -0.5]["text"].tolist()

words_good = {}
words_bad = {}

for i in tqdm(good_revs):
    words_good = word_count(i, words_good)

for i in tqdm(bad_revs):
    words_bad = word_count(i, words_bad)

words_good = pd.DataFrame(list(words_good.items()), columns = ["word", "freq"])
words_bad = pd.DataFrame(list(words_bad.items()), columns = ["word", "freq"])

words_good.to_csv("good_revs.csv", sep = ',', index = False, index_label = False)
words_bad.to_csv("bad_revs.csv", sep = ',', index = False, index_label = False)

