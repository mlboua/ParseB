# -*- coding: utf-8 -*-

import re


def findSetsDecl(text):
    ''' Retrouve toutes les déclarations de SET dans le fichier et les ramplace'''

    setRegexp = '[A-Za-z_0-9]+\s*=\s*\{\s*[A-Za-z_0-9]+\s*\n*[,\n*\s*[A-Za-z_0-9]+\s*]*\}'
    i = 0
    setContentArray = dict()
    setToPut = dict()
    foundPatterns = re.findall(setRegexp, txt)
    #print(foundPatterns)
    for p in foundPatterns:
        #setContentArray = dict()
        #setToPut = dict()
        #print(p)
        setElt = p.split('=')
        #print(setElt)
        setName = setElt[0]
        setCont = re.sub('{', '', setElt[1])
        setCont = re.sub('}', '', setCont).split(',')
        #setToPut[setName] = setCont.split(',')
        #print(setCont)
        for c in setCont:
            i = i+1
            setContentArray[c] = str(i)
        setToPut[setName] = setContentArray
    return setContentArray



#-----------------------------------------------------------------------
txt = ''
with open('SysAlim.mch','r') as myFile:
    txt = myFile.read()
 
ptxt = findSetsDecl(txt)
for key,val in ptxt.items():
    txt = re.sub(r'\b'+key.strip(), val, txt)
    #print("{},{}".format(e,v))
#print(txt)

with open('SysAlim1.mch','w') as outFile:
    outFile.write(txt)
